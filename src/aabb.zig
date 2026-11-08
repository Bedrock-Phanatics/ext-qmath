const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const core = rt.core;
const geom = core.geom;
const Box = rt.Box;
const Num = rt.Num;
const Ctx = rt.Ctx;
const Error = rt.Error;
const ZObj = rt.ZObj;
const vector = @import("vector.zig");

pub var bb_ce: rt.Ce = undefined;
pub var rtr_ce: rt.Ce = undefined;
var bb: [6]rt.Prop = undefined;
pub var rtr: [3]rt.Prop = undefined;

const prop_names = [6][]const u8{ "minX", "minY", "minZ", "maxX", "maxY", "maxZ" };

pub fn startup() void {
    bb_ce = rt.cePtr(AxisAlignedBBClass.entry);
    rtr_ce = rt.cePtr(RayTraceResultClass.entry);
    inline for (prop_names, 0..) |n, i| bb[i] = rt.Prop.resolve(bb_ce, n);
    rtr = .{ rt.Prop.resolve(rtr_ce, "bb"), rt.Prop.resolve(rtr_ce, "hitFace"), rt.Prop.resolve(rtr_ce, "hitVector") };
}

pub fn readBox(o: ZObj) Error!Box {
    var r: Box = undefined;
    inline for (0..3) |a| {
        r.min[a] = try rt.readFloat(o, bb[a]);
        r.max[a] = try rt.readFloat(o, bb[a + 3]);
    }
    return r;
}

pub fn argBox(ctx: Ctx, n: u32) Error!Box {
    return readBox(try vector.argObject(ctx, n, bb_ce));
}

fn writeBox(o: ZObj, b: Box) Error!void {
    inline for (0..3) |a| {
        try rt.writeNum(o, bb[a], true, Num.f(b.min[a]));
        try rt.writeNum(o, bb[a + 3], true, Num.f(b.max[a]));
    }
}

/// Skips the constructor's bounds check.
pub fn newBox(out: *c.zval, b: Box) ZObj {
    const o = rt.newObject(out, bb_ce);
    inline for (0..3) |a| {
        rt.setDouble(rt.initSlot(o, bb[a]), b.min[a]);
        rt.setDouble(rt.initSlot(o, bb[a + 3]), b.max[a]);
    }
    return o;
}

fn constructBox(out: *c.zval, b: Box) Error!void {
    try checkBounds(b);
    _ = newBox(out, b);
}

fn checkBounds(b: Box) Error!void {
    const names = [3][]const u8{ "X", "Y", "Z" };
    inline for (0..3) |a| {
        if (b.min[a] > b.max[a]) {
            const lo = rt.NumText.of(Num.f(b.min[a]));
            const hi = rt.NumText.of(Num.f(b.max[a]));
            return rt.invalidArgument("min" ++ names[a] ++ " {s} is larger than max" ++ names[a] ++ " {s}", .{ lo.slice(), hi.slice() });
        }
    }
}

/// Takes its own reference to `box_obj`.
pub fn newRayTraceResult(out: *c.zval, ce: rt.Ce, box_obj: ZObj, face: i64, hit: rt.Vec) ZObj {
    const o = rt.newObject(out, ce);
    rt.retObjectCopy(rt.initSlot(o, rtr[0]), box_obj);
    rt.setLong(rt.initSlot(o, rtr[1]), face);
    vector.newV3Float(rt.initSlot(o, rtr[2]), hit);
    return o;
}

fn self(ctx: Ctx) Error!Box {
    return readBox(rt.this(ctx));
}

fn mutate(ctx: Ctx, b: Box) Error!void {
    const o = rt.this(ctx);
    try writeBox(o, b);
    rt.retObjectCopy(rt.ret(ctx), o);
}

fn cloned(ctx: Ctx, b: Box) Error!void {
    const o = rt.this(ctx);
    const copy = o.handlers.*.clone_obj.?(o) orelse return error.PhpException;
    const out = rt.ret(ctx);
    out.value.obj = copy;
    out.u1.type_info = c.IS_OBJECT_EX;
    if (phpz.exception.hasPending()) return error.PhpException;
    try writeBox(copy, b);
}

