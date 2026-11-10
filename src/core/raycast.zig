const std = @import("std");
const geom = @import("geom.zig");
const voxel = @import("voxel.zig");
const collision = @import("collision.zig");
const Num = @import("num.zig").Num;
const Box = geom.Box;
const Vec = geom.Vec;
const NumVec = geom.NumVec;
const Region = collision.Region;

pub const Error = collision.Error || voxel.Error || error{ TooManySamples, TooManySteps };

/// Voxel visits shared by everything one PHP call traces, since nothing can interrupt a native loop.
pub const Budget = struct {
    pub const max_steps = 1 << 22;

    left: u64 = max_steps,

    inline fn take(self: *Budget) Error!void {
        if (self.left == 0) return error.TooManySteps;
        self.left -= 1;
    }
};

pub const BoxHit = struct {
    face: i64,
    hit: Vec,
    box: Box,
};

pub const BlockHit = struct {
    /// The block owning the box, which is not the voxel the hit lies in when the box overflows.
    cell: [3]i64,
    hit: BoxHit,
};

/// Nearest intercept that lies inside one voxel. A box reaching in from a neighbour is only hit here if the
/// segment meets it here, so walking the voxels in order finds the nearest hit overall.
const VoxelPick = struct {
    start: NumVec,
    end: NumVec,
    cell: [3]i64 = undefined,
    best: ?BlockHit = null,
    distance: f64 = geom.php_int_max_f,

    /// Slack for hits computed a rounding error outside the voxel the walk is in.
    const slack = 1e-6;

    pub fn add(self: *VoxelPick, box: Box, owner: [3]i64) void {
        var lo: Vec = undefined;
        var hi: Vec = undefined;
        // A hit in this voxel needs the box to reach it, which most boxes of the cells around do not.
        inline for (0..3) |a| {
            lo[a] = @as(f64, @floatFromInt(self.cell[a])) - slack;
            hi[a] = @as(f64, @floatFromInt(self.cell[a])) + 1.0 + slack;
            if (box.max[a] < lo[a] or box.min[a] > hi[a]) return;
        }
        const h = geom.calculateIntercept(box, self.start, self.end) orelse return;
        inline for (0..3) |a| {
            if (h.hit[a] < lo[a] or h.hit[a] > hi[a]) return;
        }
        const d = geom.distanceSquaredNum(self.start, h.hit);
        if (d < self.distance) {
            self.best = .{ .cell = owner, .hit = .{ .face = h.face, .hit = h.hit, .box = box } };
            self.distance = d;
        }
    }
};

/// Stops at the first voxel in which a collision box intercepts the segment, its own or one overflowing into it.
pub fn firstBlock(region: *const Region, start: NumVec, end: NumVec, budget: *Budget) Error!?BlockHit {
    var ray = try voxel.Ray.init(start, end);
    var lk = collision.Lookup{};
    var pick = VoxelPick{ .start = start, .end = end };
    while (true) {
        try budget.take();
        const c = ray.cell() orelse return error.OutOfRange;
        pick.cell = c;
        try region.reaching(&lk, c[0], c[1], c[2], &pick);
        if (pick.best) |h| return h;
        if (!ray.advance()) return null;
    }
}

const max_samples_per_axis = 1024;
const max_samples = 1 << 22;

