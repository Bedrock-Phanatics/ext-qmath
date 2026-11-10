//! Block collision data and the Entity::move() collision solver.
//! Cells without data are unknown, and queries touching them fail instead of treating them as air.
//! A box may reach one block out of its own cell, which is as far as queries look for it.

const std = @import("std");
const Allocator = std.mem.Allocator;
const num = @import("num.zig");
const geom = @import("geom.zig");
const Box = geom.Box;
const Vec = geom.Vec;

const pow = @import("libm.zig").powFn;

pub const Info = enum(u8) {
    custom = 0,
    cube = 1,
    none = 2,
    may_overflow = 3,
    unknown = 255,

    pub fn fromInt(v: i64) ?Info {
        return switch (v) {
            0 => .custom,
            1 => .cube,
            2 => .none,
            3 => .may_overflow,
            else => null,
        };
    }
};

pub const max_boxes_per_cell: usize = 64;
const max_boxes_per_section: usize = std.math.maxInt(u16);
const max_query_boxes: usize = 1 << 20;
/// Keeps section coordinates packable into the u64 key.
const horizontal_limit: i64 = 1 << 25;
const vertical_limit: i64 = 1 << 23;
pub const max_query_sections: usize = 4096;
pub const section_cells = 4096;

pub const Error = error{
    OutOfMemory,
    OutOfRange,
    UnknownCell,
    InvalidBox,
    InvalidInfo,
    TooManyBoxes,
    MissingBoxes,
    DuplicateCell,
    RegionFull,
    RegionTooLarge,
    Frozen,
};

const Cell = packed struct(u32) {
    first: u16 = 0,
    count: u8 = 0,
    info: Info = .unknown,
};

const Cells = struct {
    list: [section_cells]Cell,
    /// One bit per overflowing cell, a word of 16 heights per x and z, so a query can skip the rest.
    over: [256]u16,
    /// One bit per unknown cell.
    hole: [256]u16,
    /// One bit per cell that is, or touches, an overflowing or unknown cell of this section.
    /// A ray only has to look around the voxels that have it set.
    near: [256]u16,

    const none_set: [256]u16 = @splat(0);

    const Change = enum { same, set, cleared };

    fn flip(mask: *[256]u16, i: u12, on: bool) Change {
        const bit = @as(u16, 1) << @intCast(i & 15);
        if ((mask[i >> 4] & bit != 0) == on) return .same;
        mask[i >> 4] ^= bit;
        return if (on) .set else .cleared;
    }

    /// What happened to the bits `near` is built from.
    fn mark(self: *Cells, i: u12, info: Info) Change {
        const over = flip(&self.over, i, info == .may_overflow);
        const hole = flip(&self.hole, i, info == .unknown);
        if (over == .cleared or hole == .cleared) return .cleared;
        return if (over == .set or hole == .set) .set else .same;
    }

    fn markNear(self: *Cells, i: u12, change: Change) void {
        if (change == .same) return;
        const x: usize = i >> 8;
        const z: usize = (i >> 4) & 15;
        const bit = @as(u16, 1) << @intCast(i & 15);
        const spread = bit | (bit << 1) | (bit >> 1);
        for (x -| 1..@min(x + 2, 16)) |nx| {
            for (z -| 1..@min(z + 2, 16)) |nz| {
                // A new bit only adds to its surroundings, a lost one may or may not have been the last.
                const column = (nx << 4) | nz;
                if (change == .set) self.near[column] |= spread else self.near[column] = self.around(nx, nz);
            }
        }
    }

    fn around(self: *const Cells, x: usize, z: usize) u16 {
        var w: u16 = 0;
        for (x -| 1..@min(x + 2, 16)) |nx| {
            for (z -| 1..@min(z + 2, 16)) |nz| w |= self.over[(nx << 4) | nz] | self.hole[(nx << 4) | nz];
        }
        return w | (w << 1) | (w >> 1);
    }

    fn markAll(self: *Cells) void {
        for (0..16) |x| {
            for (0..16) |z| self.near[(x << 4) | z] = self.around(x, z);
        }
    }
};

/// Bits `lo` to `hi` of one column of `Cells.over`.
fn columnMask(lo: usize, hi: usize) u16 {
    return @truncate((@as(u32, 2) << @intCast(hi)) - (@as(u32, 1) << @intCast(lo)));
}

const Section = struct {
    /// Set while every cell shares this info and there are no boxes.
    uniform: ?Info = null,
    cells: ?*Cells = null,
    boxes: std.ArrayList(Box) = .empty,
    live: u32 = 0,
    unknown: u16 = section_cells,
    /// Cells whose boxes reach into their neighbours.
    overflow: u16 = 0,

    fn free(self: *Section, allocator: Allocator) void {
        self.replace(allocator, .{});
        allocator.destroy(self);
    }

    fn replace(self: *Section, allocator: Allocator, with: Section) void {
        if (self.cells) |cells| allocator.destroy(cells);
        self.boxes.deinit(allocator);
        self.* = with;
    }

    /// Only for sections that hold their cells one by one.
    fn retag(self: *Section, i: u12, info: Info) void {
        self.cells.?.markNear(i, self.tag(i, info));
    }

    /// retag() for bulk writers that rebuild `near` once at the end.
    fn tag(self: *Section, i: u12, info: Info) Cells.Change {
        const cells = self.cells.?;
        const c = &cells.list[i];
        self.unknown = self.unknown - @intFromBool(c.info == .unknown) + @intFromBool(info == .unknown);
        self.overflow = self.overflow - @intFromBool(c.info == .may_overflow) + @intFromBool(info == .may_overflow);
        c.info = info;
        return cells.mark(i, info);
    }

    fn drop(self: *Section, i: u12) void {
        const c = &self.cells.?.list[i];
        self.live -= c.count;
        c.first = 0;
        c.count = 0;
    }

    /// `scratch` backs the synthesized box of a full cube.
    fn boxesOf(self: *const Section, c: Cell, x: i64, y: i64, z: i64, scratch: *Box) []const Box {
        return switch (c.info) {
            .unknown, .none => &.{},
            .cube => blk: {
                scratch.* = Box.unitAt(x, y, z);
                break :blk scratch[0..1];
            },
            .custom, .may_overflow => self.boxes.items[c.first..][0..c.count],
        };
    }

    /// Writes only append, so the dead boxes are dropped once they outnumber the live ones.
    fn trim(self: *Section) void {
        if (self.boxes.items.len > 256 and self.boxes.items.len > self.live * 2) self.compact();
    }

    fn cell(self: *const Section, i: u12) Cell {
        if (self.cells) |cells| return cells.list[i];
        return .{ .info = self.uniform orelse .unknown };
    }

    fn expand(self: *Section, allocator: Allocator) Error!*Cells {
        if (self.cells) |cells| return cells;
        const cells = try allocator.create(Cells);
        @memset(&cells.list, .{ .info = self.uniform orelse .unknown });
        cells.over = Cells.none_set;
        cells.hole = @splat(if (self.uniform == null) 0xffff else 0);
        cells.near = cells.hole;
        self.cells = cells;
        self.uniform = null;
        return cells;
    }

    /// Live ranges are not in cell order, so they move down in storage order.
    fn compact(self: *Section) void {
        const cells = &(self.cells orelse return).list;
        var order: [section_cells]u16 = undefined;
        var n: usize = 0;
        for (cells, 0..) |*c, i| {
            if (c.count == 0) {
                c.first = 0;
                continue;
            }
            order[n] = @intCast(i);
            n += 1;
        }
        std.sort.pdq(u16, order[0..n], cells, struct {
            fn lt(cs: *const [section_cells]Cell, a: u16, b: u16) bool {
                return cs[a].first < cs[b].first;
            }
        }.lt);
        var w: usize = 0;
        for (order[0..n]) |i| {
            const c = &cells[i];
            std.mem.copyForwards(Box, self.boxes.items[w..][0..c.count], self.boxes.items[c.first..][0..c.count]);
            c.first = @intCast(w);
            w += c.count;
        }
        self.boxes.shrinkRetainingCapacity(w);
    }
};

pub const SectionPos = struct { x: i32, y: i32, z: i32 };

