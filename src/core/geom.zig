//! Axes are 0 = x, 1 = y, 2 = z, facing values use QuarkMath's encoding.

const std = @import("std");
const Num = @import("num.zig").Num;

pub const Vec = [3]f64;
pub const NumVec = [3]Num;

pub const facing = struct {
    pub const down: i64 = 0;
    pub const up: i64 = 1;
    pub const north: i64 = 2;
    pub const south: i64 = 3;
    pub const west: i64 = 4;
    pub const east: i64 = 5;

    pub const offsets = [6][3]i64{ .{ 0, -1, 0 }, .{ 0, 1, 0 }, .{ 0, 0, -1 }, .{ 0, 0, 1 }, .{ -1, 0, 0 }, .{ 1, 0, 0 } };

    pub fn ofAxis(axis: usize, positive: bool) i64 {
        const neg = [3]i64{ west, down, north };
        return neg[axis] + @intFromBool(positive);
    }
};

pub const default_epsilon = 0.00001;

pub const Box = struct {
    min: Vec,
    max: Vec,

    pub fn init(min_x: f64, min_y: f64, min_z: f64, max_x: f64, max_y: f64, max_z: f64) Box {
        return .{ .min = .{ min_x, min_y, min_z }, .max = .{ max_x, max_y, max_z } };
    }

    pub fn unitAt(x: i64, y: i64, z: i64) Box {
        const fx: f64 = @floatFromInt(x);
        const fy: f64 = @floatFromInt(y);
        const fz: f64 = @floatFromInt(z);
        return init(0.0 + fx, 0.0 + fy, 0.0 + fz, 1.0 + fx, 1.0 + fy, 1.0 + fz);
    }

    pub fn isValid(self: Box) bool {
        inline for (0..3) |a| {
            if (!std.math.isFinite(self.min[a]) or !std.math.isFinite(self.max[a])) return false;
            if (self.min[a] > self.max[a]) return false;
        }
        return true;
    }

    pub fn addCoord(self: Box, d: Vec) Box {
        var r = self;
        inline for (0..3) |a| {
            if (d[a] < 0) {
                r.min[a] += d[a];
            } else if (d[a] > 0) {
                r.max[a] += d[a];
            }
        }
        return r;
    }

    pub fn offset(self: Box, d: Vec) Box {
        var r = self;
        inline for (0..3) |a| {
            r.min[a] += d[a];
            r.max[a] += d[a];
        }
        return r;
    }

    pub fn offsetAxis(self: Box, comptime axis: usize, d: f64) Box {
        var r = self;
        r.min[axis] += d;
        r.max[axis] += d;
        return r;
    }

    pub fn expand(self: Box, d: Vec) Box {
        var r = self;
        inline for (0..3) |a| {
            r.min[a] -= d[a];
            r.max[a] += d[a];
        }
        return r;
    }

    /// `self` is the obstacle, `bb` the moving box.
    pub fn calculateOffset(self: Box, comptime axis: usize, bb: Box, d_in: f64) f64 {
        const o1 = (axis + 1) % 3;
        const o2 = (axis + 2) % 3;
        // QuarkMath checks the other axes in a different order but the result is the same.
        if (bb.max[o1] <= self.min[o1] or bb.min[o1] >= self.max[o1]) return d_in;
        if (bb.max[o2] <= self.min[o2] or bb.min[o2] >= self.max[o2]) return d_in;
        var d = d_in;
        if (d > 0 and bb.max[axis] <= self.min[axis]) {
            const d1 = self.min[axis] - bb.max[axis];
            if (d1 < d) d = d1;
        } else if (d < 0 and bb.min[axis] >= self.max[axis]) {
            const d2 = self.max[axis] - bb.min[axis];
            if (d2 > d) d = d2;
        }
        return d;
    }

    pub fn intersects(self: Box, bb: Box, epsilon: f64) bool {
        if (bb.max[0] - self.min[0] > epsilon and self.max[0] - bb.min[0] > epsilon) {
            if (bb.max[1] - self.min[1] > epsilon and self.max[1] - bb.min[1] > epsilon) {
                return bb.max[2] - self.min[2] > epsilon and self.max[2] - bb.min[2] > epsilon;
            }
        }
        return false;
    }

    pub fn isVectorInside(self: Box, v: Vec) bool {
        if (v[0] <= self.min[0] or v[0] >= self.max[0]) return false;
        if (v[1] <= self.min[1] or v[1] >= self.max[1]) return false;
        return v[2] > self.min[2] and v[2] < self.max[2];
    }

    /// Closed bounds on the two axes other than `skip`.
    pub fn isVectorInPlane(self: Box, comptime skip: usize, v: Vec) bool {
        const a = (skip + 1) % 3;
        const b = (skip + 2) % 3;
        const lo = @min(a, b);
        const hi = @max(a, b);
        return v[lo] >= self.min[lo] and v[lo] <= self.max[lo] and v[hi] >= self.min[hi] and v[hi] <= self.max[hi];
    }

    pub fn closestPoint(self: Box, p: Vec) Vec {
        var r: Vec = undefined;
        inline for (0..3) |a| r[a] = @min(@max(p[a], self.min[a]), self.max[a]);
        return r;
    }

    pub fn distanceSquaredTo(self: Box, p: Vec) f64 {
        const c = self.closestPoint(p);
        const dx = p[0] - c[0];
        const dy = p[1] - c[1];
        const dz = p[2] - c[2];
        return dx * dx + dy * dy + dz * dz;
    }

    pub fn intersectsSegment(self: Box, start: Vec, end: Vec) bool {
        var t0: f64 = 0.0;
        var t1: f64 = 1.0;
        inline for (0..3) |a| {
            const d = end[a] - start[a];
            if (d == 0) {
                if (start[a] < self.min[a] or start[a] > self.max[a]) return false;
            } else {
                var ta = (self.min[a] - start[a]) / d;
                var tb = (self.max[a] - start[a]) / d;
                if (ta > tb) std.mem.swap(f64, &ta, &tb);
                t0 = @max(t0, ta);
                t1 = @min(t1, tb);
                if (t0 > t1) return false;
            }
        }
        return true;
    }

    pub fn union_(self: Box, other: Box) Box {
        var r: Box = undefined;
        inline for (0..3) |a| {
            r.min[a] = @min(self.min[a], other.min[a]);
            r.max[a] = @max(self.max[a], other.max[a]);
        }
        return r;
    }
};

