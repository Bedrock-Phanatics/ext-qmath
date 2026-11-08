//! Block collision data and the Entity::move() collision solver.

const std = @import("std");
const Allocator = std.mem.Allocator;
const num = @import("num.zig");
const geom = @import("geom.zig");
const Box = geom.Box;
const Vec = geom.Vec;

extern fn pow(x: f64, y: f64) f64;

/// RuntimeBlockStateRegistry collision info values. `unknown` marks cells with no data.
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

pub const max_cells: usize = 1 << 22;
pub const max_boxes_per_cell: usize = 64;
const max_total_boxes: usize = 1 << 24;

pub const Error = error{
    OutOfMemory,
    /// A query needed a cell outside the region.
    OutOfRange,
    /// A query needed a cell whose data was never provided or was invalidated.
    UnknownCell,
    InvalidBox,
    InvalidInfo,
    TooManyBoxes,
    RegionTooLarge,
    Frozen,
};

const Cell = struct {
    first: u32 = 0,
    count: u8 = 0,
    info: Info = .unknown,
};

pub const Region = struct {
    allocator: Allocator,
    min: [3]i64,
    size: [3]u32,
    cells: []Cell,
    boxes: std.ArrayList(Box) = .empty,
    live_boxes: usize = 0,
    version: u64 = 0,
    frozen: bool = false,

    pub fn init(allocator: Allocator, min: [3]i64, max: [3]i64) Error!Region {
        var size: [3]u32 = undefined;
        var total: u64 = 1;
        for (0..3) |a| {
            if (max[a] < min[a]) return error.RegionTooLarge;
            const span = @as(i128, max[a]) - min[a] + 1;
            if (span > max_cells) return error.RegionTooLarge;
            size[a] = @intCast(span);
            total *= size[a];
            if (total > max_cells) return error.RegionTooLarge;
        }
        const cells = try allocator.alloc(Cell, @intCast(total));
        @memset(cells, .{});
        return .{ .allocator = allocator, .min = min, .size = size, .cells = cells };
    }

    pub fn deinit(self: *Region) void {
        self.allocator.free(self.cells);
        self.boxes.deinit(self.allocator);
        self.* = undefined;
    }

    /// Compacted deep copy, unfrozen.
    pub fn clone(self: *const Region, allocator: Allocator) Error!Region {
        const cells = try allocator.dupe(Cell, self.cells);
        errdefer allocator.free(cells);
        var boxes: std.ArrayList(Box) = .empty;
        errdefer boxes.deinit(allocator);
        try boxes.ensureTotalCapacity(allocator, self.live_boxes);
        for (cells) |*cell| {
            if (cell.count == 0) continue;
            const first: u32 = @intCast(boxes.items.len);
            boxes.appendSliceAssumeCapacity(self.boxes.items[cell.first..][0..cell.count]);
            cell.first = first;
        }
        return .{
            .allocator = allocator,
            .min = self.min,
            .size = self.size,
            .cells = cells,
            .boxes = boxes,
            .live_boxes = self.live_boxes,
            .version = self.version,
        };
    }

    pub fn maxCorner(self: *const Region) [3]i64 {
        var r: [3]i64 = undefined;
        for (0..3) |a| r[a] = self.min[a] + self.size[a] - 1;
        return r;
    }

    /// Cells are laid out with y varying fastest, then z, then x.
    pub fn index(self: *const Region, x: i64, y: i64, z: i64) ?usize {
        const p = [3]i64{ x, y, z };
        var rel: [3]u64 = undefined;
        for (0..3) |a| {
            if (p[a] < self.min[a]) return null;
            const d: u64 = @intCast(@as(i128, p[a]) - self.min[a]);
            if (d >= self.size[a]) return null;
            rel[a] = d;
        }
        return @intCast((rel[0] * self.size[2] + rel[2]) * self.size[1] + rel[1]);
    }

    pub fn cellInfo(self: *const Region, x: i64, y: i64, z: i64) Error!Info {
        const i = self.index(x, y, z) orelse return error.OutOfRange;
        const info = self.cells[i].info;
        if (info == .unknown) return error.UnknownCell;
        return info;
    }

    fn mutate(self: *Region) Error!void {
        if (self.frozen) return error.Frozen;
        self.version +%= 1;
    }

    pub fn setCell(self: *Region, x: i64, y: i64, z: i64, info: Info, boxes: []const Box) Error!void {
        const i = self.index(x, y, z) orelse return error.OutOfRange;
        if (info == .unknown) return error.InvalidInfo;
        if ((info == .cube or info == .none) and boxes.len != 0) return error.InvalidInfo;
        if (boxes.len > max_boxes_per_cell) return error.TooManyBoxes;
        for (boxes) |b| if (!b.isValid()) return error.InvalidBox;
        if (self.frozen) return error.Frozen;

        const cell = &self.cells[i];
        if (boxes.len <= cell.count) {
            // Reuse the existing span in place.
            @memcpy(self.boxes.items[cell.first..][0..boxes.len], boxes);
            self.live_boxes -= cell.count - boxes.len;
        } else {
            if (self.boxes.items.len + boxes.len > max_total_boxes) {
                self.compact();
                if (self.boxes.items.len + boxes.len > max_total_boxes) return error.TooManyBoxes;
            }
            const first: u32 = @intCast(self.boxes.items.len);
            try self.boxes.appendSlice(self.allocator, boxes);
            self.live_boxes += boxes.len - cell.count;
            cell.first = first;
        }
        cell.count = @intCast(boxes.len);
        cell.info = info;
        self.version +%= 1;
        if (self.boxes.items.len > 4096 and self.boxes.items.len > self.live_boxes * 2) self.compact();
    }

    pub fn fill(self: *Region, info: Info) Error!void {
        if (info != .none and info != .cube) return error.InvalidInfo;
        try self.mutate();
        @memset(self.cells, .{ .info = info });
        self.boxes.clearRetainingCapacity();
        self.live_boxes = 0;
    }

    fn forget(self: *Region, i: usize) void {
        self.live_boxes -= self.cells[i].count;
        self.cells[i] = .{};
    }

    pub fn invalidateCell(self: *Region, x: i64, y: i64, z: i64) Error!void {
        try self.mutate();
        if (self.index(x, y, z)) |i| self.forget(i);
    }

    pub fn invalidateBlock(self: *Region, x: i64, y: i64, z: i64) Error!void {
        try self.mutate();
        if (self.index(x, y, z)) |i| self.forget(i);
        for (geom.facing.offsets) |o| {
            const nx = std.math.add(i64, x, o[0]) catch continue;
            const ny = std.math.add(i64, y, o[1]) catch continue;
            const nz = std.math.add(i64, z, o[2]) catch continue;
            if (self.index(nx, ny, nz)) |i| self.forget(i);
        }
    }

    /// Forgets every cell in the 16x16 column of the chunk, plus the neighbouring cells whose
    /// overflow boxes could reach into it.
    pub fn invalidateChunk(self: *Region, chunk_x: i64, chunk_z: i64) Error!void {
        try self.mutate();
        const lo_x = std.math.mul(i64, chunk_x, 16) catch return;
        const lo_z = std.math.mul(i64, chunk_z, 16) catch return;
        const max = self.maxCorner();
        const x0 = @max(lo_x -| 1, self.min[0]);
        const x1 = @min(lo_x +| 16, max[0]);
        const z0 = @max(lo_z -| 1, self.min[2]);
        const z1 = @min(lo_z +| 16, max[2]);
        var x = x0;
        while (x <= x1) : (x += 1) {
            var z = z0;
            while (z <= z1) : (z += 1) {
                const start = self.index(x, self.min[1], z).?;
                for (start..start + self.size[1]) |i| self.forget(i);
            }
        }
    }

    pub fn invalidateAll(self: *Region) Error!void {
        try self.mutate();
        @memset(self.cells, .{});
        self.boxes.clearRetainingCapacity();
        self.live_boxes = 0;
    }

    fn compact(self: *Region) void {
        var w: usize = 0;
        for (self.cells) |*cell| {
            if (cell.count == 0) continue;
            std.mem.copyForwards(Box, self.boxes.items[w..][0..cell.count], self.boxes.items[cell.first..][0..cell.count]);
            cell.first = @intCast(w);
            w += cell.count;
        }
        self.boxes.shrinkRetainingCapacity(w);
    }

    /// Block::getCollisionBoxes() for the cell. `scratch` holds the synthesized box of a full cube.
    pub fn ownBoxes(self: *const Region, x: i64, y: i64, z: i64, scratch: *Box) Error![]const Box {
        const i = self.index(x, y, z) orelse return error.OutOfRange;
        const cell = self.cells[i];
        return switch (cell.info) {
            .unknown => error.UnknownCell,
            .none => &.{},
            .cube => blk: {
                scratch.* = Box.unitAt(x, y, z);
                break :blk scratch[0..1];
            },
            else => self.boxes.items[cell.first..][0..cell.count],
        };
    }

    /// World::getBlockCollisionBoxesForCell(): the cell's boxes plus overflow from neighbouring cells.
    fn cellCollisionBoxes(self: *const Region, x: i64, y: i64, z: i64, sink: anytype) !void {
        var scratch: Box = undefined;
        const info = try self.cellInfo(x, y, z);
        for (try self.ownBoxes(x, y, z, &scratch)) |b| try sink.add(b);
        if (info == .cube) return;
        const cell_bb = Box.unitAt(x, y, z);
        for (geom.facing.offsets) |o| {
            const nx = std.math.add(i64, x, o[0]) catch return error.OutOfRange;
            const ny = std.math.add(i64, y, o[1]) catch return error.OutOfRange;
            const nz = std.math.add(i64, z, o[2]) catch return error.OutOfRange;
            if (try self.cellInfo(nx, ny, nz) != .may_overflow) continue;
            for (try self.ownBoxes(nx, ny, nz, &scratch)) |b| {
                if (b.intersects(cell_bb, geom.default_epsilon)) try sink.add(b);
            }
        }
    }

    /// World::getBlockCollisionBoxes(): same boxes in the same order, duplicates included.
    pub fn collisionBoxes(self: *const Region, query: Box, sink: anytype) !void {
        if (!query.isValid()) return error.InvalidBox;
        const lo = [3]i64{ num.dvalToLval(@floor(query.min[0])), num.dvalToLval(@floor(query.min[1])), num.dvalToLval(@floor(query.min[2])) };
        const hi = [3]i64{ num.dvalToLval(@floor(query.max[0])), num.dvalToLval(@floor(query.max[1])), num.dvalToLval(@floor(query.max[2])) };
        // Reject ranges that leave the region before iterating, which also bounds the loop.
        if (self.index(lo[0], lo[1], lo[2]) == null or self.index(hi[0], hi[1], hi[2]) == null) return error.OutOfRange;
        var filter = FilterSink(@TypeOf(sink)){ .inner = sink, .query = query };
        var z = lo[2];
        while (z <= hi[2]) : (z += 1) {
            var x = lo[0];
            while (x <= hi[0]) : (x += 1) {
                var y = lo[1];
                while (y <= hi[1]) : (y += 1) {
                    try self.cellCollisionBoxes(x, y, z, &filter);
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

/// Collects boxes into an allocator-backed list.
pub const ListSink = struct {
    list: *std.ArrayList(Box),
    allocator: Allocator,
    pub fn add(self: *ListSink, b: Box) Error!void {
        if (self.list.items.len >= max_total_boxes) return error.TooManyBoxes;
        try self.list.append(self.allocator, b);
    }
};

pub fn collectBoxes(region: *const Region, allocator: Allocator, query: Box, list: *std.ArrayList(Box)) Error!void {
    list.clearRetainingCapacity();
    var sink = ListSink{ .list = list, .allocator = allocator };
    try region.collisionBoxes(query, &sink);
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

/// Collision part of Entity::move() for an entity that is not in keepMovement mode.
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
    // x, z in [-4, 4], y in [-3, 9]; a floor of full blocks at y = 0.
    var r = try Region.init(allocator, .{ -4, -3, -4 }, .{ 4, 9, 4 });
    errdefer r.deinit();
    try r.fill(.none);
    var x: i64 = -4;
    while (x <= 4) : (x += 1) {
        var z: i64 = -4;
        while (z <= 4) : (z += 1) try r.setCell(x, 0, z, .cube, &.{});
    }
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
    var r = try Region.init(testing.allocator, .{ 0, 0, 0 }, .{ 3, 3, 3 });
    defer r.deinit();
    try testing.expectError(error.UnknownCell, move(&r, testing.allocator, player(1.5, 1, 1.5), .{ 0, -0.5, 0 }, 0, false));
    try r.fill(.none);
    try r.invalidateBlock(1, 0, 1);
    try testing.expectError(error.UnknownCell, move(&r, testing.allocator, player(1.5, 1, 1.5), .{ 0, -0.5, 0 }, 0, false));
    try testing.expectError(error.OutOfRange, move(&r, testing.allocator, player(1.5, 1, 1.5), .{ 0, -5, 0 }, 0, false));
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

test "region bounds and memory limits" {
    try testing.expectError(error.RegionTooLarge, Region.init(testing.allocator, .{ 0, 0, 0 }, .{ 4096, 4096, 4096 }));
    try testing.expectError(error.RegionTooLarge, Region.init(testing.allocator, .{ 5, 0, 0 }, .{ 0, 0, 0 }));
    try testing.expectError(error.RegionTooLarge, Region.init(testing.allocator, .{ std.math.minInt(i64), 0, 0 }, .{ std.math.maxInt(i64), 0, 0 }));
    var r = try Region.init(testing.allocator, .{ 0, 0, 0 }, .{ 1, 1, 1 });
    defer r.deinit();
    try testing.expectError(error.OutOfRange, r.setCell(2, 0, 0, .none, &.{}));
    try testing.expectError(error.InvalidBox, r.setCell(0, 0, 0, .custom, &.{Box.init(1, 0, 0, 0, 1, 1)}));
    try testing.expectError(error.InvalidBox, r.setCell(0, 0, 0, .custom, &.{Box.init(std.math.nan(f64), 0, 0, 1, 1, 1)}));
    r.frozen = true;
    try testing.expectError(error.Frozen, r.setCell(0, 0, 0, .none, &.{}));
}

test "repeated cell updates do not grow storage without bound" {
    var r = try Region.init(testing.allocator, .{ 0, 0, 0 }, .{ 3, 3, 3 });
    defer r.deinit();
    const a = [_]Box{ Box.init(0, 0, 0, 1, 0.5, 1), Box.init(0, 0.5, 0, 0.5, 1, 0.5) };
    for (0..20000) |i| {
        const n: usize = if (i % 2 == 0) 1 else 2;
        try r.setCell(@intCast(i % 4), 0, 0, .custom, a[0..n]);
    }
    try testing.expect(r.boxes.items.len <= 8192);
}

test "sweep catches thin walls at high speed" {
    var r = try Region.init(testing.allocator, .{ -1, -1, -1 }, .{ 40, 3, 3 });
    defer r.deinit();
    try r.fill(.none);
    try r.setCell(30, 0, 0, .custom, &.{Box.init(30, 0, 0, 30.05, 1, 1)});
    const hit = (try sweep(&r, testing.allocator, Box.init(0.2, 0.2, 0.2, 0.8, 0.8, 0.8), .{ 38, 0, 0 })).?;
    try testing.expectEqual(geom.facing.west, hit.face);
    try testing.expect(hit.time > 0.76 and hit.time < 0.78);
}