pub fn sectionKey(sx: i32, sy: i32, sz: i32) u64 {
    const bx: u64 = @intCast(@as(i64, sx) + (1 << 21));
    const bz: u64 = @intCast(@as(i64, sz) + (1 << 21));
    const by: u64 = @intCast(@as(i64, sy) + (1 << 19));
    return (bx << 42) | (bz << 20) | by;
}

fn keyPos(key: u64) SectionPos {
    return .{
        .x = @intCast(@as(i64, @intCast(key >> 42)) - (1 << 21)),
        .z = @intCast(@as(i64, @intCast((key >> 20) & ((1 << 22) - 1))) - (1 << 21)),
        .y = @intCast(@as(i64, @intCast(key & ((1 << 20) - 1))) - (1 << 19)),
    };
}

pub fn inRange(x: i64, y: i64, z: i64) bool {
    return x > -horizontal_limit and x < horizontal_limit and z > -horizontal_limit and z < horizontal_limit and y > -vertical_limit and y < vertical_limit;
}

/// Chunk section order: x, z, y.
pub fn localIndex(lx: u4, ly: u4, lz: u4) u12 {
    return (@as(u12, lx) << 8) | (@as(u12, lz) << 4) | ly;
}

const Loc = struct { key: u64, local: u12 };

fn locate(x: i64, y: i64, z: i64) ?Loc {
    if (!inRange(x, y, z)) return null;
    return .{
        .key = sectionKey(@intCast(x >> 4), @intCast(y >> 4), @intCast(z >> 4)),
        .local = localIndex(@truncate(@as(u64, @bitCast(x))), @truncate(@as(u64, @bitCast(y))), @truncate(@as(u64, @bitCast(z)))),
    };
}

/// Section cache for one query. Adjacent sections never share a slot, so walking along a border does not thrash.
pub const Lookup = struct {
    keys: [8]u64 = @splat(std.math.maxInt(u64)),
    sections: [8]?*Section = @splat(null),

    fn slot(key: u64) u3 {
        return @intCast(((key >> 42) & 1) | (((key >> 20) & 1) << 1) | ((key & 1) << 2));
    }
};

pub const CellBoxes = struct {
    index: u12,
    boxes: []const Box,
};

