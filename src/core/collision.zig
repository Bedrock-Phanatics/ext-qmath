//! Block collision data and the Entity::move() collision solver.
//! Cells without data are unknown, and queries touching them fail instead of treating them as air.

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
    RegionFull,
    RegionTooLarge,
    Frozen,
};

const Cell = packed struct(u32) {
    first: u16 = 0,
    count: u8 = 0,
    info: Info = .unknown,
};

const Section = struct {
    /// Set while every cell shares this info and there are no boxes.
    uniform: ?Info = null,
    cells: ?*[section_cells]Cell = null,
    boxes: std.ArrayList(Box) = .empty,
    live: u32 = 0,
    unknown: u16 = section_cells,

    fn free(self: *Section, allocator: Allocator) void {
        if (self.cells) |cells| allocator.destroy(cells);
        self.boxes.deinit(allocator);
        allocator.destroy(self);
    }

    fn cell(self: *const Section, i: u12) Cell {
        if (self.cells) |cells| return cells[i];
        return .{ .info = self.uniform orelse .unknown };
    }

    fn expand(self: *Section, allocator: Allocator) Error!*[section_cells]Cell {
        if (self.cells) |cells| return cells;
        const cells = try allocator.create([section_cells]Cell);
        @memset(cells, .{ .info = self.uniform orelse .unknown });
        self.cells = cells;
        self.uniform = null;
        return cells;
    }

    /// Live ranges are not in cell order, so they move down in storage order.
    fn compact(self: *Section) void {
        const cells = self.cells orelse return;
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

/// One-entry section cache, queries visit cells in runs.
pub const Lookup = struct {
    key: u64 = std.math.maxInt(u64),
    section: ?*Section = null,
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
        try copy.sections.ensureTotalCapacity(allocator, self.sections.count());
        var it = self.sections.iterator();
        while (it.next()) |e| {
            const src = e.value_ptr.*;
            const s = try allocator.create(Section);
            s.* = .{ .uniform = src.uniform, .live = src.live, .unknown = src.unknown };
            copy.sections.putAssumeCapacity(e.key_ptr.*, s);
            if (src.cells) |cells| {
                const dst = try allocator.create([section_cells]Cell);
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
        if (lk.key != key) {
            lk.key = key;
            lk.section = self.sections.get(key);
        }
        return lk.section;
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
        return switch (at.cell.info) {
            .unknown => error.UnknownCell,
            .none => &.{},
            .cube => blk: {
                scratch.* = Box.unitAt(x, y, z);
                break :blk scratch[0..1];
            },
            else => at.section.boxes.items[at.cell.first..][0..at.cell.count],
        };
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
        return s;
    }

    fn validate(info: Info, boxes: []const Box) Error!void {
        if (info == .unknown) return error.InvalidInfo;
        if ((info == .cube or info == .none) and boxes.len != 0) return error.InvalidInfo;
        if (boxes.len > max_boxes_per_cell) return error.TooManyBoxes;
        for (boxes) |b| if (!b.isValid()) return error.InvalidBox;
    }

    pub fn setCell(self: *Region, x: i64, y: i64, z: i64, info: Info, boxes: []const Box) Error!void {
        const loc = locate(x, y, z) orelse return error.OutOfRange;
        try validate(info, boxes);
        if (self.frozen) return error.Frozen;
        const s = try self.getOrCreate(loc.key);
        if (s.cells == null and boxes.len == 0 and s.uniform == info) {
            self.version +%= 1;
            return;
        }
        const cells = try s.expand(self.allocator);
        const cell = &cells[loc.local];
        if (boxes.len <= cell.count) {
            @memcpy(s.boxes.items[cell.first..][0..boxes.len], boxes);
            s.live -= cell.count - @as(u32, @intCast(boxes.len));
            if (boxes.len == 0) cell.first = 0;
        } else {
            if (s.boxes.items.len + boxes.len > max_boxes_per_section) {
                s.compact();
                if (s.boxes.items.len + boxes.len > max_boxes_per_section) return error.TooManyBoxes;
            }
            const first: u16 = @intCast(s.boxes.items.len);
            try s.boxes.appendSlice(self.allocator, boxes);
            s.live += @as(u32, @intCast(boxes.len)) - cell.count;
            cell.first = first;
        }
        if (cell.info == .unknown) s.unknown -= 1;
        cell.count = @intCast(boxes.len);
        cell.info = info;
        self.version +%= 1;
        if (s.boxes.items.len > 256 and s.boxes.items.len > s.live * 2) s.compact();
    }

    /// `infos` is in localIndex() order.
    pub fn setSection(self: *Region, sx: i32, sy: i32, sz: i32, infos: []const Info, cell_boxes: []const CellBoxes) Error!void {
        if (infos.len != section_cells) return error.InvalidInfo;
        if (!inRange(@as(i64, sx) * 16, @as(i64, sy) * 16, @as(i64, sz) * 16) or !inRange(@as(i64, sx) * 16 + 15, @as(i64, sy) * 16 + 15, @as(i64, sz) * 16 + 15)) return error.OutOfRange;
        var total: usize = 0;
        for (infos) |i| if (i == .unknown) return error.InvalidInfo;
        for (cell_boxes) |cb| {
            try validate(infos[cb.index], cb.boxes);
            if (infos[cb.index] == .cube or infos[cb.index] == .none) return error.InvalidInfo;
            total += cb.boxes.len;
        }
        if (total > max_boxes_per_section) return error.TooManyBoxes;
        if (self.frozen) return error.Frozen;

        const uniform = cell_boxes.len == 0 and std.mem.allEqual(Info, infos, infos[0]);
        var fresh = Section{ .unknown = 0 };
        errdefer if (fresh.cells) |c| self.allocator.destroy(c);
        errdefer fresh.boxes.deinit(self.allocator);
        if (uniform) {
            fresh.uniform = infos[0];
        } else {
            const cells = try self.allocator.create([section_cells]Cell);
            fresh.cells = cells;
            for (cells, infos) |*c, i| c.* = .{ .info = i };
            try fresh.boxes.ensureTotalCapacity(self.allocator, total);
            for (cell_boxes) |cb| {
                const c = &cells[cb.index];
                if (c.count != 0) return error.InvalidInfo;
                c.first = @intCast(fresh.boxes.items.len);
                c.count = @intCast(cb.boxes.len);
                fresh.boxes.appendSliceAssumeCapacity(cb.boxes);
            }
            fresh.live = @intCast(total);
        }
        const s = try self.getOrCreate(sectionKey(sx, sy, sz));
        if (s.cells) |c| self.allocator.destroy(c);
        s.boxes.deinit(self.allocator);
        s.* = fresh;
        self.version +%= 1;
    }

    /// Replaces a section with box-less cells. Cells given as unknown stay unknown until setCell() fills them.
    pub fn setSectionInfos(self: *Region, sx: i32, sy: i32, sz: i32, infos: *const [section_cells]Info) Error!void {
        if (!inRange(@as(i64, sx) * 16, @as(i64, sy) * 16, @as(i64, sz) * 16) or !inRange(@as(i64, sx) * 16 + 15, @as(i64, sy) * 16 + 15, @as(i64, sz) * 16 + 15)) return error.OutOfRange;
        if (self.frozen) return error.Frozen;
        var fresh = Section{ .unknown = 0 };
        errdefer if (fresh.cells) |c| self.allocator.destroy(c);
        if (infos[0] != .unknown and std.mem.allEqual(Info, infos, infos[0])) {
            fresh.uniform = infos[0];
        } else {
            const cells = try self.allocator.create([section_cells]Cell);
            fresh.cells = cells;
            for (cells, infos) |*c, i| {
                c.* = .{ .info = i };
                if (i == .unknown) fresh.unknown += 1;
            }
        }
        const s = try self.getOrCreate(sectionKey(sx, sy, sz));
        if (s.cells) |c| self.allocator.destroy(c);
        s.boxes.deinit(self.allocator);
        s.* = fresh;
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
        // Sections already rewritten stay rewritten if a later one fails.
        defer self.version +%= 1;
        var sx = min[0] >> 4;
        while (sx <= max[0] >> 4) : (sx += 1) {
            var sz = min[2] >> 4;
            while (sz <= max[2] >> 4) : (sz += 1) {
                var sy = min[1] >> 4;
                while (sy <= max[1] >> 4) : (sy += 1) {
                    const base = [3]i64{ sx * 16, sy * 16, sz * 16 };
                    var lo: [3]i64 = undefined;
                    var hi: [3]i64 = undefined;
                    var whole = true;
                    for (0..3) |a| {
                        lo[a] = @max(min[a], base[a]);
                        hi[a] = @min(max[a], base[a] + 15);
                        if (lo[a] != base[a] or hi[a] != base[a] + 15) whole = false;
                    }
                    const s = try self.getOrCreate(sectionKey(@intCast(sx), @intCast(sy), @intCast(sz)));
                    if (whole) {
                        if (s.cells) |c| self.allocator.destroy(c);
                        s.boxes.deinit(self.allocator);
                        s.* = .{ .uniform = info, .unknown = 0 };
                        continue;
                    }
                    if (s.cells == null and s.uniform == info) continue;
                    const c = try s.expand(self.allocator);
                    var x = lo[0];
                    while (x <= hi[0]) : (x += 1) {
                        var z = lo[2];
                        while (z <= hi[2]) : (z += 1) {
                            var y = lo[1];
                            while (y <= hi[1]) : (y += 1) {
                                const cell = &c[locate(x, y, z).?.local];
                                if (cell.info == .unknown) s.unknown -= 1;
                                s.live -= cell.count;
                                cell.* = .{ .info = info };
                            }
                        }
                    }
                }
            }
        }
    }

    fn forget(self: *Region, x: i64, y: i64, z: i64) Error!void {
        const loc = locate(x, y, z) orelse return;
        const s = self.sections.get(loc.key) orelse return;
        if (s.cells == null and s.uniform == null) return;
        const cells = try s.expand(self.allocator);
        const c = &cells[loc.local];
        if (c.info == .unknown) return;
        s.live -= c.count;
        c.* = .{};
        s.unknown += 1;
    }

    pub fn invalidateCell(self: *Region, x: i64, y: i64, z: i64) Error!void {
        try self.mutate();
        try self.forget(x, y, z);
    }

    /// Also drops the six neighbours, like World's cache invalidation.
    pub fn invalidateBlock(self: *Region, x: i64, y: i64, z: i64) Error!void {
        try self.mutate();
        try self.forget(x, y, z);
        for (geom.facing.offsets) |o| {
            const nx = std.math.add(i64, x, o[0]) catch continue;
            const ny = std.math.add(i64, y, o[1]) catch continue;
            const nz = std.math.add(i64, z, o[2]) catch continue;
            try self.forget(nx, ny, nz);
        }
    }

    pub fn invalidateSection(self: *Region, sx: i32, sy: i32, sz: i32) Error!void {
        try self.mutate();
        if (!inRange(@as(i64, sx) * 16, @as(i64, sy) * 16, @as(i64, sz) * 16)) return;
        if (self.sections.fetchRemove(sectionKey(sx, sy, sz))) |kv| kv.value.free(self.allocator);
    }

    pub fn invalidateChunk(self: *Region, chunk_x: i32, chunk_z: i32) Error!void {
        try self.mutate();
        var doomed: std.ArrayList(u64) = .empty;
        defer doomed.deinit(self.allocator);
        var it = self.sections.keyIterator();
        while (it.next()) |k| {
            const p = keyPos(k.*);
            if (p.x == chunk_x and p.z == chunk_z) try doomed.append(self.allocator, k.*);
        }
        for (doomed.items) |k| {
            if (self.sections.fetchRemove(k)) |kv| kv.value.free(self.allocator);
        }
    }

    pub fn invalidateAll(self: *Region) Error!void {
        try self.mutate();
        var it = self.sections.valueIterator();
        while (it.next()) |s| s.*.free(self.allocator);
        self.sections.clearRetainingCapacity();
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

    /// Own boxes plus overflow from neighbouring cells.
    fn cellCollisionBoxes(self: *const Region, lk: *Lookup, nk: *Lookup, x: i64, y: i64, z: i64, sink: anytype) !void {
        var scratch: Box = undefined;
        const info = try self.cellInfo(lk, x, y, z);
        for (try self.ownBoxes(lk, x, y, z, &scratch)) |b| try sink.add(b);
        if (info == .cube) return;
        const cell_bb = Box.unitAt(x, y, z);
        for (geom.facing.offsets) |o| {
            const nx = x + o[0];
            const ny = y + o[1];
            const nz = z + o[2];
            if (try self.cellInfo(nk, nx, ny, nz) != .may_overflow) continue;
            for (try self.ownBoxes(nk, nx, ny, nz, &scratch)) |b| {
                if (b.intersects(cell_bb, geom.default_epsilon)) try sink.add(b);
            }
        }
    }

    /// Same boxes in the same order as PHP, duplicates included.
    pub fn collisionBoxes(self: *const Region, query: Box, sink: anytype) !void {
        const r = try cellRange(query);
        var lk = Lookup{};
        var nk = Lookup{};
        var filter = FilterSink(@TypeOf(sink)){ .inner = sink, .query = query };
        var z = r[0][2];
        while (z <= r[1][2]) : (z += 1) {
            var x = r[0][0];
            while (x <= r[1][0]) : (x += 1) {
                var y = r[0][1];
                while (y <= r[1][1]) : (y += 1) {
                    try self.cellCollisionBoxes(&lk, &nk, x, y, z, &filter);
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

fn FilterSink(comptime Inner: type) type {
    return struct {
        inner: Inner,
        query: Box,
        pub fn add(self: *@This(), b: Box) !void {
            if (b.intersects(self.query, geom.default_epsilon)) try self.inner.add(b);
        }
    };
}

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
    var list: std.ArrayList(Box) = .empty;
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
        try r.setCell(@intCast(i % 4), 0, 0, .custom, a[0..n]);
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

test "a fill that runs out of sections still bumps the version" {
    var r = Region.init(testing.allocator, 1);
    defer r.deinit();
    try r.fillBox(.{ 0, 0, 0 }, .{ 15, 15, 15 }, .none);
    const v = r.version;
    try testing.expectError(error.RegionFull, r.fillBox(.{ 0, 0, 0 }, .{ 31, 15, 15 }, .cube));
    try testing.expect(r.version != v);
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
