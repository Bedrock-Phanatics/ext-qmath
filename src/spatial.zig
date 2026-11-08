const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const core = rt.core;
const physics = core.physics;
const Num = rt.Num;
const Ctx = rt.Ctx;
const Error = rt.Error;
const vector = @import("vector.zig");
const aabb = @import("aabb.zig");

fn optFloat(ctx: Ctx, n: u32, default: f64) Error!f64 {
    return if (ctx.call.argCount() >= n) try ctx.call.expectArg(n, .{ .float = .{} }, {}) else default;
}

fn optBool(ctx: Ctx, n: u32, default: bool) Error!bool {
    return if (ctx.call.argCount() >= n) try ctx.call.expectArg(n, .{ .bool = .{} }, {}) else default;
}

fn typeErrorArg(n: u32, comptime what: [:0]const u8, zv: *c.zval) Error {
    c.zend_argument_type_error(n, what, c.zend_zval_value_name(zv));
    return error.PhpException;
}

pub const Spatial = struct {
    pub fn __construct() void {}

    pub fn overlapping(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 5);
        const arr = (try ctx.call.expectArg(1, .{ .array = .{} }, {})).ptr();
        const query = try aabb.argBox(ctx, 2);
        var exclude: ?rt.ZObj = null;
        if (ctx.call.argCount() >= 3) {
            const ex = rt.arg(ctx, 3);
            switch (rt.ztype(ex)) {
                rt.IS_NULL => {},
                rt.IS_OBJECT => exclude = ex.value.obj,
                else => return typeErrorArg(3, "must be of type ?object, %s given", ex),
            }
        }
        const name: *c.zend_string = if (ctx.call.argCount() >= 4) (try ctx.call.expectArg(4, .{ .string = .{ .as = .str } }, {})).ptr() else bounding_box_name;
        const eps = try optFloat(ctx, 5, core.geom.default_epsilon);

        const out = rt.ret(ctx);
        rt.newArray(out, 0);
        errdefer {
            c.zval_ptr_dtor(out);
            rt.setNull(out);
        }
        var pos: c.HashPosition = 0;
        c.zend_hash_internal_pointer_reset_ex(arr, &pos);
        while (c.zend_hash_get_current_data_ex(arr, &pos)) |raw| : (_ = c.zend_hash_move_forward_ex(arr, &pos)) {
            const zv = rt.deref(raw);
            if (rt.ztype(zv) != rt.IS_OBJECT) return typeErrorArg(1, "must contain only objects, %s found", zv);
            const o: rt.ZObj = zv.value.obj;
            if (o == exclude) continue;
            rt.hold(o);
            defer rt.release(o);
            var rv: c.zval = undefined;
            rv.u1.type_info = rt.IS_UNDEF;
            const res = o.handlers.*.read_property.?(o, name, c.BP_VAR_R, null, &rv);
            defer if (res == &rv) c.zval_ptr_dtor(&rv);
            if (phpz.exception.hasPending()) return error.PhpException;
            const bbz = rt.deref(res);
            if (rt.ztype(bbz) != rt.IS_OBJECT or !rt.instanceOf(bbz.value.obj, aabb.bb_ce)) {
                return rt.typeError("%s::$%s must be a quark\\math\\AxisAlignedBB", .{ rt.zstrC(o.ce.*.name), rt.zstrC(name) });
            }
            const b = try aabb.readBox(bbz.value.obj);
            if (b.intersects(query, eps)) {
                var item: c.zval = undefined;
                rt.retObjectCopy(&item, o);
                _ = c.zend_hash_next_index_insert(out.value.arr, &item);
            }
        }
    }

    pub fn overlappingBoxes(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 3);
        const query = try aabb.argBox(ctx, 1);
        const arr = (try ctx.call.expectArg(2, .{ .array = .{} }, {})).ptr();
        const eps = try optFloat(ctx, 3, core.geom.default_epsilon);
        const out = rt.ret(ctx);
        rt.newArray(out, 0);
        errdefer {
            c.zval_ptr_dtor(out);
            rt.setNull(out);
        }
        var pos: c.HashPosition = 0;
        c.zend_hash_internal_pointer_reset_ex(arr, &pos);
        while (c.zend_hash_get_current_data_ex(arr, &pos)) |raw| : (_ = c.zend_hash_move_forward_ex(arr, &pos)) {
            const zv = rt.deref(raw);
            if (rt.ztype(zv) != rt.IS_OBJECT or !rt.instanceOf(zv.value.obj, aabb.bb_ce)) return typeErrorArg(2, "must contain only quark\\math\\AxisAlignedBB, %s found", zv);
            if ((try aabb.readBox(zv.value.obj)).intersects(query, eps)) {
                var key: c.zval = undefined;
                c.zend_hash_get_current_key_zval_ex(arr, &key, &pos);
                _ = c.zend_hash_next_index_insert(out.value.arr, &key);
            }
        }
    }
};