pub fn numVecToFloat(v: NumVec) Vec {
    return .{ v[0].toFloat(), v[1].toFloat(), v[2].toFloat() };
}

/// Point on from..to whose `axis` component equals `value`.
pub fn intermediate(comptime axis: usize, from: NumVec, to: NumVec, value: f64) ?Vec {
    const diff = to[axis].sub(from[axis]);
    const sq = diff.mul(diff);
    if (sq.toFloat() < 0.0000001) return null;
    const f = (value - from[axis].toFloat()) / diff.toFloat();
    if (f < 0 or f > 1) return null;
    var r: Vec = undefined;
    inline for (0..3) |a| {
        if (a == axis) {
            r[a] = value;
        } else {
            // $this->a + ($v->a - $this->a) * $f
            r[a] = from[a].add(Num.f(to[a].sub(from[a]).toFloat() * f)).toFloat();
        }
    }
    return r;
}

pub const Intercept = struct {
    face: i64,
    hit: Vec,
};

/// (double) PHP_INT_MAX, QuarkMath's initial "no hit" distance.
pub const php_int_max_f: f64 = 9223372036854775807.0;

pub fn distanceSquaredNum(a: NumVec, b: Vec) f64 {
    const dx = a[0].sub(Num.f(b[0])).toFloat();
    const dy = a[1].sub(Num.f(b[1])).toFloat();
    const dz = a[2].sub(Num.f(b[2])).toFloat();
    return (dx * dx) + (dy * dy) + (dz * dz);
}

pub fn calculateIntercept(box: Box, pos1: NumVec, pos2: NumVec) ?Intercept {
    var v: [6]?Vec = .{
        intermediate(0, pos1, pos2, box.min[0]),
        intermediate(0, pos1, pos2, box.max[0]),
        intermediate(1, pos1, pos2, box.min[1]),
        intermediate(1, pos1, pos2, box.max[1]),
        intermediate(2, pos1, pos2, box.min[2]),
        intermediate(2, pos1, pos2, box.max[2]),
    };
    inline for (0..6) |idx| {
        if (v[idx]) |p| {
            const ok = switch (idx / 2) {
                0 => box.isVectorInPlane(0, p),
                1 => box.isVectorInPlane(1, p),
                else => box.isVectorInPlane(2, p),
            };
            if (!ok) v[idx] = null;
        }
    }
    const faces = [6]i64{ facing.west, facing.east, facing.down, facing.up, facing.north, facing.south };
    var best: ?Intercept = null;
    var distance: f64 = php_int_max_f;
    for (v, faces) |maybe, f| {
        if (maybe) |p| {
            const d = distanceSquaredNum(pos1, p);
            if (d < distance) {
                best = .{ .face = f, .hit = p };
                distance = d;
            }
        }
    }
    return best;
}

pub const Sweep = struct {
    time: f64,
    /// Facing of the hit surface, -1 when the boxes already overlap.
    face: i64,
};

