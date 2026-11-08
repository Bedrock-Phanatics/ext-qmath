//! Explosion::explodeA() ray marching over a grid of blast resistances.

const std = @import("std");
const Allocator = std.mem.Allocator;
const num = @import("num.zig");
const Num = num.Num;
const NumVec = @import("geom.zig").NumVec;

const pow = @import("libm.zig").powFn;

pub const max_cells: usize = 1 << 22;
const max_steps_per_ray: f64 = 1_000_000;

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

    /// Same layout as the collision region: y fastest, then z, then x.
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

/// `$v ** 2` for int|float.
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
        if (self.radius * 1.3 / (self.step_len * 0.75) > max_steps_per_ray) return error.InvalidArgument;
    }
};

pub fn isBoundaryRay(p: Params, i: i64, j: i64, k: i64) bool {
    const m = p.rays - 1;
    if (i < 0 or j < 0 or k < 0 or i > m or j > m or k > m) return false;
    return i == 0 or i == m or j == 0 or j == m or k == 0 or k == m;
}

/// One iteration of the innermost explodeA() loop body. `rng.range(min, max)` must be mt_rand().
/// Each cell reached with force left is passed to `sink.add(x, y, z)`, consecutive repeats skipped.
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

/// Every ray of explodeA() in its original order, returning first-seen cells without duplicates.
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