pub const Region = struct {
    allocator: Allocator,
    sections: std.AutoHashMapUnmanaged(u64, *Section) = .empty,
    max_sections: u32,
    version: u64 = 0,
    frozen: bool = false,
    /// Lowest and highest section height ever stored, so a chunk can be dropped without scanning every section.
    y_lo: i32 = std.math.maxInt(i32),
    y_hi: i32 = std.math.minInt(i32),

    pub fn init(allocator: Allocator, max_sections: u32) Region {
        return .{ .allocator = allocator, .max_sections = max_sections };
    }

    pub fn deinit(self: *Region) void {
        var it = self.sections.valueIterator();
        while (it.next()) |s| s.*.free(self.allocator);
        self.sections.deinit(self.allocator);
        self.* = undefined;
    }

    /// Deep copy, unfrozen.
    pub fn clone(self: *const Region, allocator: Allocator) Error!Region {
        var copy = Region.init(allocator, self.max_sections);
        errdefer copy.deinit();
        copy.version = self.version;
        copy.y_lo = self.y_lo;
        copy.y_hi = self.y_hi;
        try copy.sections.ensureTotalCapacity(allocator, self.sections.count());
        var it = self.sections.iterator();
        while (it.next()) |e| {
            const src = e.value_ptr.*;
            const s = try allocator.create(Section);
            s.* = .{ .uniform = src.uniform, .live = src.live, .unknown = src.unknown, .overflow = src.overflow };
            copy.sections.putAssumeCapacity(e.key_ptr.*, s);
            if (src.cells) |cells| {
                const dst = try allocator.create(Cells);
                dst.* = cells.*;
                s.cells = dst;
                try s.boxes.appendSlice(allocator, src.boxes.items);
                s.compact();
            }
        }
        return copy;
    }

    pub fn sectionCount(self: *const Region) usize {
        return self.sections.count();
    }

    fn mutate(self: *Region) Error!void {
        if (self.frozen) return error.Frozen;
        self.version +%= 1;
    }

    fn sectionFor(self: *const Region, lk: *Lookup, key: u64) ?*Section {
        const i = Lookup.slot(key);
        if (lk.keys[i] != key) {
            lk.keys[i] = key;
            lk.sections[i] = self.sections.get(key);
        }
        return lk.sections[i];
    }

    fn cellAt(self: *const Region, lk: *Lookup, x: i64, y: i64, z: i64) Error!struct { cell: Cell, section: *Section } {
        const loc = locate(x, y, z) orelse return error.OutOfRange;
        const s = self.sectionFor(lk, loc.key) orelse return error.UnknownCell;
        const cell = s.cell(loc.local);
        if (cell.info == .unknown) return error.UnknownCell;
        return .{ .cell = cell, .section = s };
    }

    pub fn cellInfo(self: *const Region, lk: *Lookup, x: i64, y: i64, z: i64) Error!Info {
        return (try self.cellAt(lk, x, y, z)).cell.info;
    }

    /// `scratch` backs the synthesized box of a full cube.
    pub fn ownBoxes(self: *const Region, lk: *Lookup, x: i64, y: i64, z: i64, scratch: *Box) Error![]const Box {
        const at = try self.cellAt(lk, x, y, z);
        return at.section.boxesOf(at.cell, x, y, z, scratch);
    }

    /// Hands `sink.add(box, owner)` every box that can lie in the voxel x, y, z: its own, then those of the
    /// cells around it that reach out of their own cell. Those cells have to be known, or a box could go missing.
    pub fn reaching(self: *const Region, lk: *Lookup, x: i64, y: i64, z: i64, sink: anytype) Error!void {
        const loc = locate(x, y, z) orelse return error.OutOfRange;
        const own = self.sectionFor(lk, loc.key) orelse return error.UnknownCell;
        const cell = own.cell(loc.local);
        var scratch: Box = undefined;
        for (own.boxesOf(cell, x, y, z, &scratch)) |b| sink.add(b, .{ x, y, z });
        if (cell.info == .unknown) return error.UnknownCell;
        // Away from the faces of its section a voxel has all of its surroundings in that section.
        const lx = loc.local >> 8;
        const lz = (loc.local >> 4) & 15;
        const ly = loc.local & 15;
        if (lx -% 1 < 14 and lz -% 1 < 14 and ly -% 1 < 14) {
            const cells = own.cells orelse return;
            if (cells.near[loc.local >> 4] & (@as(u16, 1) << @intCast(ly)) == 0) return;
        }
        if (!inRange(x - 1, y - 1, z - 1) or !inRange(x + 1, y + 1, z + 1)) return error.OutOfRange;
        var sx = (x - 1) >> 4;
        while (sx <= (x + 1) >> 4) : (sx += 1) {
            var sz = (z - 1) >> 4;
            while (sz <= (z + 1) >> 4) : (sz += 1) {
                var sy = (y - 1) >> 4;
                while (sy <= (y + 1) >> 4) : (sy += 1) {
                    const s = self.sectionFor(lk, sectionKey(@intCast(sx), @intCast(sy), @intCast(sz))) orelse return error.UnknownCell;
                    const cells = s.cells orelse {
                        if (s.uniform == null) return error.UnknownCell;
                        continue;
                    };
                    // The cell of this section closest to x, y, z touches everything here that could matter.
                    const closest = locate(std.math.clamp(x, sx * 16, sx * 16 + 15), std.math.clamp(y, sy * 16, sy * 16 + 15), std.math.clamp(z, sz * 16, sz * 16 + 15)).?.local;
                    if (cells.near[closest >> 4] & (@as(u16, 1) << @intCast(closest & 15)) == 0) continue;
                    const lo: usize = @intCast(@max(y - 1, sy * 16) & 15);
                    const hi: usize = @intCast(@min(y + 1, sy * 16 + 15) & 15);
                    var cx = @max(x - 1, sx * 16);
                    while (cx <= @min(x + 1, sx * 16 + 15)) : (cx += 1) {
                        var cz = @max(z - 1, sz * 16);
                        while (cz <= @min(z + 1, sz * 16 + 15)) : (cz += 1) {
                            const column: usize = @intCast(((cx & 15) << 4) | (cz & 15));
                            if (cells.hole[column] & columnMask(lo, hi) != 0) return error.UnknownCell;
                            var m = cells.over[column] & columnMask(lo, hi);
                            while (m != 0) : (m &= m - 1) {
                                const cy = sy * 16 + @ctz(m);
                                if (cx == x and cy == y and cz == z) continue;
                                const c = cells.list[(column << 4) | @ctz(m)];
                                for (s.boxes.items[c.first..][0..c.count]) |b| sink.add(b, .{ cx, cy, cz });
                            }
                        }
                    }
                }
            }
        }
    }

    fn getOrCreate(self: *Region, key: u64) Error!*Section {
        const gop = try self.sections.getOrPut(self.allocator, key);
        if (gop.found_existing) return gop.value_ptr.*;
        if (self.sections.count() > self.max_sections) {
            self.sections.removeByPtr(gop.key_ptr);
            return error.RegionFull;
        }
        const s = self.allocator.create(Section) catch |e| {
            self.sections.removeByPtr(gop.key_ptr);
            return e;
        };
        s.* = .{};
        gop.value_ptr.* = s;
        const sy = keyPos(key).y;
        self.y_lo = @min(self.y_lo, sy);
        self.y_hi = @max(self.y_hi, sy);
        return s;
    }

    const Shape = struct { len: usize, info: Info };

    /// A box cut to the cells around its own, null when nothing of it is left there.
    fn cut(pos: [3]i64, b: Box) ?Box {
        var r = b;
        inline for (0..3) |a| {
            const lo: f64 = @floatFromInt(pos[a]);
            r.min[a] = @max(b.min[a], lo - 1);
            r.max[a] = @min(b.max[a], lo + 2);
            if (r.min[a] > r.max[a]) return null;
        }
        return r;
    }

    /// How many boxes of a cell survive cut(), and whether the cell overflows.
    /// That is read off the boxes, not taken from the caller.
    fn shape(pos: [3]i64, info: Info, boxes: []const Box) Error!Shape {
        if (info == .unknown) return error.InvalidInfo;
        if (info == .cube or info == .none) return if (boxes.len == 0) .{ .len = 0, .info = info } else error.InvalidInfo;
        if (boxes.len > max_boxes_per_cell) return error.TooManyBoxes;
        var n: usize = 0;
        var overflows = false;
        for (boxes) |b| {
            if (!b.isValid()) return error.InvalidBox;
            const kept = cut(pos, b) orelse continue;
            n += 1;
            inline for (0..3) |a| {
                const lo: f64 = @floatFromInt(pos[a]);
                if (kept.min[a] < lo or kept.max[a] > lo + 1) overflows = true;
            }
        }
        return .{ .len = n, .info = if (overflows) .may_overflow else .custom };
    }

    /// `out` holds exactly the boxes shape() counted.
    fn place(pos: [3]i64, boxes: []const Box, out: []Box) void {
        var n: usize = 0;
        for (boxes) |b| {
            const kept = cut(pos, b) orelse continue;
            out[n] = kept;
            n += 1;
        }
    }

    pub fn setCell(self: *Region, x: i64, y: i64, z: i64, wanted: Info, boxes: []const Box) Error!void {
        const loc = locate(x, y, z) orelse return error.OutOfRange;
        const pos = [3]i64{ x, y, z };
        const sh = try shape(pos, wanted, boxes);
        const info = sh.info;
        if (self.frozen) return error.Frozen;
        const s = try self.getOrCreate(loc.key);
        if (s.cells == null and s.uniform == info) {
            self.version +%= 1;
            return;
        }
        const cells = try s.expand(self.allocator);
        const cell = &cells.list[loc.local];
        if (sh.len <= cell.count) {
            place(pos, boxes, s.boxes.items[cell.first..][0..sh.len]);
            s.live -= cell.count - @as(u32, @intCast(sh.len));
            if (sh.len == 0) cell.first = 0;
        } else {
            if (s.boxes.items.len + sh.len > max_boxes_per_section) {
                s.compact();
                if (s.boxes.items.len + sh.len > max_boxes_per_section) return error.TooManyBoxes;
            }
            const first: u16 = @intCast(s.boxes.items.len);
            place(pos, boxes, try s.boxes.addManyAsSlice(self.allocator, sh.len));
            s.live += @as(u32, @intCast(sh.len)) - cell.count;
            cell.first = first;
        }
        cell.count = @intCast(sh.len);
        s.retag(loc.local, info);
        self.version +%= 1;
        s.trim();
    }

    fn sectionInRange(sx: i32, sy: i32, sz: i32) bool {
        return inRange(@as(i64, sx) * 16, @as(i64, sy) * 16, @as(i64, sz) * 16) and inRange(@as(i64, sx) * 16 + 15, @as(i64, sy) * 16 + 15, @as(i64, sz) * 16 + 15);
    }

    /// `infos` is in localIndex() order. Every custom or overflowing cell needs an entry in `cell_boxes`,
    /// an empty one for a shape with no boxes, so forgotten geometry cannot turn into open space.
    pub fn setSection(self: *Region, sx: i32, sy: i32, sz: i32, infos: []const Info, cell_boxes: []const CellBoxes) Error!void {
        if (infos.len != section_cells) return error.InvalidInfo;
        if (!sectionInRange(sx, sy, sz)) return error.OutOfRange;
        var shaped: usize = 0;
        for (infos) |i| switch (i) {
            .unknown => return error.InvalidInfo,
            .custom, .may_overflow => shaped += 1,
            .cube, .none => {},
        };
        var total: usize = 0;
        for (cell_boxes) |cb| total += cb.boxes.len;
        if (self.frozen) return error.Frozen;

        var fresh = Section{ .unknown = 0 };
        errdefer if (fresh.cells) |c| self.allocator.destroy(c);
        errdefer fresh.boxes.deinit(self.allocator);
        if (shaped == 0 and std.mem.allEqual(Info, infos, infos[0])) {
            if (cell_boxes.len != 0) return error.InvalidInfo;
            fresh.uniform = infos[0];
        } else {
            const cells = try self.allocator.create(Cells);
            fresh.cells = cells;
            cells.over = Cells.none_set;
            cells.hole = Cells.none_set;
            cells.near = Cells.none_set;
            // Shaped cells start out contained, their boxes decide below.
            for (&cells.list, infos) |*c, i| c.* = .{ .info = if (i == .may_overflow) .custom else i };
            try fresh.boxes.ensureTotalCapacity(self.allocator, @min(total, max_boxes_per_section));
            var seen: std.StaticBitSet(section_cells) = .empty;
            for (cell_boxes) |cb| {
                const c = &cells.list[cb.index];
                if (c.info != .custom) return error.InvalidInfo;
                if (seen.isSet(cb.index)) return error.DuplicateCell;
                seen.set(cb.index);
                const pos = [3]i64{ @as(i64, sx) * 16 + (cb.index >> 8), @as(i64, sy) * 16 + (cb.index & 15), @as(i64, sz) * 16 + ((cb.index >> 4) & 15) };
                const sh = try shape(pos, .custom, cb.boxes);
                if (fresh.boxes.items.len + sh.len > max_boxes_per_section) return error.TooManyBoxes;
                c.first = @intCast(fresh.boxes.items.len);
                c.count = @intCast(sh.len);
                place(pos, cb.boxes, fresh.boxes.addManyAsSliceAssumeCapacity(sh.len));
                fresh.retag(cb.index, sh.info);
            }
            if (seen.count() != shaped) return error.MissingBoxes;
            fresh.live = @intCast(fresh.boxes.items.len);
        }
        const s = try self.getOrCreate(sectionKey(sx, sy, sz));
        s.replace(self.allocator, fresh);
        self.version +%= 1;
    }

    /// Replaces a section with box-less cells. Unknown, custom and overflowing cells stay unknown until setCell() fills them.
    pub fn setSectionInfos(self: *Region, sx: i32, sy: i32, sz: i32, infos: *const [section_cells]Info) Error!void {
        if (!sectionInRange(sx, sy, sz)) return error.OutOfRange;
        if (self.frozen) return error.Frozen;
        var fresh = Section{ .unknown = 0 };
        errdefer if (fresh.cells) |c| self.allocator.destroy(c);
        if ((infos[0] == .none or infos[0] == .cube) and std.mem.allEqual(Info, infos, infos[0])) {
            fresh.uniform = infos[0];
        } else {
            const cells = try self.allocator.create(Cells);
            fresh.cells = cells;
            cells.over = Cells.none_set;
            cells.hole = Cells.none_set;
            for (&cells.list, infos, 0..) |*c, i, at| {
                const boxless = i == .none or i == .cube;
                c.* = .{ .info = if (boxless) i else .unknown };
                fresh.unknown += @intFromBool(!boxless);
                if (!boxless) cells.hole[at >> 4] |= @as(u16, 1) << @intCast(at & 15);
            }
            cells.markAll();
        }
        const s = try self.getOrCreate(sectionKey(sx, sy, sz));
        s.replace(self.allocator, fresh);
        self.version +%= 1;
    }

    /// Appends the indexes of unknown cells. False when the section is not stored at all.
    pub fn unknownCells(self: *const Region, sx: i32, sy: i32, sz: i32, out: *std.ArrayList(u16), allocator: Allocator) Error!bool {
        const s = self.sections.get(sectionKey(sx, sy, sz)) orelse return false;
        if (s.unknown == 0) return true;
        try out.ensureUnusedCapacity(allocator, s.unknown);
        for (0..section_cells) |i| {
            if (s.cell(@intCast(i)).info == .unknown) out.appendAssumeCapacity(@intCast(i));
        }
        return true;
    }

    /// `info` must be none or cube.
    pub fn fillBox(self: *Region, min: [3]i64, max: [3]i64, info: Info) Error!void {
        if (info != .none and info != .cube) return error.InvalidInfo;
        if (!inRange(min[0], min[1], min[2]) or !inRange(max[0], max[1], max[2])) return error.OutOfRange;
        var cells: u128 = 1;
        for (0..3) |a| {
            if (max[a] < min[a]) return error.InvalidBox;
            cells *= @intCast(max[a] - min[a] + 1);
        }
        if (cells > 1 << 26) return error.RegionTooLarge;
        if (self.frozen) return error.Frozen;

        // Everything that can fail happens before the first cell changes, so a failed fill changes nothing.
        var missing: usize = 0;
        var it = SectionWalk.init(min, max);
        while (it.next()) |p| missing += @intFromBool(!self.sections.contains(sectionKey(p[0], p[1], p[2])));
        if (self.sections.count() + missing > self.max_sections) return error.RegionFull;
        it = SectionWalk.init(min, max);
        while (it.next()) |p| {
            const s = try self.getOrCreate(sectionKey(p[0], p[1], p[2]));
            if (!it.whole and !(s.cells == null and s.uniform == info)) _ = try s.expand(self.allocator);
        }

        self.version +%= 1;
        it = SectionWalk.init(min, max);
        while (it.next()) |p| {
            const s = self.sections.get(sectionKey(p[0], p[1], p[2])).?;
            if (it.whole) {
                s.replace(self.allocator, .{ .uniform = info, .unknown = 0 });
                continue;
            }
            const grid = s.cells orelse continue;
            const lo: usize = @intCast(it.lo[1] & 15);
            const hi: usize = @intCast(it.hi[1] & 15);
            var x = it.lo[0];
            while (x <= it.hi[0]) : (x += 1) {
                var z = it.lo[2];
                while (z <= it.hi[2]) : (z += 1) {
                    const column: usize = @intCast(((x & 15) << 4) | (z & 15));
                    for (grid.list[(column << 4) | lo .. ((column << 4) | hi) + 1]) |*c| {
                        s.unknown -= @intFromBool(c.info == .unknown);
                        s.overflow -= @intFromBool(c.info == .may_overflow);
                        s.live -= c.count;
                        c.* = .{ .info = info };
                    }
                    grid.hole[column] &= ~columnMask(lo, hi);
                    grid.over[column] &= ~columnMask(lo, hi);
                }
            }
            grid.markAll();
            s.trim();
        }
    }

    /// Never fails: when the section cannot be expanded it is dropped whole, which forgets the cell too.
    fn forget(self: *Region, x: i64, y: i64, z: i64) void {
        const loc = locate(x, y, z) orelse return;
        const s = self.sections.get(loc.key) orelse return;
        if (s.cells == null and s.uniform == null) return;
        _ = s.expand(self.allocator) catch {
            _ = self.sections.remove(loc.key);
            s.free(self.allocator);
            return;
        };
        s.drop(loc.local);
        s.retag(loc.local, .unknown);
    }

    pub fn invalidateCell(self: *Region, x: i64, y: i64, z: i64) Error!void {
        try self.mutate();
        self.forget(x, y, z);
    }

    /// Also drops the six neighbours, like World's cache invalidation.
    pub fn invalidateBlock(self: *Region, x: i64, y: i64, z: i64) Error!void {
        try self.mutate();
        self.forget(x, y, z);
        for (geom.facing.offsets) |o| {
            const nx = std.math.add(i64, x, o[0]) catch continue;
            const ny = std.math.add(i64, y, o[1]) catch continue;
            const nz = std.math.add(i64, z, o[2]) catch continue;
            self.forget(nx, ny, nz);
        }
    }

    pub fn invalidateSection(self: *Region, sx: i32, sy: i32, sz: i32) Error!void {
        try self.mutate();
        if (!inRange(@as(i64, sx) * 16, @as(i64, sy) * 16, @as(i64, sz) * 16)) return;
        if (self.sections.fetchRemove(sectionKey(sx, sy, sz))) |kv| kv.value.free(self.allocator);
    }

    pub fn invalidateChunk(self: *Region, chunk_x: i32, chunk_z: i32) Error!void {
        try self.mutate();
        if (self.sections.count() == 0 or !inRange(@as(i64, chunk_x) * 16, 0, @as(i64, chunk_z) * 16)) return;
        if (@as(i64, self.y_hi) - self.y_lo < self.sections.count()) {
            var sy = self.y_lo;
            while (sy <= self.y_hi) : (sy += 1) {
                if (self.sections.fetchRemove(sectionKey(chunk_x, sy, chunk_z))) |kv| kv.value.free(self.allocator);
            }
            return;
        }
        // Few sections spread over a tall range, cheaper to look at each one.
        var it = self.sections.iterator();
        while (it.next()) |e| {
            const p = keyPos(e.key_ptr.*);
            if (p.x != chunk_x or p.z != chunk_z) continue;
            e.value_ptr.*.free(self.allocator);
            self.sections.removeByPtr(e.key_ptr);
        }
    }

    pub fn invalidateAll(self: *Region) Error!void {
        try self.mutate();
        var it = self.sections.valueIterator();
        while (it.next()) |s| s.*.free(self.allocator);
        self.sections.clearRetainingCapacity();
        self.y_lo = std.math.maxInt(i32);
        self.y_hi = std.math.minInt(i32);
    }

    fn cellRange(query: Box) Error![2][3]i64 {
        if (!query.isValid()) return error.InvalidBox;
        const limit = [3]f64{ horizontal_limit, vertical_limit, horizontal_limit };
        var r: [2][3]i64 = undefined;
        inline for (0..3) |a| {
            const lo = @floor(query.min[a]);
            const hi = @floor(query.max[a]);
            if (!(@abs(lo) < limit[a] and @abs(hi) < limit[a])) return error.OutOfRange;
            r[0][a] = @intFromFloat(lo);
            r[1][a] = @intFromFloat(hi);
        }
        // Neighbours of the corner cells must also be addressable for overflow boxes.
        if (!inRange(r[0][0] -| 1, r[0][1] -| 1, r[0][2] -| 1) or !inRange(r[1][0] +| 1, r[1][1] +| 1, r[1][2] +| 1)) return error.OutOfRange;
        var sections: u64 = 1;
        inline for (0..3) |a| sections *= @intCast(((r[1][a] + 1) >> 4) - ((r[0][a] - 1) >> 4) + 1);
        if (sections > max_query_sections) return error.RegionTooLarge;
        return r;
    }

    /// Appends flat x, y, z triples.
    pub fn missingSections(self: *const Region, query: Box, out: *std.ArrayList(i64), allocator: Allocator) Error!void {
        const r = try cellRange(query);
        var sx = (r[0][0] - 1) >> 4;
        while (sx <= (r[1][0] + 1) >> 4) : (sx += 1) {
            var sz = (r[0][2] - 1) >> 4;
            while (sz <= (r[1][2] + 1) >> 4) : (sz += 1) {
                var sy = (r[0][1] - 1) >> 4;
                while (sy <= (r[1][1] + 1) >> 4) : (sy += 1) {
                    const s = self.sections.get(sectionKey(@intCast(sx), @intCast(sy), @intCast(sz)));
                    if (s == null or s.?.unknown > 0) try out.appendSlice(allocator, &.{ sx, sy, sz });
                }
            }
        }
    }

    /// Every box touching `query` once: those of the cells it covers, plus the ones reaching in from the ring
    /// of cells around them. All of those cells have to be known.
    pub fn collisionBoxes(self: *const Region, query: Box, sink: anytype) !void {
        const r = try cellRange(query);
        var lk = Lookup{};
        var scratch: Box = undefined;
        const y_end = r[1][1] + 1;
        var z = r[0][2] - 1;
        while (z <= r[1][2] + 1) : (z += 1) {
            const z_in = z >= r[0][2] and z <= r[1][2];
            var x = r[0][0] - 1;
            while (x <= r[1][0] + 1) : (x += 1) {
                const covered = z_in and x >= r[0][0] and x <= r[1][0];
                const column: usize = @intCast(((x & 15) << 4) | (z & 15));
                // One stretch of the column per section it passes through.
                var y = r[0][1] - 1;
                var top = y;
                while (y <= y_end) : (y = top + 1) {
                    top = @min(y_end, y | 15);
                    const s = self.sectionFor(&lk, sectionKey(@intCast(x >> 4), @intCast(y >> 4), @intCast(z >> 4))) orelse return error.UnknownCell;
                    const cells = s.cells orelse {
                        if ((s.uniform orelse return error.UnknownCell) != .cube or !covered) continue;
                        var cy = @max(y, r[0][1]);
                        while (cy <= @min(top, r[1][1])) : (cy += 1) {
                            const b = Box.unitAt(x, cy, z);
                            if (b.intersects(query, geom.default_epsilon)) try sink.add(b);
                        }
                        continue;
                    };
                    const lo: usize = @intCast(y & 15);
                    const hi: usize = @intCast(top & 15);
                    if (cells.hole[column] & columnMask(lo, hi) != 0) return error.UnknownCell;
                    if (!covered) {
                        // Ring columns only matter where a cell overflows.
                        var m = cells.over[column] & columnMask(lo, hi);
                        while (m != 0) : (m &= m - 1) {
                            const c = cells.list[(column << 4) | @ctz(m)];
                            for (s.boxes.items[c.first..][0..c.count]) |b| {
                                if (b.intersects(query, geom.default_epsilon)) try sink.add(b);
                            }
                        }
                        continue;
                    }
                    var cy = y;
                    while (cy <= top) : (cy += 1) {
                        const c = cells.list[(column << 4) | @as(usize, @intCast(cy & 15))];
                        if ((cy < r[0][1] or cy > r[1][1]) and c.info != .may_overflow) continue;
                        for (s.boxesOf(c, x, cy, z, &scratch)) |b| {
                            if (b.intersects(query, geom.default_epsilon)) try sink.add(b);
                        }
                    }
                }
            }
        }
    }

    pub fn isComplete(self: *const Region, query: Box) bool {
        var sink = CountSink{};
        self.collisionBoxes(query, &sink) catch return false;
        return true;
    }

    pub fn collides(self: *const Region, query: Box) Error!bool {
        var sink = AnySink{};
        self.collisionBoxes(query, &sink) catch |e| return switch (e) {
            error.Found => true,
            else => |other| other,
        };
        return false;
    }
};