/// Touching boxes count as contact. Equal entry times pick x, then y, then z.
pub fn sweep(moving: Box, d: Vec, obstacle: Box) ?Sweep {
    var entry: f64 = -std.math.inf(f64);
    var exit: f64 = std.math.inf(f64);
    var entry_axis: ?usize = null;
    inline for (0..3) |a| {
        var t_in: f64 = undefined;
        var t_out: f64 = undefined;
        if (d[a] > 0) {
            t_in = (obstacle.min[a] - moving.max[a]) / d[a];
            t_out = (obstacle.max[a] - moving.min[a]) / d[a];
        } else if (d[a] < 0) {
            t_in = (obstacle.max[a] - moving.min[a]) / d[a];
            t_out = (obstacle.min[a] - moving.max[a]) / d[a];
        } else {
            if (moving.max[a] <= obstacle.min[a] or moving.min[a] >= obstacle.max[a]) return null;
            t_in = -std.math.inf(f64);
            t_out = std.math.inf(f64);
        }
        if (t_in > entry) {
            entry = t_in;
            entry_axis = a;
        }
        if (t_out < exit) exit = t_out;
    }
    if (entry >= exit or entry > 1 or exit <= 0) return null;
    if (entry < 0) return .{ .time = 0, .face = -1 };
    const axis = entry_axis.?;
    return .{ .time = entry, .face = facing.ofAxis(axis, d[axis] < 0) };
}

const testing = std.testing;

fn nv(x: f64, y: f64, z: f64) NumVec {
    return .{ Num.f(x), Num.f(y), Num.f(z) };
}

test "calculateOffset clips against obstacles" {
    const floor = Box.init(0, 0, 0, 1, 1, 1);
    const entity = Box.init(0.2, 1.5, 0.2, 0.8, 3.3, 0.8);
    try testing.expectEqual(@as(f64, -0.5), floor.calculateOffset(1, entity, -2.0));
    try testing.expectEqual(@as(f64, -0.25), floor.calculateOffset(1, entity, -0.25));
    const side = Box.init(2, 0, 0, 3, 1, 1);
    try testing.expectEqual(@as(f64, -2.0), side.calculateOffset(1, entity, -2.0));
}

test "intersects uses an exclusive epsilon" {
    const a = Box.init(0, 0, 0, 1, 1, 1);
    try testing.expect(!a.intersects(Box.init(1, 0, 0, 2, 1, 1), default_epsilon));
    try testing.expect(!a.intersects(Box.init(0.999995, 0, 0, 2, 1, 1), default_epsilon));
    try testing.expect(a.intersects(Box.init(0.9, 0, 0, 2, 1, 1), default_epsilon));
}

test "calculateIntercept prefers the nearest face" {
    const box = Box.init(0, 0, 0, 1, 1, 1);
    const hit = calculateIntercept(box, nv(-1, 0.5, 0.5), nv(2, 0.5, 0.5)).?;
    try testing.expectEqual(facing.west, hit.face);
    try testing.expectEqual(@as(f64, 0), hit.hit[0]);
    try testing.expect(calculateIntercept(box, nv(-1, 2, 0.5), nv(2, 2, 0.5)) == null);
}

test "sweep finds time of impact and face" {
    const moving = Box.init(0, 0, 0, 1, 1, 1);
    const wall = Box.init(3, 0, 0, 4, 1, 1);
    const s = sweep(moving, .{ 4, 0, 0 }, wall).?;
    try testing.expectEqual(@as(f64, 0.5), s.time);
    try testing.expectEqual(facing.west, s.face);
    try testing.expect(sweep(moving, .{ 1, 0, 0 }, wall) == null);
    try testing.expect(sweep(moving, .{ 4, 0, 0 }, Box.init(3, 1, 0, 4, 2, 1)) == null);
    // a high velocity that would tunnel with discrete steps is still caught
    const thin = Box.init(50, 0, 0, 50.01, 1, 1);
    try testing.expect(sweep(moving, .{ 1000, 0, 0 }, thin) != null);
    try testing.expectEqual(@as(i64, -1), sweep(moving, .{ 1, 0, 0 }, Box.init(0.5, 0.5, 0.5, 2, 2, 2)).?.face);
}

test "segment and point helpers" {
    const box = Box.init(0, 0, 0, 1, 1, 1);
    try testing.expect(box.intersectsSegment(.{ -1, 0.5, 0.5 }, .{ 2, 0.5, 0.5 }));
    try testing.expect(!box.intersectsSegment(.{ -1, 2, 0.5 }, .{ 2, 2, 0.5 }));
    try testing.expectEqual(@as(f64, 4), box.distanceSquaredTo(.{ 3, 0.5, 0.5 }));
}
