//! pocketmine\math\Vector2 and Vector3.

const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const core = rt.core;
const num = core.num;
const geom = core.geom;
const Num = rt.Num;
const NumVec = rt.NumVec;
const Ctx = rt.Ctx;
const Error = rt.Error;
const ZObj = rt.ZObj;

/// An int|float argument coerced like a user function parameter: weak mode accepts numeric strings
/// and bools, and null is only accepted when `nullable`.
fn numArg(ctx: Ctx, n: u32, comptime nullable: bool) Error!?Num {
    const zv = rt.arg(ctx, n);
    switch (rt.ztype(zv)) {
        rt.IS_LONG => return Num.i(zv.value.lval),
        rt.IS_DOUBLE => return Num.f(zv.value.dval),
        rt.IS_NULL => if (nullable) return null,
        else => {
            var dest: [*c]c.zval = undefined;
            if (c.zend_parse_arg_number_slow(zv, &dest, n)) {
                return if (rt.ztype(dest) == rt.IS_LONG) Num.i(dest.*.value.lval) else Num.f(dest.*.value.dval);
            }
            if (phpz.exception.hasPending()) return error.PhpException;
        },
    }
    c.zend_argument_type_error(n, "must be of type " ++ (if (nullable) "int|float|null" else "int|float") ++ ", %s given", c.zend_zval_value_name(zv));
    return error.PhpException;
}

/// A float argument coerced like a user function parameter declared as `types`.
fn floatArg(ctx: Ctx, n: u32, comptime types: []const u8) Error!f64 {
    const zv = rt.arg(ctx, n);
    switch (rt.ztype(zv)) {
        rt.IS_DOUBLE => return zv.value.dval,
        rt.IS_LONG => return @floatFromInt(zv.value.lval),
        rt.IS_NULL => {},
        else => {
            var d: f64 = undefined;
            if (c.zend_parse_arg_double_slow(zv, &d, n)) return d;
            if (phpz.exception.hasPending()) return error.PhpException;
        },
    }
    c.zend_argument_type_error(n, "must be of type " ++ types ++ ", %s given", c.zend_zval_value_name(zv));
    return error.PhpException;
}

fn numArgs(ctx: Ctx) Error!NumVec {
    try ctx.call.expectArgCount(3, 3);
    return .{ (try numArg(ctx, 1, false)).?, (try numArg(ctx, 2, false)).?, (try numArg(ctx, 3, false)).? };
}

pub var v3_ce: rt.Ce = undefined;
pub var v2_ce: rt.Ce = undefined;
var v3: [3]rt.Prop = undefined;
var v2: [2]rt.Prop = undefined;
var base_get_side: ?*c.zend_function = null;
var get_side_name: *c.zend_string = undefined;

pub fn startup() void {
    v3_ce = rt.cePtr(Vector3Class.entry);
    v2_ce = rt.cePtr(Vector2Class.entry);
    v3 = .{ rt.Prop.resolve(v3_ce, "x"), rt.Prop.resolve(v3_ce, "y"), rt.Prop.resolve(v3_ce, "z") };
    v2 = .{ rt.Prop.resolve(v2_ce, "x"), rt.Prop.resolve(v2_ce, "y") };
    get_side_name = c.zend_string_init_interned.?("getside", 7, true);
    base_get_side = @ptrCast(@alignCast(c.zend_hash_find_ptr(&v3_ce.function_table, get_side_name)));
}

pub fn readV3(o: ZObj) Error!NumVec {
    const plain = rt.plainSlots(o.ce, v3_ce, &v3);
    return .{ try rt.readNum(o, v3[0], plain), try rt.readNum(o, v3[1], plain), try rt.readNum(o, v3[2], plain) };
}

pub fn readV3Float(o: ZObj) Error!rt.Vec {
    return geom.numVecToFloat(try readV3(o));
}

pub fn newV3(out: *c.zval, v: NumVec) void {
    const o = rt.newObject(out, v3_ce);
    inline for (0..3) |a| rt.setNum(rt.initSlot(o, v3[a]), v[a]);
}

pub fn newV3Float(out: *c.zval, v: rt.Vec) void {
    newV3(out, .{ Num.f(v[0]), Num.f(v[1]), Num.f(v[2]) });
}