/// Fraction of sample points in `bb` with a clear line to `origin`.
pub fn exposure(region: *const Region, origin: NumVec, bb: Box, budget: *Budget) Error!f64 {
    var diff: Vec = undefined;
    var step: Vec = undefined;
    inline for (0..3) |a| {
        diff[a] = (bb.max[a] - bb.min[a]) * 2.0 + 1.0;
        if (!(diff[a] <= max_samples_per_axis)) return error.TooManySamples;
        step[a] = 1.0 / diff[a];
    }
    if ((diff[0] + 1) * (diff[1] + 1) * (diff[2] + 1) > max_samples) return error.TooManySamples;
    const x_offset = (1.0 - (@floor(diff[0]) / diff[0])) / 2.0;
    const z_offset = (1.0 - (@floor(diff[2]) / diff[2])) / 2.0;

    var checks: f64 = 0.0;
    var hits: f64 = 0.0;
    var x: f64 = 0.0;
    while (x <= 1.0) : (x += step[0]) {
        var y: f64 = 0.0;
        while (y <= 1.0) : (y += step[1]) {
            var z: f64 = 0.0;
            while (z <= 1.0) : (z += step[2]) {
                const point = NumVec{
                    Num.f(lerp(x, bb.min[0], bb.max[0]) + x_offset),
                    Num.f(lerp(y, bb.min[1], bb.max[1])),
                    Num.f(lerp(z, bb.min[2], bb.max[2]) + z_offset),
                };
                if (try firstBlock(region, origin, point, budget) == null) hits += 1;
                checks += 1;
            }
        }
    }
    return if (checks > 0.0) hits / checks else 0.0;
}

fn lerp(scale: f64, a: f64, b: f64) f64 {
    return a + scale * (b - a);
}

const testing = std.testing;

fn nv(x: f64, y: f64, z: f64) NumVec {
    return .{ Num.f(x), Num.f(y), Num.f(z) };
}

/// Checks every box, the slow way a trace has to agree with.
fn nearest(boxes: []const Box, start: NumVec, end: NumVec) ?BoxHit {
    var best: ?BoxHit = null;
    var distance: f64 = geom.php_int_max_f;
    for (boxes) |b| {
        const h = geom.calculateIntercept(b, start, end) orelse continue;
        const d = geom.distanceSquaredNum(start, h.hit);
        if (d < distance) {
            best = .{ .face = h.face, .hit = h.hit, .box = b };
            distance = d;
        }
    }
    return best;
}

fn testRegion() !Region {
    var r = Region.init(testing.allocator, 64);
    errdefer r.deinit();
    try r.fillBox(.{ -2, -2, -2 }, .{ 12, 6, 6 }, .none);
    return r;
}

test "first block hit stops at the first intercepting voxel" {
    var r = try testRegion();
    defer r.deinit();
    var budget = Budget{};
    try r.setCell(5, 1, 1, .cube, &.{});
    try r.setCell(8, 1, 1, .cube, &.{});
    const h = (try firstBlock(&r, nv(0.5, 1.5, 1.5), nv(10.5, 1.5, 1.5), &budget)).?;
    try testing.expectEqual([3]i64{ 5, 1, 1 }, h.cell);
    try testing.expectEqual(geom.facing.west, h.hit.face);
    try testing.expectEqual(@as(f64, 5), h.hit.hit[0]);
}

test "partial shapes can be missed" {
    var r = try testRegion();
    defer r.deinit();
    var budget = Budget{};
    try r.setCell(5, 1, 1, .custom, &.{Box.init(5, 1, 1, 6, 1.5, 2)});
    try testing.expect(try firstBlock(&r, nv(0.5, 1.75, 1.5), nv(10.5, 1.75, 1.5), &budget) == null);
    try testing.expect(try firstBlock(&r, nv(0.5, 1.25, 1.5), nv(10.5, 1.25, 1.5), &budget) != null);
}

test "exposure counts obstructed samples" {
    var r = try testRegion();
    defer r.deinit();
    var budget = Budget{};
    const bb = Box.init(4.7, 1, 1.2, 5.3, 2.8, 1.8);
    try testing.expectEqual(@as(f64, 1.0), try exposure(&r, nv(0.5, 1.5, 1.5), bb, &budget));
    var z: i64 = -2;
    while (z <= 6) : (z += 1) {
        var y: i64 = -2;
        while (y <= 6) : (y += 1) try r.setCell(2, y, z, .cube, &.{});
    }
    try testing.expectEqual(@as(f64, 0.0), try exposure(&r, nv(0.5, 1.5, 1.5), bb, &budget));
    try testing.expectError(error.TooManySamples, exposure(&r, nv(0.5, 1.5, 1.5), Box.init(0, 0, 0, 1e6, 1, 1), &budget));
}