/// Sections overlapping an inclusive cell box, with the part of the box inside each.
const SectionWalk = struct {
    min: [3]i64,
    max: [3]i64,
    at: [3]i64,
    lo: [3]i64 = undefined,
    hi: [3]i64 = undefined,
    whole: bool = false,

    fn init(min: [3]i64, max: [3]i64) SectionWalk {
        return .{ .min = min, .max = max, .at = .{ min[0] >> 4, min[1] >> 4, min[2] >> 4 } };
    }

    fn next(self: *SectionWalk) ?[3]i32 {
        if (self.at[0] > self.max[0] >> 4) return null;
        const p = self.at;
        self.whole = true;
        for (0..3) |a| {
            self.lo[a] = @max(self.min[a], p[a] * 16);
            self.hi[a] = @min(self.max[a], p[a] * 16 + 15);
            if (self.hi[a] - self.lo[a] != 15) self.whole = false;
        }
        self.at[1] += 1;
        if (self.at[1] > self.max[1] >> 4) {
            self.at[1] = self.min[1] >> 4;
            self.at[2] += 1;
            if (self.at[2] > self.max[2] >> 4) {
                self.at[2] = self.min[2] >> 4;
                self.at[0] += 1;
            }
        }
        return .{ @intCast(p[0]), @intCast(p[1]), @intCast(p[2]) };
    }
};