pub fn readV2(o: ZObj) Error![2]f64 {
    const plain = rt.plainSlots(o.ce, v2_ce, &v2);
    return .{ try rt.readFloatOf(o, v2[0], plain), try rt.readFloatOf(o, v2[1], plain) };
}

pub fn newV2(out: *c.zval, x: f64, y: f64) void {
    const o = rt.newObject(out, v2_ce);
    rt.setDouble(rt.initSlot(o, v2[0]), x);
    rt.setDouble(rt.initSlot(o, v2[1]), y);
}

/// The object argument `n` if it is an instance of `ce`, with ZPP's error otherwise.
pub fn argObject(ctx: Ctx, n: u32, ce: rt.Ce) Error!ZObj {
    const zv = rt.arg(ctx, n);
    if (rt.ztype(zv) == rt.IS_OBJECT and rt.instanceOf(zv.value.obj, ce)) return zv.value.obj;
    c.zend_wrong_parameter_class_error(n, rt.zstrC(ce.name), zv);
    return error.PhpException;
}

pub fn argV3(ctx: Ctx, n: u32) Error!NumVec {
    return readV3(try argObject(ctx, n, v3_ce));
}

fn self3(ctx: Ctx) Error!NumVec {
    return readV3(rt.this(ctx));
}

fn retV3(ctx: Ctx, v: NumVec) void {
    newV3(rt.ret(ctx), v);
}

fn lenSq3(v: NumVec) Num {
    return v[0].mul(v[0]).add(v[1].mul(v[1])).add(v[2].mul(v[2]));
}

fn distSq3(a: NumVec, b: NumVec) Num {
    const dx = a[0].sub(b[0]);
    const dy = a[1].sub(b[1]);
    const dz = a[2].sub(b[2]);
    return dx.mul(dx).add(dy.mul(dy)).add(dz.mul(dz));
}

fn dot3(a: NumVec, b: NumVec) Num {
    return a[0].mul(b[0]).add(a[1].mul(b[1])).add(a[2].mul(b[2]));
}

fn add3(a: NumVec, b: NumVec) NumVec {
    return .{ a[0].add(b[0]), a[1].add(b[1]), a[2].add(b[2]) };
}

fn scale(a: NumVec, f: f64) NumVec {
    return .{ Num.f(a[0].toFloat() * f), Num.f(a[1].toFloat() * f), Num.f(a[2].toFloat() * f) };
}

/// Vector3::getSide() without dispatch.
fn side(v: NumVec, s: i64, step: i64) NumVec {
    const o: [3]i64 = if (s >= 0 and s < 6) geom.facing.offsets[@intCast(s)] else .{ 0, 0, 0 };
    return add3(v, .{ Num.i(o[0]).mul(Num.i(step)), Num.i(o[1]).mul(Num.i(step)), Num.i(o[2]).mul(Num.i(step)) });
}

/// Calls getSide() through the object's own method table so overrides such as Position::getSide() apply.
fn dispatchSide(o: ZObj, out: *c.zval, s: i64, step: i64) Error!void {
    if (o.ce != v3_ce) {
        const f: ?*c.zend_function = @ptrCast(@alignCast(c.zend_hash_find_ptr(&o.ce.*.function_table, get_side_name)));
        if (f != null and f != base_get_side) {
            var params: [2]c.zval = undefined;
            rt.setLong(&params[0], s);
            rt.setLong(&params[1], step);
            c.zend_call_known_function(f, o, o.ce, out, 2, &params, null);
            if (phpz.exception.hasPending()) {
                c.zval_ptr_dtor(out);
                rt.setNull(out);
                return error.PhpException;
            }
            return;
        }
    }
    newV3(out, side(try readV3(o), s, step));
}

/// Frameless max($a, $b) for int|float values.
fn phpMax(a: Num, b: Num) Num {
    return switch (a) {
        .int => |l| switch (b) {
            .int => |r| if (l >= r) a else b,
            .float => |r| if (num.dvalToLval(@floatFromInt(l)) == l) (if (@as(f64, @floatFromInt(l)) >= r) a else b) else generic(a, b, true),
        },
        .float => |l| switch (b) {
            .float => |r| if (l >= r) a else b,
            .int => |r| if (num.dvalToLval(@floatFromInt(r)) == r) (if (l >= @as(f64, @floatFromInt(r))) a else b) else generic(a, b, true),
        },
    };
}