test "unknown voxels on the path are errors" {
    var r = try testRegion();
    defer r.deinit();
    var budget = Budget{};
    try r.invalidateCell(3, 1, 1);
    try testing.expectError(error.UnknownCell, firstBlock(&r, nv(0.5, 1.5, 1.5), nv(10.5, 1.5, 1.5), &budget));
    try r.setCell(3, 1, 1, .none, &.{});
    try testing.expectError(error.UnknownCell, firstBlock(&r, nv(0.5, 1.5, 1.5), nv(100.5, 1.5, 1.5), &budget));
    try testing.expectError(error.OutOfRange, firstBlock(&r, nv(1e12, 1.5, 1.5), nv(0.5, 1.5, 1.5), &budget));
    try testing.expectError(error.NotFinite, firstBlock(&r, nv(0.5, 1.5, 1.5), nv(std.math.inf(f64), 1.5, 1.5), &budget));
    try testing.expectError(error.NotFinite, firstBlock(&r, nv(std.math.nan(f64), 1.5, 1.5), nv(3, 1.5, 1.5), &budget));
}

const fence = Box.init(5.375, 1, 1.375, 5.625, 2.5, 1.625);

test "a box overflowing into the voxel above is hit there" {
    var r = try testRegion();
    defer r.deinit();
    var budget = Budget{};
    try r.setCell(5, 1, 1, .may_overflow, &.{fence});
    const h = (try firstBlock(&r, nv(0.5, 2.25, 1.5), nv(10.5, 2.25, 1.5), &budget)).?;
    try testing.expectEqual([3]i64{ 5, 1, 1 }, h.cell);
    try testing.expectEqual(geom.facing.west, h.hit.face);
    try testing.expectEqual(@as(f64, 5.375), h.hit.hit[0]);
    try testing.expect(try firstBlock(&r, nv(0.5, 2.75, 1.5), nv(10.5, 2.75, 1.5), &budget) == null);
    // Straight down onto the top of the post.
    const top = (try firstBlock(&r, nv(5.5, 4.5, 1.5), nv(5.5, 0.5, 1.5), &budget)).?;
    try testing.expectEqual(geom.facing.up, top.hit.face);
    try testing.expectEqual(@as(f64, 2.5), top.hit.hit[1]);
    // Starting inside the overflowing part finds the way out.
    const out = (try firstBlock(&r, nv(5.5, 2.2, 1.5), nv(9.5, 2.2, 1.5), &budget)).?;
    try testing.expectEqual([3]i64{ 5, 1, 1 }, out.cell);
    try testing.expectEqual(@as(f64, 5.625), out.hit.hit[0]);
}

test "a nearer box in a later voxel beats an overflowing one from an earlier voxel" {
    var r = try testRegion();
    defer r.deinit();
    var budget = Budget{};
    try r.setCell(5, 1, 1, .may_overflow, &.{fence});
    const sliver = Box.init(5.65, 2, 1, 5.9, 2.02, 2);
    try r.setCell(5, 2, 1, .custom, &.{sliver});
    // Passes beside the post in its own voxel, then meets the sliver before the post's upper half.
    const h = (try firstBlock(&r, nv(5.9, 1.9, 1.5), nv(5.1, 2.3, 1.5), &budget)).?;
    try testing.expectEqual([3]i64{ 5, 2, 1 }, h.cell);
    try testing.expectEqual(sliver, h.hit.box);
    try r.setCell(5, 2, 1, .none, &.{});
    const post = (try firstBlock(&r, nv(5.9, 1.9, 1.5), nv(5.1, 2.3, 1.5), &budget)).?;
    try testing.expectEqual([3]i64{ 5, 1, 1 }, post.cell);
    try testing.expectEqual(geom.facing.east, post.hit.face);
}