fn offsetTowardsBox(b: Box, face: i64, distance: f64) Error!Box {
    if (face < 0 or face > 5) return rt.invalidArgument("Invalid Facing {d}", .{face});
    const o = geom.facing.offsets[@intCast(face)];
    return b.offset(.{ @as(f64, @floatFromInt(o[0])) * distance, @as(f64, @floatFromInt(o[1])) * distance, @as(f64, @floatFromInt(o[2])) * distance });
}

fn extendBox(b_in: Box, face: i64, distance: f64) Error!Box {
    var b = b_in;
    switch (face) {
        geom.facing.down => b.min[1] -= distance,
        geom.facing.up => b.max[1] += distance,
        geom.facing.north => b.min[2] -= distance,
        geom.facing.south => b.max[2] += distance,
        geom.facing.west => b.min[0] -= distance,
        geom.facing.east => b.max[0] += distance,
        else => return rt.invalidArgument("Invalid face {d}", .{face}),
    }
    return b;
}

fn stretchBox(b_in: Box, axis: i64, distance: f64) Error!Box {
    var b = b_in;
    const a: usize = switch (axis) {
        0 => 1,
        1 => 2,
        2 => 0,
        else => return rt.invalidArgument("Invalid axis {d}", .{axis}),
    };
    b.min[a] -= distance;
    b.max[a] += distance;
    return b;
}

fn contractBox(b: Box, d: rt.Vec) Box {
    var r = b;
    inline for (0..3) |a| {
        r.min[a] += d[a];
        r.max[a] -= d[a];
    }
    return r;
}