pub const CountSink = struct {
    count: usize = 0,
    pub fn add(self: *CountSink, _: Box) Error!void {
        self.count += 1;
    }
};

const AnySink = struct {
    pub fn add(_: *AnySink, _: Box) (Error || error{Found})!void {
        return error.Found;
    }
};

pub const ListSink = struct {
    list: *std.ArrayList(Box),
    allocator: Allocator,
    pub fn add(self: *ListSink, b: Box) Error!void {
        if (self.list.items.len >= max_query_boxes) return error.TooManyBoxes;
        try self.list.append(self.allocator, b);
    }
};

pub fn collectBoxes(region: *const Region, allocator: Allocator, query: Box, list: *std.ArrayList(Box)) Error!void {
    list.clearRetainingCapacity();
    var sink = ListSink{ .list = list, .allocator = allocator };
    try region.collisionBoxes(query, &sink);
}

/// Expands a PalettedBlockArray word array through `palette`, cells in localIndex() order.
pub fn decodePalette(bits_per_block: i64, words: []const u8, palette: []const Info, out: *[section_cells]Info) error{InvalidPalette}!void {
    var indexes: [section_cells]u16 = undefined;
    try @import("palette.zig").decode(bits_per_block, words, palette.len, &indexes);
    for (out, indexes) |*o, i| o.* = palette[i];
}

/// Covers every query move() may make, for prefetching.
pub fn queryBox(bb: Box, wanted: Vec, step_height: f64) Box {
    var q = bb.addCoord(wanted);
    if (step_height > 0) q = q.union_(bb.addCoord(.{ wanted[0], step_height, wanted[2] }));
    return q;
}

pub const MoveResult = struct {
    d: Vec,
    bb: Box,
    collided: [3]bool,
    horizontal: bool,
    vertical: bool,
    on_ground: bool,
    stepped: bool,
};

fn clipAxis(comptime axis: usize, list: []const Box, moving: Box, d: f64) f64 {
    var r = d;
    for (list) |b| r = b.calculateOffset(axis, moving, r);
    return r;
}

fn along(comptime axis: usize, d: f64) Vec {
    var v: Vec = .{ 0, 0, 0 };
    v[axis] = d;
    return v;
}

/// Entity::move() without keepMovement.
pub fn move(region: *const Region, allocator: Allocator, bb: Box, wanted: Vec, step_height: f64, on_ground: bool) Error!MoveResult {
    if (!bb.isValid()) return error.InvalidBox;
    // One allocation covers nearly every move, instead of growing box by box.
    var list = try std.ArrayList(Box).initCapacity(allocator, 32);
    defer list.deinit(allocator);

    var dx = wanted[0];
    var dy = wanted[1];
    var dz = wanted[2];

    var move_bb = bb;
    try collectBoxes(region, allocator, move_bb.addCoord(wanted), &list);
    dy = clipAxis(1, list.items, move_bb, dy);
    move_bb = move_bb.offset(along(1, dy));
    const falling = on_ground or (dy != wanted[1] and wanted[1] < 0);
    dx = clipAxis(0, list.items, move_bb, dx);
    move_bb = move_bb.offset(along(0, dx));
    dz = clipAxis(2, list.items, move_bb, dz);
    move_bb = move_bb.offset(along(2, dz));

    var stepped = false;
    if (step_height > 0 and falling and (wanted[0] != dx or wanted[2] != dz)) {
        const cx = dx;
        const cy = dy;
        const cz = dz;
        dx = wanted[0];
        dy = step_height;
        dz = wanted[2];

        var step_bb = bb;
        try collectBoxes(region, allocator, step_bb.addCoord(.{ dx, dy, dz }), &list);
        dy = clipAxis(1, list.items, step_bb, dy);
        step_bb = step_bb.offset(along(1, dy));
        dx = clipAxis(0, list.items, step_bb, dx);
        step_bb = step_bb.offset(along(0, dx));
        dz = clipAxis(2, list.items, step_bb, dz);
        step_bb = step_bb.offset(along(2, dz));

        const reverse = clipAxis(1, list.items, step_bb, num.negf(dy));
        dy += reverse;
        step_bb = step_bb.offset(along(1, reverse));

        if ((pow(cx, 2) + pow(cz, 2)) >= (pow(dx, 2) + pow(dz, 2))) {
            dx = cx;
            dy = cy;
            dz = cz;
        } else {
            move_bb = step_bb;
            stepped = true;
        }
    }

    const collided = [3]bool{ wanted[0] != dx, wanted[1] != dy, wanted[2] != dz };
    return .{
        .d = .{ dx, dy, dz },
        .bb = move_bb,
        .collided = collided,
        .horizontal = collided[0] or collided[2],
        .vertical = collided[1],
        .on_ground = collided[1] and wanted[1] < 0,
        .stepped = stepped,
    };
}

