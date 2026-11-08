//! Entity motion formulas from Quark, kept in their original operation order.

const std = @import("std");
const num = @import("num.zig");
const Num = num.Num;
const NumVec = @import("geom.zig").NumVec;

const libm = @import("libm.zig");
const sin = libm.sinFn;
const cos = libm.cosFn;
const atan2 = libm.atan2Fn;
const fmod = libm.fmodFn;
const pow = libm.powFn;

pub const pi: f64 = 3.14159265358979323846;
pub const pi_2: f64 = 1.57079632679489661923;

/// PHP deg2rad()
pub fn deg2rad(deg: f64) f64 {
    return (deg / 180.0) * pi;
}

pub const MotionParams = struct {
    drag: f64,
    gravity: f64,
    gravity_enabled: bool = true,
    drag_before_gravity: bool = false,
    ground_friction: f64 = 1.0,
    threshold: f64 = 0.00001,
};

/// Entity::tryChangeMovement() then the MOTION_THRESHOLD clamp from Entity::onUpdate().
/// Clamped components become int 0 like withComponents(0, ...).
pub fn motionStep(m: NumVec, p: MotionParams) NumVec {
    var friction = 1 - p.drag;
    var my = m[1];
    if (p.drag_before_gravity) my = Num.f(my.toFloat() * friction);
    if (p.gravity_enabled) my = my.sub(Num.f(p.gravity));
    if (!p.drag_before_gravity) my = Num.f(my.toFloat() * friction);
    friction *= p.ground_friction;
    var r = NumVec{ Num.f(m[0].toFloat() * friction), my, Num.f(m[2].toFloat() * friction) };
    inline for (0..3) |a| {
        if (r[a].abs().toFloat() <= p.threshold) r[a] = Num.i(0);
    }
    return r;
}

/// Living::knockBack() after the resistance roll. Null when the direction has no length.
pub fn knockBack(m: NumVec, x: f64, z: f64, force: f64, vertical_limit: ?f64) ?NumVec {
    var f = @sqrt(x * x + z * z);
    if (f <= 0) return null;
    f = 1 / f;
    var mx = m[0].toFloat() / 2;
    var my = m[1].toFloat() / 2;
    var mz = m[2].toFloat() / 2;
    mx += x * f * force;
    my += force;
    mz += z * f * force;
    const limit = vertical_limit orelse force;
    if (my > limit) my = limit;
    return .{ Num.f(mx), Num.f(my), Num.f(mz) };
}

/// Vector3::normalize()
pub fn normalize(v: NumVec) NumVec {
    const len = v[0].mul(v[0]).add(v[1].mul(v[1])).add(v[2].mul(v[2]));
    if (len.toFloat() > 0) {
        const s = @sqrt(len.toFloat());
        return .{ Num.f(v[0].toFloat() / s), Num.f(v[1].toFloat() / s), Num.f(v[2].toFloat() / s) };
    }
    return .{ Num.i(0), Num.i(0), Num.i(0) };
}

/// Entity::getDirectionVector()
pub fn directionVector(yaw: f64, pitch: f64) NumVec {
    const y = num.negf(sin(deg2rad(pitch)));
    const xz = cos(deg2rad(pitch));
    const x = num.negf(xz) * sin(deg2rad(yaw));
    const z = xz * cos(deg2rad(yaw));
    return normalize(.{ Num.f(x), Num.f(y), Num.f(z) });
}

/// Entity::getDirectionPlane() before Vector2 wrapping.
pub fn directionPlane(yaw: f64) [2]f64 {
    const x = num.negf(cos(deg2rad(yaw) - pi_2));
    const y = num.negf(sin(deg2rad(yaw) - pi_2));
    const len = x * x + y * y;
    if (len > 0) {
        const s = @sqrt(len);
        return .{ x / s, y / s };
    }
    return .{ 0, 0 };
}

/// Entity::getHorizontalFacing()
pub fn horizontalFacing(yaw: f64) i64 {
    var angle = fmod(yaw, 360);
    if (angle < 0) angle += 360.0;
    if ((0 <= angle and angle < 45) or (315 <= angle and angle < 360)) return 3; // south
    if (45 <= angle and angle < 135) return 4; // west
    if (135 <= angle and angle < 225) return 2; // north
    return 5; // east
}

fn square(v: Num) Num {
    return switch (v) {
        .int => v.mul(v),
        .float => |f| Num.f(pow(f, 2)),
    };
}

/// Living::lookAt() with the eye position already offset.
pub fn lookAt(eye: NumVec, target: NumVec) [2]f64 {
    const x_dist = target[0].sub(eye[0]);
    const z_dist = target[2].sub(eye[2]);
    const horizontal = @sqrt(square(x_dist).add(square(z_dist)).toFloat());
    const vertical = target[1].sub(eye[1]).toFloat();
    const pitch = num.negf(atan2(vertical, horizontal)) / pi * 180;
    var yaw = atan2(z_dist.toFloat(), x_dist.toFloat()) / pi * 180 - 90;
    if (yaw < 0) yaw += 360.0;
    return .{ yaw, pitch };
}

/// Rotation set by Projectile::move() when nothing was hit.
pub fn motionRotation(m: NumVec) [2]f64 {
    const horizontal = @sqrt(square(m[0]).add(square(m[2])).toFloat());
    return .{
        atan2(m[0].toFloat(), m[2].toFloat()) * 180 / pi,
        atan2(m[1].toFloat(), horizontal) * 180 / pi,
    };
}

const testing = std.testing;

test "drag order changes the vertical result" {
    const m = NumVec{ Num.f(0.5), Num.f(0.2), Num.f(0) };
    const y: f64 = 0.2;
    const drag: f64 = 0.02;
    const gravity: f64 = 0.08;
    const after = motionStep(m, .{ .drag = drag, .gravity = gravity });
    try testing.expectEqual((y - gravity) * (1 - drag), after[1].toFloat());
    const before = motionStep(m, .{ .drag = drag, .gravity = gravity, .drag_before_gravity = true });
    try testing.expectEqual(y * (1 - drag) - gravity, before[1].toFloat());
    try testing.expectEqual(Num.i(0), after[2]);
}

test "knockback caps vertical speed" {
    const r = knockBack(.{ Num.f(0), Num.f(1), Num.f(0) }, 1, 0, 0.4, 0.4).?;
    try testing.expectEqual(@as(f64, 0.4), r[0].toFloat());
    try testing.expectEqual(@as(f64, 0.4), r[1].toFloat());
    try testing.expect(knockBack(.{ Num.f(0), Num.f(0), Num.f(0) }, 0, 0, 0.4, null) == null);
}

test "direction helpers" {
    const d = directionVector(0, 0);
    try testing.expectApproxEqAbs(@as(f64, 1), d[2].toFloat(), 1e-12);
    try testing.expectEqual(@as(i64, 3), horizontalFacing(-360));
    try testing.expectEqual(@as(i64, 4), horizontalFacing(90));
    const la = lookAt(.{ Num.f(0), Num.f(0), Num.f(0) }, .{ Num.f(0), Num.f(0), Num.f(5) });
    try testing.expectApproxEqAbs(@as(f64, 0), la[0], 1e-9);
}
