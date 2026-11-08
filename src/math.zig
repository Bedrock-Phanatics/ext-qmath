const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const core = rt.core;
const num = core.num;
const Num = rt.Num;
const Ctx = rt.Ctx;
const Error = rt.Error;
const vector = @import("vector.zig");

const axis_names = [3][]const u8{ "y", "z", "x" };
const facing_names = [6][]const u8{ "down", "up", "north", "south", "west", "east" };

fn axisName(axis: i64) Error![]const u8 {
    if (axis < 0 or axis > 2) return rt.invalidArgument("Invalid axis {d}", .{axis});
    return axis_names[@intCast(axis)];
}

fn facingName(facing: i64) Error![]const u8 {
    if (facing < 0 or facing > 5) return rt.invalidArgument("Invalid facing {d}", .{facing});
    return facing_names[@intCast(facing)];
}

pub const Axis = struct {
    pub fn __construct() void {}

    pub fn toString(ctx: Ctx, axis: i64) Error!void {
        rt.retStringBytes(rt.ret(ctx), try axisName(axis));
    }
};

const F = core.geom.facing;

/// -1 where rotation is impossible.
const clockwise = [3][6]i64{
    .{ -1, -1, F.east, F.west, F.north, F.south },
    .{ F.west, F.east, -1, -1, F.up, F.down },
    .{ F.south, F.north, F.down, F.up, -1, -1 },
};

fn rotate(direction: i64, axis: i64, cw: bool) Error!i64 {
    if (axis < 0 or axis > 2) return rt.invalidArgument("Invalid axis {d}", .{axis});
    const r = if (direction >= 0 and direction < 6) clockwise[@intCast(axis)][@intCast(direction)] else -1;
    if (r < 0) {
        const fname = try facingName(direction);
        return rt.invalidArgument("Cannot rotate facing \"{s}\" around axis \"{s}\"", .{ fname, axis_names[@intCast(axis)] });
    }
    return if (cw) r else r ^ 1;
}

pub const Facing = struct {
    pub fn __construct() void {}

    pub fn axis(direction: i64) i64 {
        return direction >> 1;
    }

    pub fn isPositive(direction: i64) bool {
        return (direction & 1) == 1;
    }

    pub fn opposite(direction: i64) i64 {
        return direction ^ 1;
    }

    pub fn rotate(direction: i64, a: i64, cw: bool) Error!i64 {
        return rotateFacing(direction, a, cw);
    }

    pub fn rotateY(direction: i64, cw: bool) Error!i64 {
        return rotateFacing(direction, 0, cw);
    }

    pub fn rotateZ(direction: i64, cw: bool) Error!i64 {
        return rotateFacing(direction, 1, cw);
    }

    pub fn rotateX(direction: i64, cw: bool) Error!i64 {
        return rotateFacing(direction, 2, cw);
    }

    pub fn validate(facing: i64) Error!void {
        if (facing < 0 or facing > 5) return rt.invalidArgument("Invalid direction {d}", .{facing});
    }

    pub fn toString(ctx: Ctx, facing: i64) Error!void {
        rt.retStringBytes(rt.ret(ctx), try facingName(facing));
    }
};

pub const rotateFacing = rotate;

/// PHP would overflow to float and fail the int return type.
fn stepInt(ctx: Ctx, i: i64, delta: i64, comptime name: []const u8) Error!void {
    const r = @addWithOverflow(i, delta);
    if (r[1] != 0) return rt.typeError("pocketmine\\math\\Math::" ++ name ++ "(): Return value must be of type int, float returned", .{});
    rt.setLong(rt.ret(ctx), r[0]);
}

fn roundFloat(ctx: Ctx, comptime ceil: bool) Error!void {
    try ctx.call.expectArgCount(1, 1);
    const n = rt.deref(rt.arg(ctx, 1));
    const name = if (ceil) "ceilFloat" else "floorFloat";
    switch (rt.ztype(n)) {
        rt.IS_LONG => return rt.setLong(rt.ret(ctx), n.value.lval),
        rt.IS_DOUBLE => {
            const d = n.value.dval;
            const i = num.dvalToLval(d);
            const fi: f64 = @floatFromInt(i);
            const keep = if (ceil) d <= fi else d >= fi;
            if (keep) return rt.setLong(rt.ret(ctx), i);
            return stepInt(ctx, i, if (ceil) 1 else -1, name);
        },
        else => {
            const i = c.zval_get_long(n);
            if (phpz.exception.hasPending()) return error.PhpException;
            var iz: c.zval = undefined;
            rt.setLong(&iz, i);
            const cmp = if (ceil) c.zend_compare(n, &iz) else c.zend_compare(&iz, n);
            if (phpz.exception.hasPending()) return error.PhpException;
            if (cmp <= 0) return rt.setLong(rt.ret(ctx), i);
            return stepInt(ctx, i, if (ceil) 1 else -1, name);
        },
    }
}