pub const SweepHit = struct {
    time: f64,
    face: i64,
    box: Box,
    index: usize,
};

pub fn sweepList(bb: Box, d: Vec, boxes: []const Box) ?SweepHit {
    var best: ?SweepHit = null;
    for (boxes, 0..) |b, i| {
        if (geom.sweep(bb, d, b)) |s| {
            if (best == null or s.time < best.?.time) best = .{ .time = s.time, .face = s.face, .box = b, .index = i };
        }
    }
    return best;
}

pub fn sweep(region: *const Region, allocator: Allocator, bb: Box, d: Vec) Error!?SweepHit {
    if (!bb.isValid()) return error.InvalidBox;
    var list: std.ArrayList(Box) = .empty;
    defer list.deinit(allocator);
    try collectBoxes(region, allocator, bb.addCoord(d), &list);
    return sweepList(bb, d, list.items);
}

const testing = std.testing;

fn flatGround(allocator: Allocator) !Region {
    var r = Region.init(allocator, 1024);
    errdefer r.deinit();
    try r.fillBox(.{ -20, -20, -20 }, .{ 20, 20, 20 }, .none);
    try r.fillBox(.{ -20, 0, -20 }, .{ 20, 0, 20 }, .cube);
    return r;
}

fn player(x: f64, y: f64, z: f64) Box {
    return Box.init(x - 0.3, y, z - 0.3, x + 0.3, y + 1.8, z + 0.3);
}

test "falling onto a floor lands exactly on top" {
    var r = try flatGround(testing.allocator);
    defer r.deinit();
    const res = try move(&r, testing.allocator, player(0.5, 1.2, 0.5), .{ 0, -0.5, 0 }, 0.6, false);
    try testing.expectEqual(@as(f64, 1.0), res.bb.min[1]);
    try testing.expect(res.on_ground and res.vertical and !res.horizontal);
    const top: f64 = 1.0;
    const start: f64 = 1.2;
    try testing.expectEqual(top - start, res.d[1]);
}

test "fast fall does not tunnel through the floor" {
    var r = try flatGround(testing.allocator);
    defer r.deinit();
    const res = try move(&r, testing.allocator, player(0.5, 5.0, 0.5), .{ 0, -5.5, 0 }, 0.0, false);
    try testing.expectEqual(@as(f64, 1.0), res.bb.min[1]);
}

test "step height climbs a slab but not a full block" {
    var r = try flatGround(testing.allocator);
    defer r.deinit();
    try r.setCell(1, 1, 0, .custom, &.{Box.init(1, 1, 0, 2, 1.5, 1)});
    const res = try move(&r, testing.allocator, player(0.5, 1.0, 0.5), .{ 0.4, 0, 0 }, 0.6, true);
    try testing.expect(res.stepped);
    try testing.expectEqual(@as(f64, 1.5), res.bb.min[1]);

    try r.setCell(1, 1, 0, .cube, &.{});
    const blocked = try move(&r, testing.allocator, player(0.5, 1.0, 0.5), .{ 0.4, 0, 0 }, 0.6, true);
    try testing.expect(!blocked.stepped and blocked.horizontal);
    try testing.expectEqual(@as(f64, 1.0), blocked.bb.max[0]);
}

test "unknown cells are errors, not air" {
    var r = Region.init(testing.allocator, 64);
    defer r.deinit();
    try testing.expectError(error.UnknownCell, move(&r, testing.allocator, player(1.5, 1, 1.5), .{ 0, -0.5, 0 }, 0, false));
    try r.fillBox(.{ -16, -16, -16 }, .{ 15, 15, 15 }, .none);
    try r.invalidateBlock(1, 0, 1);
    try testing.expectError(error.UnknownCell, move(&r, testing.allocator, player(1.5, 1, 1.5), .{ 0, -0.5, 0 }, 0, false));
    try testing.expectError(error.UnknownCell, move(&r, testing.allocator, player(1.5, 1, 1.5), .{ 0, -30, 0 }, 0, false));
}

test "missing sections cover the query and its neighbours" {
    var r = Region.init(testing.allocator, 64);
    defer r.deinit();
    var out: std.ArrayList(i64) = .empty;
    defer out.deinit(testing.allocator);
    try r.missingSections(Box.init(1, 1, 1, 2, 2, 2), &out, testing.allocator);
    try testing.expectEqual(@as(usize, 3), out.items.len);
    out.clearRetainingCapacity();
    // cell 0 needs its neighbour at -1, which lives in the next section down on every axis
    try r.missingSections(Box.init(0.5, 0.5, 0.5, 2, 2, 2), &out, testing.allocator);
    try testing.expectEqual(@as(usize, 8 * 3), out.items.len);
    try r.fillBox(.{ -16, -16, -16 }, .{ 15, 15, 15 }, .none);
    out.clearRetainingCapacity();
    try r.missingSections(Box.init(1, 1, 1, 2, 2, 2), &out, testing.allocator);
    try testing.expectEqual(@as(usize, 0), out.items.len);
    try r.invalidateCell(0, 0, 0);
    out.clearRetainingCapacity();
    try r.missingSections(Box.init(1, 1, 1, 2, 2, 2), &out, testing.allocator);
    try testing.expectEqualSlices(i64, &.{ 0, 0, 0 }, out.items);
}

test "partial sections report their unknown cells" {
    var r = Region.init(testing.allocator, 64);
    defer r.deinit();
    var out: std.ArrayList(u16) = .empty;
    defer out.deinit(testing.allocator);
    try testing.expect(!try r.unknownCells(0, 0, 0, &out, testing.allocator));

    var infos: [section_cells]Info = @splat(.none);
    infos[localIndex(1, 2, 3)] = .unknown;
    infos[localIndex(15, 15, 15)] = .unknown;
    try r.setSectionInfos(0, 0, 0, &infos);
    try testing.expect(try r.unknownCells(0, 0, 0, &out, testing.allocator));
    try testing.expectEqualSlices(u16, &.{ localIndex(1, 2, 3), localIndex(15, 15, 15) }, out.items);

    try r.setCell(1, 2, 3, .custom, &.{Box.init(1, 2, 3, 2, 2.5, 4)});
    try r.setCell(15, 15, 15, .cube, &.{});
    out.clearRetainingCapacity();
    try testing.expect(try r.unknownCells(0, 0, 0, &out, testing.allocator));
    try testing.expectEqual(@as(usize, 0), out.items.len);

    try r.invalidateBlock(5, 5, 5);
    out.clearRetainingCapacity();
    _ = try r.unknownCells(0, 0, 0, &out, testing.allocator);
    try testing.expectEqual(@as(usize, 7), out.items.len);

    infos = @splat(.cube);
    try r.setSectionInfos(0, 1, 0, &infos);
    out.clearRetainingCapacity();
    try testing.expect(try r.unknownCells(0, 1, 0, &out, testing.allocator));
    try testing.expectEqual(@as(usize, 0), out.items.len);
    var lk = Lookup{};
    try testing.expectEqual(Info.cube, try r.cellInfo(&lk, 0, 16, 0));
    try testing.expectError(error.OutOfRange, r.setSectionInfos(1 << 22, 0, 0, &infos));
}