fn phpMin(a: Num, b: Num) Num {
    return switch (a) {
        .int => |l| switch (b) {
            .int => |r| if (l < r) a else b,
            .float => |r| if (num.dvalToLval(@floatFromInt(l)) == l) (if (@as(f64, @floatFromInt(l)) < r) a else b) else generic(a, b, false),
        },
        .float => |l| switch (b) {
            .float => |r| if (l < r) a else b,
            .int => |r| if (num.dvalToLval(@floatFromInt(r)) == r) (if (l < @as(f64, @floatFromInt(r))) a else b) else generic(a, b, false),
        },
    };
}

fn generic(a: Num, b: Num, comptime max: bool) Num {
    var za: c.zval = undefined;
    var zb: c.zval = undefined;
    rt.setNum(&za, a);
    rt.setNum(&zb, b);
    const cmp = c.zend_compare(&za, &zb);
    return if (max) (if (cmp >= 0) a else b) else (if (cmp < 0) a else b);
}

fn validRoundMode(mode: i64) bool {
    return mode >= c.PHP_ROUND_HALF_UP and mode <= c.PHP_ROUND_AWAY_FROM_ZERO;
}

/// round($v, $precision, $mode) for int|float.
fn phpRound(v: Num, places: c_int, mode: i64) f64 {
    return switch (v) {
        .int => |l| if (places >= 0) @floatFromInt(l) else c._php_math_round(@floatFromInt(l), places, @intCast(mode)),
        .float => |d| c._php_math_round(d, places, @intCast(mode)),
    };
}

fn buildSides(ctx: Ctx, out: *c.zval, step: i64, skip_axis: ?i64, keys: bool) Error!void {
    const o = rt.this(ctx);
    rt.newArray(out, 6);
    var f: i64 = 0;
    while (f < 6) : (f += 1) {
        if (skip_axis) |a| if ((f >> 1) == a) continue;
        var item: c.zval = undefined;
        dispatchSide(o, &item, f, step) catch |e| {
            c.zval_ptr_dtor(out);
            rt.setNull(out);
            return e;
        };
        if (keys) {
            _ = c.zend_hash_index_update(out.value.arr, @intCast(f), &item);
        } else {
            _ = c.zend_hash_next_index_insert(out.value.arr, &item);
        }
    }
}

fn arrayIterator(out: *c.zval, arr: *c.zval) Error!void {
    const it = rt.newObject(out, rt.phpCe("spl_ce_ArrayIterator"));
    c.zend_call_known_instance_method_with_1_params(rt.phpCe("spl_ce_ArrayIterator").*.constructor, it, null, arr);
    c.zval_ptr_dtor(arr);
    if (phpz.exception.hasPending()) return error.PhpException;
}

