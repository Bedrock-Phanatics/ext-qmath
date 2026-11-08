//! VoxelRayTrace::betweenPoints() as a resumable iterator.
//! The first voxel is floor(start); boundary ties are crossed in Z, Y, X order like QuarkMath.

const std = @import("std");
const num = @import("num.zig");
const Num = num.Num;
const NumVec = @import("geom.zig").NumVec;

pub const Error = error{ZeroLength};

pub const zero_length_message = "Start and end points are the same, giving a zero direction vector";

pub const Ray = struct {
    block: NumVec,
    t_max: [3]f64,
    t_delta: [3]f64,
    step: [3]i64,
    radius: f64,
    done: bool = false,

    pub fn init(start: NumVec, end: NumVec) Error!Ray {
        var block: NumVec = undefined;
        inline for (0..3) |a| block[a] = Num.i(num.floorInt(start[a]));

        // $end->subtractVector($start)->normalize()
        var diff: NumVec = undefined;
        inline for (0..3) |a| diff[a] = end[a].add(start[a].neg());
        const len_sq = diff[0].mul(diff[0]).add(diff[1].mul(diff[1])).add(diff[2].mul(diff[2]));
        if (!(len_sq.toFloat() > 0)) return error.ZeroLength;
        const len = @sqrt(len_sq.toFloat());
        var dir: [3]f64 = undefined;
        inline for (0..3) |a| dir[a] = diff[a].toFloat() / len;
        if (dir[0] * dir[0] + dir[1] * dir[1] + dir[2] * dir[2] <= 0) return error.ZeroLength;

        // $start->distance($end)
        var dist = Num.i(0);
        inline for (0..3) |a| {
            const d = start[a].sub(end[a]);
            dist = if (a == 0) d.mul(d) else dist.add(d.mul(d));
        }

        var ray: Ray = .{
            .block = block,
            .t_max = undefined,
            .t_delta = undefined,
            .step = undefined,
            .radius = @sqrt(dist.toFloat()),
        };
        inline for (0..3) |a| {
            ray.step[a] = num.spaceshipZero(dir[a]);
            ray.t_max[a] = distanceFactorToBoundary(start[a].toFloat(), dir[a]);
            ray.t_delta[a] = if (dir[a] == 0.0) 0 else @as(f64, @floatFromInt(ray.step[a])) / dir[a];
        }
        return ray;
    }

    /// Moves to the next voxel. Returns false once the ray has passed its end, leaving `block` unchanged.
    pub fn advance(self: *Ray) bool {
        if (self.done) return false;
        const axis: usize = if (self.t_max[0] < self.t_max[1] and self.t_max[0] < self.t_max[2])
            0
        else if (self.t_max[1] < self.t_max[2])
            1
        else
            2;
        if (self.t_max[axis] > self.radius) {
            self.done = true;
            return false;
        }
        self.block[axis] = self.block[axis].add(Num.i(self.step[axis]));
        self.t_max[axis] += self.t_delta[axis];
        return true;
    }

    /// Integer cell coordinates, or null if a coordinate overflowed to float.
    pub fn cell(self: *const Ray) ?[3]i64 {
        var r: [3]i64 = undefined;
        inline for (0..3) |a| {
            if (self.block[a] != .int) return null;
            r[a] = self.block[a].int;
        }
        return r;
    }
};

fn distanceFactorToBoundary(s: f64, ds: f64) f64 {
    if (ds == 0.0) return std.math.inf(f64);
    return if (ds < 0)
        (s - @floor(s)) / num.negf(ds)
    else
        (1 - (s - @floor(s))) / ds;
}

const testing = std.testing;

fn nv(x: f64, y: f64, z: f64) NumVec {
    return .{ Num.f(x), Num.f(y), Num.f(z) };
}

fn collect(start: NumVec, end: NumVec, out: [][3]i64) !usize {
    var ray = try Ray.init(start, end);
    var n: usize = 0;
    while (true) {
        out[n] = ray.cell().?;
        n += 1;
        if (!ray.advance()) break;
    }
    return n;
}

test "straight line visits each voxel once" {
    var buf: [16][3]i64 = undefined;
    const n = try collect(nv(0.5, 0.5, 0.5), nv(3.5, 0.5, 0.5), &buf);
    try testing.expectEqual(@as(usize, 4), n);
    try testing.expectEqual([3]i64{ 3, 0, 0 }, buf[3]);
}

test "negative coordinates floor correctly" {
    var buf: [16][3]i64 = undefined;
    const n = try collect(nv(-0.5, 0.5, 0.5), nv(-2.5, 0.5, 0.5), &buf);
    try testing.expectEqual(@as(usize, 3), n);
    try testing.expectEqual([3]i64{ -1, 0, 0 }, buf[0]);
    try testing.expectEqual([3]i64{ -3, 0, 0 }, buf[2]);
}

test "diagonal corner prefers z then y then x" {
    var buf: [16][3]i64 = undefined;
    _ = try collect(nv(0.5, 0.5, 0.5), nv(1.5, 1.5, 1.5), &buf);
    try testing.expectEqual([3]i64{ 0, 0, 1 }, buf[1]);
    try testing.expectEqual([3]i64{ 0, 1, 1 }, buf[2]);
    try testing.expectEqual([3]i64{ 1, 1, 1 }, buf[3]);
}

test "zero length rays are rejected" {
    try testing.expectError(error.ZeroLength, Ray.init(nv(1, 2, 3), nv(1, 2, 3)));
    try testing.expectError(error.ZeroLength, Ray.init(nv(std.math.nan(f64), 0, 0), nv(1, 2, 3)));
}

test "taxicab steps of one" {
    var buf: [64][3]i64 = undefined;
    const n = try collect(nv(0.1, 0.2, 0.3), nv(7.9, -3.4, 5.5), &buf);
    for (1..n) |k| {
        var d: i64 = 0;
        inline for (0..3) |a| d += @intCast(@abs(buf[k][a] - buf[k - 1][a]));
        try testing.expectEqual(@as(i64, 1), d);
    }
    try testing.expectEqual([3]i64{ 7, -4, 5 }, buf[n - 1]);
}