test "fence overflow boxes come from neighbouring cells" {
    var r = try flatGround(testing.allocator);
    defer r.deinit();
    try r.setCell(0, 1, 0, .may_overflow, &.{Box.init(0.375, 1, 0.375, 0.625, 2.5, 0.625)});
    var list: std.ArrayList(Box) = .empty;
    defer list.deinit(testing.allocator);
    try collectBoxes(&r, testing.allocator, Box.init(0.4, 2.1, 0.4, 0.6, 2.3, 0.6), &list);
    try testing.expectEqual(@as(usize, 1), list.items.len);
}

test "sections and coordinates are bounded" {
    var r = Region.init(testing.allocator, 2);
    defer r.deinit();
    try r.setCell(0, 0, 0, .none, &.{});
    try r.setCell(16, 0, 0, .none, &.{});
    try testing.expectError(error.RegionFull, r.setCell(32, 0, 0, .none, &.{}));
    try testing.expectEqual(@as(usize, 2), r.sectionCount());
    try testing.expectError(error.OutOfRange, r.setCell(1 << 40, 0, 0, .none, &.{}));
    try testing.expectError(error.InvalidBox, r.setCell(0, 0, 0, .custom, &.{Box.init(1, 0, 0, 0, 1, 1)}));
    try testing.expectError(error.InvalidBox, r.setCell(0, 0, 0, .custom, &.{Box.init(std.math.nan(f64), 0, 0, 1, 1, 1)}));
    try testing.expectError(error.RegionTooLarge, r.fillBox(.{ 0, 0, 0 }, .{ 10000, 10000, 10000 }, .none));
    r.frozen = true;
    try testing.expectError(error.Frozen, r.setCell(0, 0, 0, .none, &.{}));
}

test "section keys round trip" {
    for ([_]SectionPos{ .{ .x = 0, .y = 0, .z = 0 }, .{ .x = -1, .y = -4, .z = 1875000 }, .{ .x = -2097151, .y = 524287, .z = -2097151 } }) |p| {
        try testing.expectEqual(p, keyPos(sectionKey(p.x, p.y, p.z)));
    }
}

test "repeated cell updates do not grow storage without bound" {
    var r = Region.init(testing.allocator, 4);
    defer r.deinit();
    const a = [_]Box{ Box.init(0, 0, 0, 1, 0.5, 1), Box.init(0, 0.5, 0, 0.5, 1, 0.5) };
    for (0..20000) |i| {
        const n: usize = if (i % 2 == 0) 1 else 2;
        const x: f64 = @floatFromInt(i % 4);
        const moved = [_]Box{ a[0].offset(.{ x, 0, 0 }), a[1].offset(.{ x, 0, 0 }) };
        try r.setCell(@intCast(i % 4), 0, 0, .custom, moved[0..n]);
    }
    try testing.expect(r.sections.get(sectionKey(0, 0, 0)).?.boxes.items.len <= 1024);
}

test "compaction keeps every cell's own boxes" {
    var r = Region.init(testing.allocator, 4);
    defer r.deinit();
    const a = Box.init(2, 0, 0, 3, 0.5, 1);
    const b = Box.init(1, 0, 0, 2, 0.25, 1);
    try r.setCell(2, 0, 0, .custom, &.{ a, a });
    try r.setCell(1, 0, 0, .custom, &.{ b, b });
    try r.setCell(3, 0, 0, .custom, &.{a});
    try r.setCell(3, 0, 0, .custom, &.{});
    var copy = try r.clone(testing.allocator);
    defer copy.deinit();
    var lk = Lookup{};
    var scratch: Box = undefined;
    try testing.expectEqualSlices(Box, &.{ a, a }, try copy.ownBoxes(&lk, 2, 0, 0, &scratch));
    try testing.expectEqualSlices(Box, &.{ b, b }, try copy.ownBoxes(&lk, 1, 0, 0, &scratch));
    try testing.expectEqual(@as(usize, 0), (try copy.ownBoxes(&lk, 3, 0, 0, &scratch)).len);
    try copy.setCell(3, 0, 0, .custom, &.{});
}

test "huge or out of range coordinates are rejected" {
    var r = Region.init(testing.allocator, 4);
    defer r.deinit();
    var list: std.ArrayList(Box) = .empty;
    defer list.deinit(testing.allocator);
    try testing.expectError(error.OutOfRange, collectBoxes(&r, testing.allocator, Box.init(1000, 0, 0, 0x1p64, 1, 1), &list));
    try testing.expectError(error.OutOfRange, r.fillBox(.{ std.math.minInt(i64), 0, 0 }, .{ std.math.maxInt(i64), 0, 0 }, .none));
    try r.setCell(16, 0, 0, .none, &.{});
    try r.invalidateSection(0, 0, 1 << 22);
    try testing.expectEqual(@as(usize, 1), r.sectionCount());
}

test "a fill that runs out of sections changes nothing" {
    var r = Region.init(testing.allocator, 1);
    defer r.deinit();
    try r.fillBox(.{ 0, 0, 0 }, .{ 15, 15, 15 }, .none);
    const v = r.version;
    try testing.expectError(error.RegionFull, r.fillBox(.{ 0, 0, 0 }, .{ 31, 15, 15 }, .cube));
    try testing.expectEqual(v, r.version);
    var lk = Lookup{};
    try testing.expectEqual(Info.none, try r.cellInfo(&lk, 3, 3, 3));
}

test "a fill that runs out of memory changes nothing" {
    var failing = std.testing.FailingAllocator.init(testing.allocator, .{});
    var r = Region.init(failing.allocator(), 64);
    defer r.deinit();
    try r.fillBox(.{ 0, 0, 0 }, .{ 47, 15, 15 }, .none);
    try r.setCell(20, 1, 1, .custom, &.{Box.init(20, 1, 1, 21, 1.5, 2)});
    const v = r.version;
    // The first two sections are rewritten whole, the third has to be expanded and cannot be.
    failing.fail_index = failing.alloc_index;
    try testing.expectError(error.OutOfMemory, r.fillBox(.{ 0, 0, 0 }, .{ 40, 15, 15 }, .cube));
    try testing.expectEqual(v, r.version);
    var lk = Lookup{};
    try testing.expectEqual(Info.none, try r.cellInfo(&lk, 3, 3, 3));
    try testing.expectEqual(Info.custom, try r.cellInfo(&lk, 20, 1, 1));
}

test "overflow is read off the boxes and reaches diagonal neighbours" {
    var r = try flatGround(testing.allocator);
    defer r.deinit();
    var lk = Lookup{};
    // Claimed overflowing but stays inside its cell.
    try r.setCell(3, 1, 3, .may_overflow, &.{Box.init(3.25, 1, 3.25, 3.75, 2, 3.75)});
    try testing.expectEqual(Info.custom, try r.cellInfo(&lk, 3, 1, 3));
    // Claimed contained but leans out over two axes at once.
    try r.setCell(0, 1, 0, .custom, &.{Box.init(0.5, 1.5, 0.5, 1.5, 2.5, 1)});
    try testing.expectEqual(Info.may_overflow, try r.cellInfo(&lk, 0, 1, 0));
    var list: std.ArrayList(Box) = .empty;
    defer list.deinit(testing.allocator);
    try collectBoxes(&r, testing.allocator, Box.init(1.1, 2.1, 0.1, 1.4, 2.4, 0.9), &list);
    try testing.expectEqual(@as(usize, 1), list.items.len);
    const res = try move(&r, testing.allocator, Box.init(1.1, 2.6, 0.1, 1.4, 3, 0.9), .{ 0, -1, 0 }, 0, false);
    try testing.expectEqual(@as(f64, 2.5), res.bb.min[1]);
    // The cell itself and its ring are all it takes, each box shows up once.
    try collectBoxes(&r, testing.allocator, Box.init(0.1, 1.1, 0.1, 1.9, 2.9, 0.9), &list);
    try testing.expectEqual(@as(usize, 1), list.items.len);
}

test "boxes are cut to the cells around their own" {
    var r = try flatGround(testing.allocator);
    defer r.deinit();
    try r.setCell(0, 1, 0, .custom, &.{ Box.init(0, 1, 0, 1, 9, 1), Box.init(7, 1, 0, 8, 2, 1) });
    var lk = Lookup{};
    var scratch: Box = undefined;
    try testing.expectEqualSlices(Box, &.{Box.init(0, 1, 0, 1, 3, 1)}, try r.ownBoxes(&lk, 0, 1, 0, &scratch));
}