pub const Vector3 = struct {
    pub fn __construct(ctx: Ctx) Error!void {
        const in = try numArgs(ctx);
        const o = rt.this(ctx);
        const plain = rt.plainSlots(o.ce, v3_ce, &v3);
        inline for (0..3) |a| try rt.writeNum(o, v3[a], plain, in[a]);
    }

    pub fn zero(ctx: Ctx) void {
        retV3(ctx, .{ Num.i(0), Num.i(0), Num.i(0) });
    }

    pub fn getX(ctx: Ctx) Error!void {
        rt.setNum(rt.ret(ctx), (try self3(ctx))[0]);
    }

    pub fn getY(ctx: Ctx) Error!void {
        rt.setNum(rt.ret(ctx), (try self3(ctx))[1]);
    }

    pub fn getZ(ctx: Ctx) Error!void {
        rt.setNum(rt.ret(ctx), (try self3(ctx))[2]);
    }

    pub fn getFloorX(ctx: Ctx) Error!i64 {
        return num.floorInt((try self3(ctx))[0]);
    }

    pub fn getFloorY(ctx: Ctx) Error!i64 {
        return num.floorInt((try self3(ctx))[1]);
    }

    pub fn getFloorZ(ctx: Ctx) Error!i64 {
        return num.floorInt((try self3(ctx))[2]);
    }

    pub fn add(ctx: Ctx) Error!void {
        const in = try numArgs(ctx);
        retV3(ctx, addTo(try self3(ctx), in));
    }

    fn addTo(a: NumVec, b: NumVec) NumVec {
        return .{ a[0].add(b[0]), a[1].add(b[1]), a[2].add(b[2]) };
    }

    pub fn addVector(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        retV3(ctx, addTo(try self3(ctx), try argV3(ctx, 1)));
    }

    pub fn subtract(ctx: Ctx) Error!void {
        const in = try numArgs(ctx);
        retV3(ctx, addTo(try self3(ctx), .{ in[0].neg(), in[1].neg(), in[2].neg() }));
    }

    pub fn subtractVector(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const v = try argV3(ctx, 1);
        retV3(ctx, addTo(try self3(ctx), .{ v[0].neg(), v[1].neg(), v[2].neg() }));
    }

    pub fn multiply(ctx: Ctx, number: f64) Error!void {
        retV3(ctx, scale(try self3(ctx), number));
    }

    pub fn divide(ctx: Ctx, number: f64) Error!void {
        const v = try self3(ctx);
        if (number == 0) return rt.divisionByZero();
        retV3(ctx, .{ Num.f(v[0].toFloat() / number), Num.f(v[1].toFloat() / number), Num.f(v[2].toFloat() / number) });
    }

    pub fn ceil(ctx: Ctx) Error!void {
        const v = try self3(ctx);
        retV3(ctx, .{ Num.i(num.ceilInt(v[0])), Num.i(num.ceilInt(v[1])), Num.i(num.ceilInt(v[2])) });
    }

    pub fn floor(ctx: Ctx) Error!void {
        const v = try self3(ctx);
        retV3(ctx, .{ Num.i(num.floorInt(v[0])), Num.i(num.floorInt(v[1])), Num.i(num.floorInt(v[2])) });
    }

    pub fn round(ctx: Ctx, precision: ?i64, mode: ?i64) Error!void {
        const v = try self3(ctx);
        const p = precision orelse 0;
        const m = mode orelse c.PHP_ROUND_HALF_UP;
        if (!validRoundMode(m)) return rt.valueError("round(): Argument #3 ($mode) must be a valid rounding mode (RoundingMode::*)", .{});
        const places: c_int = @intCast(std.math.clamp(p, std.math.minInt(c_int), std.math.maxInt(c_int)));
        var r: NumVec = undefined;
        inline for (0..3) |a| {
            const d = phpRound(v[a], places, m);
            r[a] = if (p > 0) Num.f(d) else Num.i(num.dvalToLval(d));
        }
        retV3(ctx, r);
    }

    pub fn abs(ctx: Ctx) Error!void {
        const v = try self3(ctx);
        retV3(ctx, .{ v[0].abs(), v[1].abs(), v[2].abs() });
    }

    pub fn getSide(ctx: Ctx, s: i64, step: ?i64) Error!void {
        retV3(ctx, side(try self3(ctx), s, step orelse 1));
    }

    pub fn down(ctx: Ctx, step: ?i64) Error!void {
        try dispatchSide(rt.this(ctx), rt.ret(ctx), geom.facing.down, step orelse 1);
    }

    pub fn up(ctx: Ctx, step: ?i64) Error!void {
        try dispatchSide(rt.this(ctx), rt.ret(ctx), geom.facing.up, step orelse 1);
    }

    pub fn north(ctx: Ctx, step: ?i64) Error!void {
        try dispatchSide(rt.this(ctx), rt.ret(ctx), geom.facing.north, step orelse 1);
    }

    pub fn south(ctx: Ctx, step: ?i64) Error!void {
        try dispatchSide(rt.this(ctx), rt.ret(ctx), geom.facing.south, step orelse 1);
    }

    pub fn west(ctx: Ctx, step: ?i64) Error!void {
        try dispatchSide(rt.this(ctx), rt.ret(ctx), geom.facing.west, step orelse 1);
    }

    pub fn east(ctx: Ctx, step: ?i64) Error!void {
        try dispatchSide(rt.this(ctx), rt.ret(ctx), geom.facing.east, step orelse 1);
    }

    pub fn sides(ctx: Ctx, step: ?i64) Error!void {
        var arr: c.zval = undefined;
        try buildSides(ctx, &arr, step orelse 1, null, true);
        try arrayIterator(rt.ret(ctx), &arr);
    }

    pub fn sidesArray(ctx: Ctx, keys: ?bool, step: ?i64) Error!void {
        _ = keys;
        try buildSides(ctx, rt.ret(ctx), step orelse 1, null, false);
    }

    pub fn sidesAroundAxis(ctx: Ctx, axis: i64, step: ?i64) Error!void {
        var arr: c.zval = undefined;
        try buildSides(ctx, &arr, step orelse 1, axis, true);
        try arrayIterator(rt.ret(ctx), &arr);
    }

    pub fn asVector3(ctx: Ctx) Error!void {
        retV3(ctx, try self3(ctx));
    }

    pub fn distance(ctx: Ctx) Error!f64 {
        try ctx.call.expectArgCount(1, 1);
        return @sqrt(distSq3(try self3(ctx), try argV3(ctx, 1)).toFloat());
    }

    pub fn distanceSquared(ctx: Ctx) Error!f64 {
        try ctx.call.expectArgCount(1, 1);
        return distSq3(try self3(ctx), try argV3(ctx, 1)).toFloat();
    }

    pub fn maxPlainDistance(ctx: Ctx) Error!f64 {
        try ctx.call.expectArgCount(1, 2);
        const v = try self3(ctx);
        const a1 = rt.arg(ctx, 1);
        const vec: ?ZObj = if (rt.ztype(a1) == rt.IS_OBJECT and (rt.instanceOf(a1.value.obj, v3_ce) or rt.instanceOf(a1.value.obj, v2_ce))) a1.value.obj else null;
        var x: f64 = if (vec == null) try floatArg(ctx, 1, "pocketmine\\math\\Vector3|pocketmine\\math\\Vector2|float") else 0;
        // $z is checked even when $x is a vector, like the PHP signature.
        var z: f64 = if (ctx.call.argCount() >= 2) try floatArg(ctx, 2, "float") else 0;
        if (vec) |o| {
            if (rt.instanceOf(o, v3_ce)) {
                const p = try readV3(o);
                x = p[0].toFloat();
                z = p[2].toFloat();
            } else {
                const p = try readV2(o);
                x = p[0];
                z = p[1];
            }
        }
        const dx = v[0].sub(Num.f(x)).abs();
        const dz = v[2].sub(Num.f(z)).abs();
        return phpMax(dx, dz).toFloat();
    }

    pub fn length(ctx: Ctx) Error!f64 {
        return @sqrt(lenSq3(try self3(ctx)).toFloat());
    }

    pub fn lengthSquared(ctx: Ctx) Error!f64 {
        return lenSq3(try self3(ctx)).toFloat();
    }

    pub fn normalize(ctx: Ctx) Error!void {
        retV3(ctx, core.physics.normalize(try self3(ctx)));
    }

    pub fn dot(ctx: Ctx) Error!f64 {
        try ctx.call.expectArgCount(1, 1);
        return dot3(try self3(ctx), try argV3(ctx, 1)).toFloat();
    }

    pub fn cross(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const a = try self3(ctx);
        const b = try argV3(ctx, 1);
        retV3(ctx, .{
            a[1].mul(b[2]).sub(a[2].mul(b[1])),
            a[2].mul(b[0]).sub(a[0].mul(b[2])),
            a[0].mul(b[1]).sub(a[1].mul(b[0])),
        });
    }

    pub fn equals(ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(1, 1);
        const a = try self3(ctx);
        const b = try argV3(ctx, 1);
        return a[0].toFloat() == b[0].toFloat() and a[1].toFloat() == b[1].toFloat() and a[2].toFloat() == b[2].toFloat();
    }

    fn intermediate(ctx: Ctx, comptime axis: usize) Error!void {
        try ctx.call.expectArgCount(2, 2);
        const a = try self3(ctx);
        const b = try argV3(ctx, 1);
        const value = try ctx.call.expectArg(2, .{ .float = .{} }, {});
        if (geom.intermediate(axis, a, b, value)) |p| newV3Float(rt.ret(ctx), p);
    }

    pub fn getIntermediateWithXValue(ctx: Ctx) Error!void {
        try intermediate(ctx, 0);
    }

    pub fn getIntermediateWithYValue(ctx: Ctx) Error!void {
        try intermediate(ctx, 1);
    }

    pub fn getIntermediateWithZValue(ctx: Ctx) Error!void {
        try intermediate(ctx, 2);
    }

    pub fn __toString(ctx: Ctx) Error!void {
        const v = try self3(ctx);
        const x = rt.NumText.of(v[0]);
        const y = rt.NumText.of(v[1]);
        const z = rt.NumText.of(v[2]);
        rt.retString(rt.ret(ctx), &.{ "Vector3(x=", x.slice(), ",y=", y.slice(), ",z=", z.slice(), ")" });
    }

    pub fn withComponents(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(3, 3);
        const in = [3]?Num{ try numArg(ctx, 1, true), try numArg(ctx, 2, true), try numArg(ctx, 3, true) };
        const o = rt.this(ctx);
        if (in[0] == null and in[1] == null and in[2] == null) return rt.retObjectCopy(rt.ret(ctx), o);
        const v = try readV3(o);
        var r: NumVec = undefined;
        inline for (0..3) |a| r[a] = in[a] orelse v[a];
        retV3(ctx, r);
    }

    fn components(ctx: Ctx, comptime pick: fn (Num, Num) Num) Error!void {
        const n = ctx.call.argCount();
        if (n < 1) return phpz.exception.wrongParameterCount(1, std.math.maxInt(u32));
        var acc = try argV3(ctx, 1);
        var i: u32 = 2;
        while (i <= n) : (i += 1) {
            const v = try argV3(ctx, i);
            inline for (0..3) |a| acc[a] = pick(acc[a], v[a]);
        }
        retV3(ctx, acc);
    }

    pub fn maxComponents(ctx: Ctx) Error!void {
        try components(ctx, phpMax);
    }

    pub fn minComponents(ctx: Ctx) Error!void {
        try components(ctx, phpMin);
    }

    pub fn sum(ctx: Ctx) Error!void {
        var acc = NumVec{ Num.i(0), Num.i(0), Num.i(0) };
        var i: u32 = 1;
        while (i <= ctx.call.argCount()) : (i += 1) acc = addTo(acc, try argV3(ctx, i));
        retV3(ctx, acc);
    }

    pub fn lerp(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        const a = try readV3Float(rt.this(ctx));
        const b = geom.numVecToFloat(try argV3(ctx, 1));
        const t = try ctx.call.expectArg(2, .{ .float = .{} }, {});
        var r: rt.Vec = undefined;
        inline for (0..3) |k| r[k] = a[k] + (b[k] - a[k]) * t;
        newV3Float(rt.ret(ctx), r);
    }

    pub fn normalizeOrNull(ctx: Ctx) Error!void {
        const v = try readV3Float(rt.this(ctx));
        const len = @sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
        if (!(len > 0) or !std.math.isFinite(len)) return;
        newV3Float(rt.ret(ctx), .{ v[0] / len, v[1] / len, v[2] / len });
    }

    fn projectOnto(a: rt.Vec, b: rt.Vec) rt.Vec {
        const bb = b[0] * b[0] + b[1] * b[1] + b[2] * b[2];
        if (!(bb > 0)) return .{ 0, 0, 0 };
        const k = (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]) / bb;
        return .{ b[0] * k, b[1] * k, b[2] * k };
    }

    pub fn project(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const a = try readV3Float(rt.this(ctx));
        const b = geom.numVecToFloat(try argV3(ctx, 1));
        newV3Float(rt.ret(ctx), projectOnto(a, b));
    }

    pub fn reject(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const a = try readV3Float(rt.this(ctx));
        const p = projectOnto(a, geom.numVecToFloat(try argV3(ctx, 1)));
        newV3Float(rt.ret(ctx), .{ a[0] - p[0], a[1] - p[1], a[2] - p[2] });
    }

    pub fn reflect(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const a = try readV3Float(rt.this(ctx));
        const n = geom.numVecToFloat(try argV3(ctx, 1));
        const d = 2 * (a[0] * n[0] + a[1] * n[1] + a[2] * n[2]);
        newV3Float(rt.ret(ctx), .{ a[0] - n[0] * d, a[1] - n[1] * d, a[2] - n[2] * d });
    }

    pub fn angle(ctx: Ctx) Error!f64 {
        try ctx.call.expectArgCount(1, 1);
        const a = try readV3Float(rt.this(ctx));
        const b = geom.numVecToFloat(try argV3(ctx, 1));
        const la = @sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
        const lb = @sqrt(b[0] * b[0] + b[1] * b[1] + b[2] * b[2]);
        if (!(la > 0) or !(lb > 0)) return 0;
        const cos = (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]) / (la * lb);
        return std.math.acos(std.math.clamp(cos, -1.0, 1.0));
    }

    pub fn clamp(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        const v = try readV3Float(rt.this(ctx));
        const lo = geom.numVecToFloat(try argV3(ctx, 1));
        const hi = geom.numVecToFloat(try argV3(ctx, 2));
        var r: rt.Vec = undefined;
        inline for (0..3) |k| r[k] = @min(@max(v[k], lo[k]), hi[k]);
        newV3Float(rt.ret(ctx), r);
    }

    pub fn moveTowards(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        const a = try readV3Float(rt.this(ctx));
        const target = try argV3(ctx, 1);
        const max = try ctx.call.expectArg(2, .{ .float = .{} }, {});
        const b = geom.numVecToFloat(target);
        const d = rt.Vec{ b[0] - a[0], b[1] - a[1], b[2] - a[2] };
        const dist = @sqrt(d[0] * d[0] + d[1] * d[1] + d[2] * d[2]);
        if (dist <= max or dist == 0) return newV3(rt.ret(ctx), target);
        const k = max / dist;
        newV3Float(rt.ret(ctx), .{ a[0] + d[0] * k, a[1] + d[1] * k, a[2] + d[2] * k });
    }

    pub fn isFinite(ctx: Ctx) Error!bool {
        const v = try readV3Float(rt.this(ctx));
        return std.math.isFinite(v[0]) and std.math.isFinite(v[1]) and std.math.isFinite(v[2]);
    }
};