pub const AxisAlignedBB = struct {
    pub fn __construct(ctx: Ctx, min_x: f64, min_y: f64, min_z: f64, max_x: f64, max_y: f64, max_z: f64) Error!void {
        const b = Box.init(min_x, min_y, min_z, max_x, max_y, max_z);
        try checkBounds(b);
        try writeBox(rt.this(ctx), b);
    }

    pub fn addCoord(ctx: Ctx, x: f64, y: f64, z: f64) Error!void {
        try constructBox(rt.ret(ctx), (try self(ctx)).addCoord(.{ x, y, z }));
    }

    pub fn expand(ctx: Ctx, x: f64, y: f64, z: f64) Error!void {
        try mutate(ctx, (try self(ctx)).expand(.{ x, y, z }));
    }

    pub fn expandedCopy(ctx: Ctx, x: f64, y: f64, z: f64) Error!void {
        try cloned(ctx, (try self(ctx)).expand(.{ x, y, z }));
    }

    pub fn offset(ctx: Ctx, x: f64, y: f64, z: f64) Error!void {
        try mutate(ctx, (try self(ctx)).offset(.{ x, y, z }));
    }

    pub fn offsetCopy(ctx: Ctx, x: f64, y: f64, z: f64) Error!void {
        try cloned(ctx, (try self(ctx)).offset(.{ x, y, z }));
    }

    pub fn offsetTowards(ctx: Ctx, face: i64, distance: f64) Error!void {
        try mutate(ctx, try offsetTowardsBox(try self(ctx), face, distance));
    }

    pub fn offsetTowardsCopy(ctx: Ctx, face: i64, distance: f64) Error!void {
        try cloned(ctx, try offsetTowardsBox(try self(ctx), face, distance));
    }

    pub fn contract(ctx: Ctx, x: f64, y: f64, z: f64) Error!void {
        try mutate(ctx, contractBox(try self(ctx), .{ x, y, z }));
    }

    pub fn contractedCopy(ctx: Ctx, x: f64, y: f64, z: f64) Error!void {
        try cloned(ctx, contractBox(try self(ctx), .{ x, y, z }));
    }

    pub fn extend(ctx: Ctx, face: i64, distance: f64) Error!void {
        try mutate(ctx, try extendBox(try self(ctx), face, distance));
    }

    pub fn extendedCopy(ctx: Ctx, face: i64, distance: f64) Error!void {
        try cloned(ctx, try extendBox(try self(ctx), face, distance));
    }

    pub fn trim(ctx: Ctx, face: i64, distance: f64) Error!void {
        try mutate(ctx, try extendBox(try self(ctx), face, core.num.negf(distance)));
    }

    pub fn trimmedCopy(ctx: Ctx, face: i64, distance: f64) Error!void {
        try cloned(ctx, try extendBox(try self(ctx), face, core.num.negf(distance)));
    }

    pub fn stretch(ctx: Ctx, axis: i64, distance: f64) Error!void {
        try mutate(ctx, try stretchBox(try self(ctx), axis, distance));
    }

    pub fn stretchedCopy(ctx: Ctx, axis: i64, distance: f64) Error!void {
        try cloned(ctx, try stretchBox(try self(ctx), axis, distance));
    }

    pub fn squash(ctx: Ctx, axis: i64, distance: f64) Error!void {
        try mutate(ctx, try stretchBox(try self(ctx), axis, core.num.negf(distance)));
    }

    pub fn squashedCopy(ctx: Ctx, axis: i64, distance: f64) Error!void {
        try cloned(ctx, try stretchBox(try self(ctx), axis, core.num.negf(distance)));
    }

    fn calculateOffset(ctx: Ctx, comptime axis: usize) Error!f64 {
        try ctx.call.expectArgCount(2, 2);
        const obstacle = try self(ctx);
        const moving = try argBox(ctx, 1);
        const d = try ctx.call.expectArg(2, .{ .float = .{} }, {});
        return obstacle.calculateOffset(axis, moving, d);
    }

    pub fn calculateXOffset(ctx: Ctx) Error!f64 {
        return calculateOffset(ctx, 0);
    }

    pub fn calculateYOffset(ctx: Ctx) Error!f64 {
        return calculateOffset(ctx, 1);
    }

    pub fn calculateZOffset(ctx: Ctx) Error!f64 {
        return calculateOffset(ctx, 2);
    }

    pub fn intersectsWith(ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(1, 2);
        const a = try self(ctx);
        const b = try argBox(ctx, 1);
        const eps = if (ctx.call.argCount() >= 2) try ctx.call.expectArg(2, .{ .float = .{} }, {}) else geom.default_epsilon;
        return a.intersects(b, eps);
    }

    pub fn isVectorInside(ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(1, 1);
        return (try self(ctx)).isVectorInside(geom.numVecToFloat(try vector.argV3(ctx, 1)));
    }

    pub fn getAverageEdgeLength(ctx: Ctx) Error!f64 {
        const b = try self(ctx);
        return (b.max[0] - b.min[0] + b.max[1] - b.min[1] + b.max[2] - b.min[2]) / 3;
    }

    pub fn getXLength(ctx: Ctx) Error!f64 {
        const b = try self(ctx);
        return b.max[0] - b.min[0];
    }

    pub fn getYLength(ctx: Ctx) Error!f64 {
        const b = try self(ctx);
        return b.max[1] - b.min[1];
    }

    pub fn getZLength(ctx: Ctx) Error!f64 {
        const b = try self(ctx);
        return b.max[2] - b.min[2];
    }

    pub fn isCube(ctx: Ctx, epsilon: ?f64) Error!bool {
        const b = try self(ctx);
        const eps = epsilon orelse 0.000001;
        const x = b.max[0] - b.min[0];
        const y = b.max[1] - b.min[1];
        const z = b.max[2] - b.min[2];
        return @abs(x - y) < eps and @abs(y - z) < eps;
    }

    pub fn getVolume(ctx: Ctx) Error!f64 {
        const b = try self(ctx);
        return (b.max[0] - b.min[0]) * (b.max[1] - b.min[1]) * (b.max[2] - b.min[2]);
    }

    pub fn calculateIntercept(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        const o = rt.this(ctx);
        const b = try readBox(o);
        const p1 = try vector.argV3(ctx, 1);
        const p2 = try vector.argV3(ctx, 2);
        const hit = geom.calculateIntercept(b, p1, p2) orelse return;
        _ = newRayTraceResult(rt.ret(ctx), rtr_ce, o, hit.face, hit.hit);
    }

    pub fn __toString(ctx: Ctx) Error!void {
        const b = try self(ctx);
        var t: [6]rt.NumText = undefined;
        inline for (0..3) |a| {
            t[a] = rt.NumText.of(Num.f(b.min[a]));
            t[a + 3] = rt.NumText.of(Num.f(b.max[a]));
        }
        rt.retString(rt.ret(ctx), &.{ "AxisAlignedBB(", t[0].slice(), ", ", t[1].slice(), ", ", t[2].slice(), ", ", t[3].slice(), ", ", t[4].slice(), ", ", t[5].slice(), ")" });
    }

    pub fn one(ctx: Ctx) void {
        _ = newBox(rt.ret(ctx), Box.init(0, 0, 0, 1, 1, 1));
    }

    pub fn getCenter(ctx: Ctx) Error!void {
        const b = try self(ctx);
        vector.newV3Float(rt.ret(ctx), .{ (b.min[0] + b.max[0]) / 2, (b.min[1] + b.max[1]) / 2, (b.min[2] + b.max[2]) / 2 });
    }

    pub fn closestPoint(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const b = try self(ctx);
        vector.newV3Float(rt.ret(ctx), b.closestPoint(geom.numVecToFloat(try vector.argV3(ctx, 1))));
    }

    pub fn distanceSquaredTo(ctx: Ctx) Error!f64 {
        try ctx.call.expectArgCount(1, 1);
        const b = try self(ctx);
        return b.distanceSquaredTo(geom.numVecToFloat(try vector.argV3(ctx, 1)));
    }

    pub fn intersectsSphere(ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(2, 2);
        const b = try self(ctx);
        const center = geom.numVecToFloat(try vector.argV3(ctx, 1));
        const radius = try ctx.call.expectArg(2, .{ .float = .{} }, {});
        return b.distanceSquaredTo(center) <= radius * radius;
    }

    pub fn intersectsSegment(ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(2, 2);
        const b = try self(ctx);
        return b.intersectsSegment(geom.numVecToFloat(try vector.argV3(ctx, 1)), geom.numVecToFloat(try vector.argV3(ctx, 2)));
    }

    pub fn @"union"(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        _ = newBox(rt.ret(ctx), (try self(ctx)).union_(try argBox(ctx, 1)));
    }

    pub fn isFinite(ctx: Ctx) Error!bool {
        const b = try self(ctx);
        inline for (0..3) |a| {
            if (!std.math.isFinite(b.min[a]) or !std.math.isFinite(b.max[a])) return false;
        }
        return true;
    }
};

pub const RayTraceResult = struct {
    pub fn __construct(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(3, 3);
        _ = try vector.argObject(ctx, 1, bb_ce);
        const face = try ctx.call.expectArg(2, .{ .int = .{} }, {});
        _ = try vector.argObject(ctx, 3, vector.v3_ce);
        const o = rt.this(ctx);
        var f: c.zval = undefined;
        rt.setLong(&f, face);
        try rt.writeZval(o, rtr[0], rt.arg(ctx, 1));
        try rt.writeZval(o, rtr[1], &f);
        try rt.writeZval(o, rtr[2], rt.arg(ctx, 3));
    }
};

fn registerStringable(register_fn: anytype) *phpz.ClassEntry {
    return register_fn(.{.builtin("Stringable")});
}

pub const AxisAlignedBBClass = phpz.Class("quark\\math\\AxisAlignedBB", AxisAlignedBB, .{ .register = registerStringable });
pub const RayTraceResultClass = phpz.Class("quark\\math\\RayTraceResult", RayTraceResult, .{});
