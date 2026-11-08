//! Segment queries against block collision data.

const std = @import("std");
const geom = @import("geom.zig");
const voxel = @import("voxel.zig");
const collision = @import("collision.zig");
const Num = @import("num.zig").Num;
const Box = geom.Box;
const Vec = geom.Vec;
const NumVec = geom.NumVec;
const Region = collision.Region;

pub const Error = collision.Error || voxel.Error || error{TooManySamples};

pub const BoxHit = struct {
    face: i64,
    hit: Vec,
    box: Box,
    index: usize,
};

/// Block::calculateIntercept(): the nearest intercept among `boxes`.
pub fn nearest(boxes: []const Box, start: NumVec, end: NumVec) ?BoxHit {
    var best: ?BoxHit = null;
    var distance: f64 = geom.php_int_max_f;
    for (boxes, 0..) |b, i| {
        const h = geom.calculateIntercept(b, start, end) orelse continue;
        const d = geom.distanceSquaredNum(start, h.hit);
        if (d < distance) {
            best = .{ .face = h.face, .hit = h.hit, .box = b, .index = i };
            distance = d;
        }
    }
    return best;
}

pub const BlockHit = struct {
    cell: [3]i64,
    hit: BoxHit,
};

/// The block pass of Projectile::move(): walks voxels in VoxelRayTrace order and stops at the first
/// voxel whose own collision boxes intercept the segment.
pub fn firstBlock(region: *const Region, start: NumVec, end: NumVec) Error!?BlockHit {
    var ray = try voxel.Ray.init(start, end);
    var scratch: Box = undefined;
    while (true) {
        const c = ray.cell() orelse return error.OutOfRange;
        const boxes = try region.ownBoxes(c[0], c[1], c[2], &scratch);
        if (nearest(boxes, start, end)) |h| return .{ .cell = c, .hit = h };
        if (!ray.advance()) return null;
    }
}

const max_samples_per_axis = 1024;

/// Explosion::getExposure(): the fraction of sample points in `bb` with an unobstructed line to `origin`.
pub fn exposure(region: *const Region, origin: NumVec, bb: Box) Error!f64 {
    // (new Vector3($xLen, $yLen, $zLen))->multiply(2)->add(1, 1, 1)
    var diff: Vec = undefined;
    var step: Vec = undefined;
    inline for (0..3) |a| {
        diff[a] = (bb.max[a] - bb.min[a]) * 2.0 + 1.0;
        if (!(diff[a] <= max_samples_per_axis)) return error.TooManySamples;
        step[a] = 1.0 / diff[a];
    }
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
                if (try firstBlock(region, origin, point) == null) hits += 1;
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

fn testRegion() !Region {
    var r = try Region.init(testing.allocator, .{ -2, -2, -2 }, .{ 12, 6, 6 });
    errdefer r.deinit();
    try r.fill(.none);
    return r;
}

test "first block hit stops at the first intercepting voxel" {
    var r = try testRegion();
    defer r.deinit();
    try r.setCell(5, 1, 1, .cube, &.{});
    try r.setCell(8, 1, 1, .cube, &.{});
    const h = (try firstBlock(&r, nv(0.5, 1.5, 1.5), nv(10.5, 1.5, 1.5))).?;
    try testing.expectEqual([3]i64{ 5, 1, 1 }, h.cell);
    try testing.expectEqual(geom.facing.west, h.hit.face);
    try testing.expectEqual(@as(f64, 5), h.hit.hit[0]);
}

test "partial shapes can be missed" {
    var r = try testRegion();
    defer r.deinit();
    try r.setCell(5, 1, 1, .custom, &.{Box.init(5, 1, 1, 6, 1.5, 2)});
    try testing.expect(try firstBlock(&r, nv(0.5, 1.75, 1.5), nv(10.5, 1.75, 1.5)) == null);
    try testing.expect(try firstBlock(&r, nv(0.5, 1.25, 1.5), nv(10.5, 1.25, 1.5)) != null);
}

test "exposure counts obstructed samples" {
    var r = try testRegion();
    defer r.deinit();
    const bb = Box.init(4.7, 1, 1.2, 5.3, 2.8, 1.8);
    try testing.expectEqual(@as(f64, 1.0), try exposure(&r, nv(0.5, 1.5, 1.5), bb));
    var z: i64 = -2;
    while (z <= 6) : (z += 1) {
        var y: i64 = -2;
        while (y <= 6) : (y += 1) try r.setCell(2, y, z, .cube, &.{});
    }
    try testing.expectEqual(@as(f64, 0.0), try exposure(&r, nv(0.5, 1.5, 1.5), bb));
    try testing.expectError(error.TooManySamples, exposure(&r, nv(0.5, 1.5, 1.5), Box.init(0, 0, 0, 1e6, 1, 1)));
}

test "unknown voxels on the path are errors" {
    var r = try testRegion();
    defer r.deinit();
    try r.invalidateCell(3, 1, 1);
    try testing.expectError(error.UnknownCell, firstBlock(&r, nv(0.5, 1.5, 1.5), nv(10.5, 1.5, 1.5)));
    try r.setCell(3, 1, 1, .none, &.{});
    try testing.expectError(error.OutOfRange, firstBlock(&r, nv(0.5, 1.5, 1.5), nv(100.5, 1.5, 1.5)));
}