test "setSection wants boxes for every shaped cell, once" {
    var r = Region.init(testing.allocator, 8);
    defer r.deinit();
    var infos: [section_cells]Info = @splat(.none);
    infos[5] = .custom;
    infos[6] = .may_overflow;
    const one = [_]Box{Box.init(0, 5, 0, 1, 5.5, 1)};
    try testing.expectError(error.MissingBoxes, r.setSection(0, 0, 0, &infos, &.{}));
    try testing.expectError(error.MissingBoxes, r.setSection(0, 0, 0, &infos, &.{.{ .index = 5, .boxes = &one }}));
    try testing.expectError(error.DuplicateCell, r.setSection(0, 0, 0, &infos, &.{ .{ .index = 5, .boxes = &.{} }, .{ .index = 5, .boxes = &.{} }, .{ .index = 6, .boxes = &.{} } }));
    try testing.expectEqual(@as(usize, 0), r.sectionCount());
    // An empty list is how a shape with no boxes is spelled.
    try r.setSection(0, 0, 0, &infos, &.{ .{ .index = 5, .boxes = &one }, .{ .index = 6, .boxes = &.{} } });
    var lk = Lookup{};
    try testing.expectEqual(Info.custom, try r.cellInfo(&lk, 0, 6, 0));
    var copy: [section_cells]Info = infos;
    try r.setSectionInfos(0, 1, 0, &copy);
    try testing.expectError(error.UnknownCell, r.cellInfo(&lk, 0, 16 + 5, 0));
}

test "dropping a chunk finds its sections by height or by scan" {
    var r = Region.init(testing.allocator, 256);
    defer r.deinit();
    try r.fillBox(.{ 0, 0, 0 }, .{ 127, 47, 127 }, .none);
    try r.invalidateChunk(3, 4);
    try testing.expectEqual(@as(usize, 189), r.sectionCount());
    try r.invalidateAll();
    try r.invalidateChunk(3, 4);
    // Three sections half a million apart, where scanning them beats probing every height.
    try r.setCell(0, 0, 0, .cube, &.{});
    try r.setCell(0, 8000000, 0, .cube, &.{});
    try r.setCell(16, 0, 0, .cube, &.{});
    try r.invalidateChunk(0, 0);
    try testing.expectEqual(@as(usize, 1), r.sectionCount());
    try r.invalidateChunk(1 << 30, 0);
    try testing.expectEqual(@as(usize, 1), r.sectionCount());
}

test "invalidating keeps counters straight when a section cannot be expanded" {
    var failing = std.testing.FailingAllocator.init(testing.allocator, .{});
    var r = Region.init(failing.allocator(), 8);
    defer r.deinit();
    try r.fillBox(.{ 0, 0, 0 }, .{ 15, 15, 15 }, .cube);
    failing.fail_index = failing.alloc_index;
    try r.invalidateBlock(4, 4, 4);
    var lk = Lookup{};
    try testing.expectError(error.UnknownCell, r.cellInfo(&lk, 4, 4, 4));
}

test "setSection builds uniform and detailed sections" {
    var r = Region.init(testing.allocator, 8);
    defer r.deinit();
    var infos: [section_cells]Info = @splat(.none);
    try r.setSection(0, 0, 0, &infos, &.{});
    try testing.expect(r.sections.get(sectionKey(0, 0, 0)).?.cells == null);
    infos[localIndex(1, 2, 3)] = .custom;
    try r.setSection(0, 0, 0, &infos, &.{.{ .index = localIndex(1, 2, 3), .boxes = &.{Box.init(1, 2, 3, 2, 2.5, 4)} }});
    var lk = Lookup{};
    var scratch: Box = undefined;
    try testing.expectEqual(@as(usize, 1), (try r.ownBoxes(&lk, 1, 2, 3, &scratch)).len);
    try testing.expectError(error.InvalidInfo, r.setSection(0, 0, 0, &infos, &.{.{ .index = 0, .boxes = &.{Box.init(0, 0, 0, 1, 1, 1)} }}));
}

test "sweep catches thin walls at high speed" {
    var r = Region.init(testing.allocator, 64);
    defer r.deinit();
    try r.fillBox(.{ -16, -16, -16 }, .{ 47, 15, 15 }, .none);
    try r.setCell(30, 0, 0, .custom, &.{Box.init(30, 0, 0, 30.05, 1, 1)});
    const hit = (try sweep(&r, testing.allocator, Box.init(0.2, 0.2, 0.2, 0.8, 0.8, 0.8), .{ 38, 0, 0 })).?;
    try testing.expectEqual(geom.facing.west, hit.face);
    try testing.expect(hit.time > 0.76 and hit.time < 0.78);
}

/// Rebuilds every counter and mask of a section from its cells.
fn expectConsistent(s: *const Section) !void {
    const cells = s.cells orelse {
        try testing.expectEqual(@as(u16, if (s.uniform == null) section_cells else 0), s.unknown);
        try testing.expectEqual(@as(u16, 0), s.overflow);
        return;
    };
    var want: Cells = undefined;
    want.over = Cells.none_set;
    want.hole = Cells.none_set;
    var unknown: u16 = 0;
    var overflow: u16 = 0;
    var live: u32 = 0;
    for (cells.list, 0..) |c, i| {
        const bit = @as(u16, 1) << @intCast(i & 15);
        if (c.info == .unknown) want.hole[i >> 4] |= bit;
        if (c.info == .may_overflow) want.over[i >> 4] |= bit;
        unknown += @intFromBool(c.info == .unknown);
        overflow += @intFromBool(c.info == .may_overflow);
        live += c.count;
    }
    want.markAll();
    try testing.expectEqual(unknown, s.unknown);
    try testing.expectEqual(overflow, s.overflow);
    try testing.expectEqual(live, s.live);
    try testing.expectEqualSlices(u16, &want.hole, &cells.hole);
    try testing.expectEqualSlices(u16, &want.over, &cells.over);
    try testing.expectEqualSlices(u16, &want.near, &cells.near);
}

test "counters and masks follow the cells through every kind of write" {
    var prng = std.Random.DefaultPrng.init(3);
    const rand = prng.random();
    var r = Region.init(testing.allocator, 32);
    defer r.deinit();
    for (0..6000) |step| {
        const x = rand.intRangeAtMost(i64, -3, 34);
        const y = rand.intRangeAtMost(i64, -3, 18);
        const z = rand.intRangeAtMost(i64, 0, 15);
        const fx: f64 = @floatFromInt(x);
        const fy: f64 = @floatFromInt(y);
        const fz: f64 = @floatFromInt(z);
        switch (rand.uintLessThan(u8, 12)) {
            0, 1 => try r.setCell(x, y, z, if (rand.boolean()) .cube else .none, &.{}),
            2, 3 => try r.setCell(x, y, z, .custom, &.{Box.init(fx, fy, fz, fx + 1, fy + 0.5, fz + 1)}),
            4, 5, 6 => try r.setCell(x, y, z, .custom, &.{ Box.init(fx + 0.4, fy, fz + 0.4, fx + 0.6, fy + 1.5, fz + 0.6), Box.init(fx - 0.5, fy, fz, fx + 0.5, fy + 1, fz + 1) }),
            7 => try r.setCell(x, y, z, .may_overflow, &.{}),
            8 => try r.invalidateBlock(x, y, z),
            9 => try r.invalidateCell(x, y, z),
            10 => try r.fillBox(.{ x, y, z }, .{ x + rand.uintLessThan(u8, 20), y + rand.uintLessThan(u8, 20), @min(15, z + rand.uintLessThan(u8, 20)) }, if (rand.boolean()) .cube else .none),
            else => if (step % 50 == 0) try r.invalidateSection(@intCast(x >> 4), @intCast(y >> 4), 0),
        }
        if (step % 97 != 0) continue;
        var copy = try r.clone(testing.allocator);
        defer copy.deinit();
        for ([_]*const Region{ &r, &copy }) |region| {
            var it = region.sections.valueIterator();
            while (it.next()) |s| try expectConsistent(s.*);
        }
    }
}