fn self2(ctx: Ctx) Error![2]f64 {
    return readV2(rt.this(ctx));
}

fn argV2(ctx: Ctx, n: u32) Error![2]f64 {
    return readV2(try argObject(ctx, n, v2_ce));
}

pub const Vector2 = struct {
    pub fn __construct(ctx: Ctx, x: f64, y: f64) Error!void {
        const o = rt.this(ctx);
        const plain = rt.plainSlots(o.ce, v2_ce, &v2);
        try rt.writeNum(o, v2[0], plain, Num.f(x));
        try rt.writeNum(o, v2[1], plain, Num.f(y));
    }

    pub fn getX(ctx: Ctx) Error!f64 {
        return (try self2(ctx))[0];
    }

    pub fn getY(ctx: Ctx) Error!f64 {
        return (try self2(ctx))[1];
    }

    pub fn getFloorX(ctx: Ctx) Error!i64 {
        return num.dvalToLval(@floor((try self2(ctx))[0]));
    }

    pub fn getFloorY(ctx: Ctx) Error!i64 {
        return num.dvalToLval(@floor((try self2(ctx))[1]));
    }

    pub fn add(ctx: Ctx, x: f64, y: f64) Error!void {
        const v = try self2(ctx);
        newV2(rt.ret(ctx), v[0] + x, v[1] + y);
    }

    pub fn addVector(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const v = try self2(ctx);
        const o = try argV2(ctx, 1);
        newV2(rt.ret(ctx), v[0] + o[0], v[1] + o[1]);
    }

    pub fn subtract(ctx: Ctx, x: f64, y: f64) Error!void {
        const v = try self2(ctx);
        newV2(rt.ret(ctx), v[0] + num.negf(x), v[1] + num.negf(y));
    }

    pub fn subtractVector(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const v = try self2(ctx);
        const o = try argV2(ctx, 1);
        newV2(rt.ret(ctx), v[0] + num.negf(o[0]), v[1] + num.negf(o[1]));
    }

    // Vector2::ceil()/floor() pass (int) results to float parameters, so they come back as floats.
    pub fn ceil(ctx: Ctx) Error!void {
        const v = try self2(ctx);
        newV2(rt.ret(ctx), @floatFromInt(num.dvalToLval(@ceil(v[0]))), @floatFromInt(num.dvalToLval(@ceil(v[1]))));
    }

    pub fn floor(ctx: Ctx) Error!void {
        const v = try self2(ctx);
        newV2(rt.ret(ctx), @floatFromInt(num.dvalToLval(@floor(v[0]))), @floatFromInt(num.dvalToLval(@floor(v[1]))));
    }

    pub fn round(ctx: Ctx) Error!void {
        const v = try self2(ctx);
        newV2(rt.ret(ctx), c._php_math_round(v[0], 0, c.PHP_ROUND_HALF_UP), c._php_math_round(v[1], 0, c.PHP_ROUND_HALF_UP));
    }

    pub fn abs(ctx: Ctx) Error!void {
        const v = try self2(ctx);
        newV2(rt.ret(ctx), @abs(v[0]), @abs(v[1]));
    }

    pub fn multiply(ctx: Ctx, number: f64) Error!void {
        const v = try self2(ctx);
        newV2(rt.ret(ctx), v[0] * number, v[1] * number);
    }

    pub fn divide(ctx: Ctx, number: f64) Error!void {
        const v = try self2(ctx);
        if (number == 0) return rt.divisionByZero();
        newV2(rt.ret(ctx), v[0] / number, v[1] / number);
    }

    pub fn distance(ctx: Ctx) Error!f64 {
        return @sqrt(try @This().distanceSquared(ctx));
    }

    pub fn distanceSquared(ctx: Ctx) Error!f64 {
        try ctx.call.expectArgCount(1, 1);
        const v = try self2(ctx);
        const o = try argV2(ctx, 1);
        const dx = v[0] - o[0];
        const dy = v[1] - o[1];
        return (dx * dx) + (dy * dy);
    }

    pub fn length(ctx: Ctx) Error!f64 {
        return @sqrt(try @This().lengthSquared(ctx));
    }

    pub fn lengthSquared(ctx: Ctx) Error!f64 {
        const v = try self2(ctx);
        return v[0] * v[0] + v[1] * v[1];
    }

    pub fn normalize(ctx: Ctx) Error!void {
        const v = try self2(ctx);
        const len = v[0] * v[0] + v[1] * v[1];
        if (len > 0) {
            const s = @sqrt(len);
            return newV2(rt.ret(ctx), v[0] / s, v[1] / s);
        }
        newV2(rt.ret(ctx), 0, 0);
    }

    pub fn dot(ctx: Ctx) Error!f64 {
        try ctx.call.expectArgCount(1, 1);
        const v = try self2(ctx);
        const o = try argV2(ctx, 1);
        return v[0] * o[0] + v[1] * o[1];
    }

    pub fn lerp(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        const v = try self2(ctx);
        const o = try argV2(ctx, 1);
        const t = try ctx.call.expectArg(2, .{ .float = .{} }, {});
        newV2(rt.ret(ctx), v[0] + (o[0] - v[0]) * t, v[1] + (o[1] - v[1]) * t);
    }

    pub fn __toString(ctx: Ctx) Error!void {
        const v = try self2(ctx);
        const x = rt.NumText.of(Num.f(v[0]));
        const y = rt.NumText.of(Num.f(v[1]));
        rt.retString(rt.ret(ctx), &.{ "Vector2(x=", x.slice(), ",y=", y.slice(), ")" });
    }
};

fn registerStringable(register_fn: anytype) *phpz.ClassEntry {
    return register_fn(.{.builtin("Stringable")});
}

pub const Vector2Class = phpz.Class("pocketmine\\math\\Vector2", Vector2, .{ .register = registerStringable });
pub const Vector3Class = phpz.Class("pocketmine\\math\\Vector3", Vector3, .{ .register = registerStringable });