var bounding_box_name: *c.zend_string = undefined;

pub fn startup() void {
    bounding_box_name = c.zend_string_init_interned.?("boundingBox", 11, true);
}

pub const Physics = struct {
    pub fn __construct() void {}

    pub fn motionStep(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(3, 7);
        const m = try vector.argV3(ctx, 1);
        const p = physics.MotionParams{
            .drag = try ctx.call.expectArg(2, .{ .float = .{} }, {}),
            .gravity = try ctx.call.expectArg(3, .{ .float = .{} }, {}),
            .gravity_enabled = try optBool(ctx, 4, true),
            .drag_before_gravity = try optBool(ctx, 5, false),
            .ground_friction = try optFloat(ctx, 6, 1.0),
            .threshold = try optFloat(ctx, 7, 0.00001),
        };
        vector.newV3(rt.ret(ctx), physics.motionStep(m, p));
    }

    pub fn knockBack(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(3, 5);
        const m = try vector.argV3(ctx, 1);
        const x = try ctx.call.expectArg(2, .{ .float = .{} }, {});
        const z = try ctx.call.expectArg(3, .{ .float = .{} }, {});
        const force = try optFloat(ctx, 4, 0.4);
        var limit: ?f64 = 0.4;
        if (ctx.call.argCount() >= 5) {
            limit = if (rt.ztype(rt.arg(ctx, 5)) == rt.IS_NULL) null else try ctx.call.expectArg(5, .{ .float = .{} }, {});
        }
        if (physics.knockBack(m, x, z, force, limit)) |r| vector.newV3(rt.ret(ctx), r);
    }

    pub fn directionPlane(ctx: Ctx, yaw: f64) void {
        const p = physics.directionPlane(yaw);
        vector.newV2(rt.ret(ctx), p[0], p[1]);
    }

    pub fn horizontalFacing(yaw: f64) i64 {
        return physics.horizontalFacing(yaw);
    }

    fn pair(ctx: Ctx, v: [2]f64) void {
        const out = rt.ret(ctx);
        rt.newArray(out, 2);
        for (v) |d| {
            var zv: c.zval = undefined;
            rt.setDouble(&zv, d);
            _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
        }
    }

    pub fn lookAt(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        pair(ctx, physics.lookAt(try vector.argV3(ctx, 1), try vector.argV3(ctx, 2)));
    }

    pub fn motionRotation(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        pair(ctx, physics.motionRotation(try vector.argV3(ctx, 1)));
    }

    pub fn predictTrajectory(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(5, 6);
        var pos = try vector.argV3(ctx, 1);
        var m = try vector.argV3(ctx, 2);
        const p = physics.MotionParams{
            .drag = try ctx.call.expectArg(3, .{ .float = .{} }, {}),
            .gravity = try ctx.call.expectArg(4, .{ .float = .{} }, {}),
            .drag_before_gravity = try optBool(ctx, 6, false),
        };
        const ticks = try ctx.call.expectArg(5, .{ .int = .{} }, {});
        if (ticks < 0 or ticks > 1_000_000) return rt.valueError("ticks must be between 0 and 1000000", .{});
        const n: usize = @intCast(ticks);
        const s: *c.zend_string = c.zend_string_alloc(n * 24, false);
        const dst = s.val();
        for (0..n) |t| {
            m = physics.motionStep(m, p);
            inline for (0..3) |a| {
                pos[a] = pos[a].add(m[a]);
                std.mem.writeInt(u64, dst[t * 24 + a * 8 ..][0..8], @bitCast(pos[a].toFloat()), .little);
            }
        }
        dst[n * 24] = 0;
        const out = rt.ret(ctx);
        out.value.str = s;
        out.u1.type_info = c.IS_STRING_EX;
    }
};

pub const SpatialClass = phpz.Class("quark\\math\\collision\\Spatial", Spatial, .{});
pub const PhysicsClass = phpz.Class("quark\\math\\physics\\Physics", Physics, .{});