pub const Math = struct {
    pub fn __construct() void {}

    pub fn floorFloat(ctx: Ctx) Error!void {
        try roundFloat(ctx, false);
    }

    pub fn ceilFloat(ctx: Ctx) Error!void {
        try roundFloat(ctx, true);
    }

    pub fn solveQuadratic(ctx: Ctx, a: f64, b: f64, cc: f64) Error!void {
        if (a == 0.0) return rt.invalidArgument("Coefficient a cannot be 0!", .{});
        const discriminant = b * b - 4 * a * cc;
        const out = rt.ret(ctx);
        if (discriminant > 0) {
            const s = @sqrt(discriminant);
            rt.newArray(out, 2);
            var zv: c.zval = undefined;
            rt.setDouble(&zv, (num.negf(b) + s) / (2 * a));
            _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
            rt.setDouble(&zv, (num.negf(b) - s) / (2 * a));
            _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
        } else if (discriminant == 0.0) {
            rt.newArray(out, 1);
            var zv: c.zval = undefined;
            rt.setDouble(&zv, (num.negf(b)) / (2 * a));
            _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
        } else {
            rt.newArray(out, 0);
        }
    }
};

const libm = core.libm;

pub const VectorMath = struct {
    pub fn __construct() void {}

    pub fn getDirection2D(ctx: Ctx, azimuth: f64) void {
        vector.newV2(rt.ret(ctx), libm.cos(azimuth), libm.sin(azimuth));
    }

    pub fn getDirection3D(ctx: Ctx, yaw: f64, pitch: f64) void {
        vector.newV3(rt.ret(ctx), core.physics.directionVector(yaw, pitch));
    }
};

pub const AxisClass = phpz.Class("pocketmine\\math\\Axis", Axis, .{});
pub const FacingClass = phpz.Class("pocketmine\\math\\Facing", Facing, .{});
pub const MathClass = phpz.Class("pocketmine\\math\\Math", Math, .{});
pub const VectorMathClass = phpz.Class("pocketmine\\math\\VectorMath", VectorMath, .{});

var facing_arrays: [9]?*c.zend_array = @splat(null);

fn declareConstant(ce: rt.Ce, comptime name: []const u8, ht: *c.zend_array) void {
    var zv: c.zval = undefined;
    rt.setImmutableArray(&zv, ht);
    const zname = c.zend_string_init_interned.?(name.ptr, name.len, true);
    _ = c.zend_declare_class_constant_ex(ce, zname, &zv, c.ZEND_ACC_PUBLIC, null);
}

fn longList(values: []const i64) *c.zend_array {
    const ht = rt.persistentArray(@intCast(values.len));
    for (values) |v| {
        var zv: c.zval = undefined;
        rt.setLong(&zv, v);
        _ = c.zend_hash_next_index_insert(ht, &zv);
    }
    rt.freezeArray(ht);
    return ht;
}

/// gen_stub cannot emit these.
pub fn startup() void {
    const ce = rt.cePtr(FacingClass.entry);
    const all = longList(&.{ 0, 1, 2, 3, 4, 5 });
    const horizontal = longList(&.{ 2, 3, 4, 5 });
    const offset = rt.persistentArray(6);
    for (F.offsets, 0..) |o, i| {
        const inner = longList(&o);
        facing_arrays[3 + i] = inner;
        var zv: c.zval = undefined;
        rt.setImmutableArray(&zv, inner);
        _ = c.zend_hash_next_index_insert(offset, &zv);
    }
    rt.freezeArray(offset);
    declareConstant(ce, "ALL", all);
    declareConstant(ce, "HORIZONTAL", horizontal);
    declareConstant(ce, "OFFSET", offset);
    facing_arrays[0] = all;
    facing_arrays[1] = horizontal;
    facing_arrays[2] = offset;
}

pub fn shutdown() void {
    for (&facing_arrays) |*slot| {
        if (slot.*) |ht| rt.freeArray(ht);
        slot.* = null;
    }
}