test "overflow is found across section corners" {
    var r = Region.init(testing.allocator, 64);
    defer r.deinit();
    try r.fillBox(.{ 10, 10, 10 }, .{ 20, 20, 20 }, .none);
    try r.setCell(15, 15, 15, .custom, &.{Box.init(15.5, 15.5, 15.5, 16.5, 16.5, 16.5)});
    var budget = Budget{};
    const h = (try firstBlock(&r, nv(16.2, 16.2, 17.5), nv(16.2, 16.2, 16.1), &budget)).?;
    try testing.expectEqual([3]i64{ 15, 15, 15 }, h.cell);
    try testing.expectEqual(geom.facing.south, h.hit.face);
    try testing.expectEqual(@as(f64, 16.5), h.hit.hit[2]);
}

test "traces agree with checking every box" {
    var prng = std.Random.DefaultPrng.init(99);
    const rand = prng.random();
    var r = Region.init(testing.allocator, 64);
    defer r.deinit();
    try r.fillBox(.{ -4, -4, -4 }, .{ 20, 20, 20 }, .none);
    var all: std.ArrayList(Box) = .empty;
    defer all.deinit(testing.allocator);
    var x: i64 = 0;
    while (x < 16) : (x += 1) {
        var y: i64 = 0;
        while (y < 16) : (y += 1) {
            var z: i64 = 0;
            while (z < 16) : (z += 1) {
                const roll = rand.uintLessThan(u8, 100);
                if (roll >= 12) continue;
                if (roll < 3) {
                    try r.setCell(x, y, z, .cube, &.{});
                    try all.append(testing.allocator, Box.unitAt(x, y, z));
                    continue;
                }
                // Up to a block outside the cell on any side.
                const reach: f64 = if (roll < 8) 0 else 1;
                var b: Box = undefined;
                const base = [3]f64{ @floatFromInt(x), @floatFromInt(y), @floatFromInt(z) };
                inline for (0..3) |a| {
                    const p = base[a] - reach + rand.float(f64) * (1 + 2 * reach);
                    const q = base[a] - reach + rand.float(f64) * (1 + 2 * reach);
                    b.min[a] = @min(p, q);
                    b.max[a] = @max(p, q);
                }
                try r.setCell(x, y, z, .custom, &.{b});
                try all.append(testing.allocator, b);
            }
        }
    }
    var hits: usize = 0;
    for (0..4000) |_| {
        var p: [6]f64 = undefined;
        for (&p) |*v| v.* = 1 + rand.float(f64) * 14;
        const start = nv(p[0], p[1], p[2]);
        const end = nv(p[3], p[4], p[5]);
        var budget = Budget{};
        const got = try firstBlock(&r, start, end, &budget);
        const want = nearest(all.items, start, end);
        try testing.expectEqual(want == null, got == null);
        if (want) |w| {
            hits += 1;
            try testing.expectApproxEqAbs(geom.distanceSquaredNum(start, w.hit), geom.distanceSquaredNum(start, got.?.hit.hit), 1e-9);
        }
    }
    try testing.expect(hits > 1000);
}

test "the step budget is shared and bounded" {
    var r = try testRegion();
    defer r.deinit();
    var budget = Budget{ .left = 5 };
    try testing.expectError(error.TooManySteps, firstBlock(&r, nv(0.5, 1.5, 1.5), nv(10.5, 1.5, 1.5), &budget));
    budget = .{ .left = 11 };
    try testing.expect(try firstBlock(&r, nv(0.5, 1.5, 1.5), nv(10.5, 1.5, 1.5), &budget) == null);
    try testing.expectEqual(@as(u64, 0), budget.left);
    try testing.expectError(error.TooManySteps, firstBlock(&r, nv(0.5, 1.5, 1.5), nv(1.5, 1.5, 1.5), &budget));
}
