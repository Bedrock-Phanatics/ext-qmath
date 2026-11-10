const std = @import("std");
const Allocator = std.mem.Allocator;
const num = @import("num.zig");
const Num = num.Num;
const NumVec = @import("geom.zig").NumVec;
const palette = @import("palette.zig");

const pow = @import("libm.zig").powFn;

pub const max_cells: usize = 1 << 22;
/// Step budget per explosion, the native loop can't be interrupted.
const max_steps: f64 = 1 << 24;

pub const Error = error{ OutOfMemory, OutOfRange, UnknownCell, RegionTooLarge, InvalidArgument };

const State = enum(u8) { unknown, known, invalid };

pub const Grid = struct {
    allocator: Allocator,
    min: [3]i64,
    size: [3]u32,
    values: []f64,
    states: []State,

    pub fn init(allocator: Allocator, min: [3]i64, max: [3]i64) Error!Grid {
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
        const values = try allocator.alloc(f64, @intCast(total));
        errdefer allocator.free(values);
        const states = try allocator.alloc(State, @intCast(total));
        @memset(states, .unknown);
        return .{ .allocator = allocator, .min = min, .size = size, .values = values, .states = states };
    }

    pub fn deinit(self: *Grid) void {
        self.allocator.free(self.values);
        self.allocator.free(self.states);
        self.* = undefined;
    }

    pub fn cellCount(self: *const Grid) usize {
        return self.values.len;
    }

    /// Layout is y fastest, then z, then x.
    pub fn index(self: *const Grid, x: i64, y: i64, z: i64) ?usize {
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

    pub fn set(self: *Grid, x: i64, y: i64, z: i64, resistance: f64) Error!void {
        if (std.math.isNan(resistance)) return error.InvalidArgument;
        const i = self.index(x, y, z) orelse return error.OutOfRange;
        self.values[i] = resistance;
        self.states[i] = .known;
    }

    pub fn setInvalid(self: *Grid, x: i64, y: i64, z: i64) Error!void {
        const i = self.index(x, y, z) orelse return error.OutOfRange;
        self.states[i] = .invalid;
    }

    pub fn fill(self: *Grid, resistance: f64) Error!void {
        if (std.math.isNan(resistance)) return error.InvalidArgument;
        @memset(self.values, resistance);
        @memset(self.states, .known);
    }

    /// Fills the cells of a 16^3 chunk section that lie inside the grid, from palette indexes in section order.
    /// A NaN palette value marks its cells invalid.
    pub fn setSection(self: *Grid, sx: i64, sy: i64, sz: i64, indexes: *const [palette.section_cells]u16, values: []const f64) Error!void {
        const base = [3]i64{ sx *% 16, sy *% 16, sz *% 16 };
        // Offsets into the section, so nothing here can overflow next to PHP_INT_MIN or PHP_INT_MAX.
        var lo: [3]u5 = undefined;
        var hi: [3]u5 = undefined;
        for (0..3) |a| {
            if (base[a] >> 4 != ([3]i64{ sx, sy, sz })[a]) return error.OutOfRange;
            const first = @as(i128, self.min[a]) - base[a];
            const last = first + self.size[a] - 1;
            if (first > 15 or last < 0) return;
            lo[a] = @intCast(@max(first, 0));
            hi[a] = @intCast(@min(last, 15));
        }
        var lx = lo[0];
        while (lx <= hi[0]) : (lx += 1) {
            var lz = lo[2];
            while (lz <= hi[2]) : (lz += 1) {
                var ly = lo[1];
                while (ly <= hi[1]) : (ly += 1) {
                    const v = values[indexes[palette.localIndex(@intCast(lx), @intCast(ly), @intCast(lz))]];
                    const i = self.index(base[0] + lx, base[1] + ly, base[2] + lz).?;
                    if (std.math.isNan(v)) {
                        self.states[i] = .invalid;
                    } else {
                        self.values[i] = v;
                        self.states[i] = .known;
                    }
                }
            }
        }
    }

    /// One value per cell in index order, NaN marks an invalid cell.
    pub fn setPacked(self: *Grid, values: []const f64) Error!void {
        if (values.len != self.values.len) return error.InvalidArgument;
        for (values, self.values, self.states) |v, *dst, *st| {
            if (std.math.isNan(v)) {
                st.* = .invalid;
            } else {
                dst.* = v;
                st.* = .known;
            }
        }
    }
};

pub fn rayCount(rays: i64) i64 {
    if (rays < 2) return 0;
    const inner = rays - 2;
    return rays * rays * rays - inner * inner * inner;
}

/// PHP `$a / $b` for ints with $b > 0: exact quotients stay ints.
fn intDiv(a: i64, b: i64) Num {
    if (@rem(a, b) == 0) return Num.i(@divTrunc(a, b));
    return Num.f(@as(f64, @floatFromInt(a)) / @as(f64, @floatFromInt(b)));
}

fn square(v: Num) Num {
    return switch (v) {
        .int => v.mul(v),
        .float => |f| Num.f(pow(f, 2)),
    };
}

pub const Params = struct {
    radius: f64,
    rays: i64,
    step_len: f64,

    pub fn validate(self: Params) Error!void {
        if (!std.math.isFinite(self.radius) or self.radius <= 0) return error.InvalidArgument;
        if (self.rays < 2 or self.rays > 64) return error.InvalidArgument;
        if (!std.math.isFinite(self.step_len) or self.step_len <= 0) return error.InvalidArgument;
        if (self.radius * 1.3 / (self.step_len * 0.75) * @as(f64, @floatFromInt(rayCount(self.rays))) > max_steps) return error.InvalidArgument;
    }
};

pub fn isBoundaryRay(p: Params, i: i64, j: i64, k: i64) bool {
    const m = p.rays - 1;
    if (i < 0 or j < 0 or k < 0 or i > m or j > m or k > m) return false;
    return i == 0 or i == m or j == 0 or j == m or k == 0 or k == m;
}

/// `rng.range(min, max)` must be mt_rand(). Consecutive repeat cells are skipped.
pub fn traceRay(grid: *const Grid, source: NumVec, p: Params, i: i64, j: i64, k: i64, rng: anytype, sink: anytype) !void {
    const m = p.rays - 1;
    var shift: [3]Num = undefined;
    const idx = [3]i64{ i, j, k };
    inline for (0..3) |a| shift[a] = intDiv(idx[a], m).mul(Num.i(2)).sub(Num.i(1));
    const len = @sqrt(square(shift[0]).add(square(shift[1])).add(square(shift[2])).toFloat());
    var dir: [3]f64 = undefined;
    inline for (0..3) |a| dir[a] = (shift[a].toFloat() / len) * p.step_len;

    var pointer = source;
    var last: ?usize = null;
    var force = p.radius * intDiv(rng.range(700, 1300), 1000).toFloat();
    while (force > 0) : (force -= p.step_len * 0.75) {
        var block: [3]i64 = undefined;
        inline for (0..3) |a| {
            const t: i64 = switch (pointer[a]) {
                .int => |v| v,
                .float => |v| num.dvalToLval(v),
            };
            const ge = switch (pointer[a]) {
                .int => true,
                .float => |v| v >= @as(f64, @floatFromInt(t)),
            };
            block[a] = if (ge) t else t -% 1;
            pointer[a] = pointer[a].add(Num.f(dir[a]));
        }
        const cell = grid.index(block[0], block[1], block[2]) orelse return error.OutOfRange;
        switch (grid.states[cell]) {
            .unknown => return error.UnknownCell,
            .invalid => continue,
            .known => {},
        }
        const resistance = grid.values[cell];
        if (resistance >= 0) {
            force -= (resistance / 5 + 0.3) * p.step_len;
            if (force > 0 and last != cell) {
                last = cell;
                try sink.add(block[0], block[1], block[2]);
            }
        }
    }
}

pub const ListSink = struct {
    list: *std.ArrayList(i64),
    allocator: Allocator,
    seen: ?*std.DynamicBitSetUnmanaged = null,
    grid: *const Grid,

    pub fn add(self: *ListSink, x: i64, y: i64, z: i64) Error!void {
        if (self.seen) |seen| {
            const i = self.grid.index(x, y, z).?;
            if (seen.isSet(i)) return;
            seen.set(i);
        }
        try self.list.appendSlice(self.allocator, &.{ x, y, z });
    }
};

/// Original ray order, first-seen cells only.
pub fn traceRays(grid: *const Grid, allocator: Allocator, source: NumVec, p: Params, rng: anytype, out: *std.ArrayList(i64)) !void {
    try p.validate();
    var seen = try std.DynamicBitSetUnmanaged.initEmpty(allocator, grid.cellCount());
    defer seen.deinit(allocator);
    var sink = ListSink{ .list = out, .allocator = allocator, .seen = &seen, .grid = grid };
    var i: i64 = 0;
    while (i < p.rays) : (i += 1) {
        var j: i64 = 0;
        while (j < p.rays) : (j += 1) {
            var k: i64 = 0;
            while (k < p.rays) : (k += 1) {
                if (isBoundaryRay(p, i, j, k)) try traceRay(grid, source, p, i, j, k, rng, &sink);
            }
        }
    }
}

const testing = std.testing;

const FixedRng = struct {
    value: i64,
    calls: usize = 0,
    pub fn range(self: *FixedRng, min: i64, max: i64) i64 {
        _ = min;
        _ = max;
        self.calls += 1;
        return self.value;
    }
};

test "sections fill the overlapping part of the grid" {
    var g = try Grid.init(testing.allocator, .{ -2, 14, 30 }, .{ 2, 17, 33 });
    defer g.deinit();
    var idx: [palette.section_cells]u16 = @splat(0);
    idx[palette.localIndex(15, 15, 0)] = 1;
    try g.setSection(-1, 0, 2, &idx, &.{ 0.5, std.math.nan(f64) });
    try testing.expectEqual(State.invalid, g.states[g.index(-1, 15, 32).?]);
    try testing.expectEqual(State.known, g.states[g.index(-2, 14, 32).?]);
    try testing.expectEqual(@as(f64, 0.5), g.values[g.index(-2, 14, 32).?]);
    try testing.expectEqual(State.unknown, g.states[g.index(0, 15, 32).?]);
    try testing.expectEqual(State.unknown, g.states[g.index(-1, 16, 32).?]);
    try testing.expectEqual(State.unknown, g.states[g.index(-1, 15, 30).?]);
    try g.setSection(100, 0, 0, &idx, &.{ 0.5, 1 });
    try testing.expectError(error.OutOfRange, g.setSection(std.math.maxInt(i64), 0, 0, &idx, &.{ 0.5, 1 }));
}

test "sections fill grids at the ends of the integer range" {
    const max = std.math.maxInt(i64);
    const min = std.math.minInt(i64);
    const idx: [palette.section_cells]u16 = @splat(0);
    var hi = try Grid.init(testing.allocator, .{ max - 2, max - 2, max - 2 }, .{ max, max, max });
    defer hi.deinit();
    try hi.setSection(max >> 4, max >> 4, max >> 4, &idx, &.{0.5});
    for (hi.states) |s| try testing.expectEqual(State.known, s);
    try hi.setSection(min >> 4, 0, 0, &idx, &.{0.5});
    var lo = try Grid.init(testing.allocator, .{ min, min, min }, .{ min + 17, min + 2, min + 2 });
    defer lo.deinit();
    try lo.setSection(min >> 4, min >> 4, min >> 4, &idx, &.{0.5});
    try testing.expectEqual(State.known, lo.states[lo.index(min + 15, min + 2, min + 2).?]);
    try testing.expectEqual(State.unknown, lo.states[lo.index(min + 16, min, min).?]);
    try testing.expectError(error.RegionTooLarge, Grid.init(testing.allocator, .{ min, 0, 0 }, .{ max, 0, 0 }));
}

test "ray count matches the hollow cube of rays" {
    try testing.expectEqual(@as(i64, 1352), rayCount(16));
}

test "air explosion reaches a sphere of cells" {
    var g = try Grid.init(testing.allocator, .{ -10, -10, -10 }, .{ 10, 10, 10 });
    defer g.deinit();
    try g.fill(0);
    var out: std.ArrayList(i64) = .empty;
    defer out.deinit(testing.allocator);
    var rng = FixedRng{ .value = 1000 };
    try traceRays(&g, testing.allocator, .{ Num.f(0.5), Num.f(0.5), Num.f(0.5) }, .{ .radius = 4, .rays = 16, .step_len = 0.3 }, &rng, &out);
    try testing.expectEqual(@as(usize, 1352), rng.calls);
    try testing.expect(out.items.len % 3 == 0 and out.items.len > 0);
    try testing.expectEqualSlices(i64, &.{ 0, 0, 0 }, out.items[0..3]);
}

test "high resistance blocks stop rays" {
    var g = try Grid.init(testing.allocator, .{ -10, -10, -10 }, .{ 10, 10, 10 });
    defer g.deinit();
    try g.fill(0);
    try g.set(0, 0, 0, 1e6);
    var out: std.ArrayList(i64) = .empty;
    defer out.deinit(testing.allocator);
    var rng = FixedRng{ .value = 1300 };
    try traceRays(&g, testing.allocator, .{ Num.f(0.5), Num.f(0.5), Num.f(0.5) }, .{ .radius = 4, .rays = 16, .step_len = 0.3 }, &rng, &out);
    try testing.expectEqual(@as(usize, 0), out.items.len);
}

test "unknown cells and bad parameters are rejected" {
    var g = try Grid.init(testing.allocator, .{ -2, -2, -2 }, .{ 2, 2, 2 });
    defer g.deinit();
    var out: std.ArrayList(i64) = .empty;
    defer out.deinit(testing.allocator);
    var rng = FixedRng{ .value = 1000 };
    const src = NumVec{ Num.f(0.5), Num.f(0.5), Num.f(0.5) };
    try testing.expectError(error.UnknownCell, traceRays(&g, testing.allocator, src, .{ .radius = 1, .rays = 16, .step_len = 0.3 }, &rng, &out));
    try g.fill(0);
    try testing.expectError(error.OutOfRange, traceRays(&g, testing.allocator, src, .{ .radius = 8, .rays = 16, .step_len = 0.3 }, &rng, &out));
    try testing.expectError(error.InvalidArgument, traceRays(&g, testing.allocator, src, .{ .radius = 1, .rays = 1, .step_len = 0.3 }, &rng, &out));
    try testing.expectError(error.InvalidArgument, traceRays(&g, testing.allocator, src, .{ .radius = 1, .rays = 16, .step_len = 1e-300 }, &rng, &out));
}
