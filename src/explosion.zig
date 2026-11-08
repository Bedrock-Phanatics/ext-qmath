//! qmath\ResistanceGrid and ExplosionMath.

const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const core = rt.core;
const ex = core.explosion;
const Ctx = rt.Ctx;
const Error = rt.Error;
const vector = @import("vector.zig");
const aabb = @import("aabb.zig");
const region = @import("region.zig");

fn fail(err: anyerror) Error {
    return switch (err) {
        error.UnknownCell => rt.throwCe(region.exception_ce, "The explosion reaches a cell with no resistance data"),
        error.OutOfRange => rt.throwCe(region.exception_ce, "The explosion reaches outside the resistance grid"),
        error.RegionTooLarge => rt.valueError("Grid bounds are inverted or exceed CollisionRegion::MAX_CELLS", .{}),
        error.InvalidArgument => rt.valueError("Invalid explosion parameters: radius and stepLen must be positive and finite, rays between 2 and 64", .{}),
        else => region.fail(err),
    };
}

pub const Grid = struct {
    grid: ?ex.Grid = null,

    pub fn __construct(min_x: i64, min_y: i64, min_z: i64, max_x: i64, max_y: i64, max_z: i64) Error!Grid {
        const g = ex.Grid.init(rt.allocator, .{ min_x, min_y, min_z }, .{ max_x, max_y, max_z }) catch |e| return fail(e);
        return .{ .grid = g };
    }

    fn deinit(self: *Grid) void {
        if (self.grid) |*g| g.deinit();
        self.grid = null;
    }

    fn get(self: *Grid) Error!*ex.Grid {
        if (self.grid) |*g| return g;
        return rt.throwCe(rt.phpCe("zend_ce_error"), "ResistanceGrid has not been constructed");
    }

    pub fn getBounds(self: *Grid, ctx: Ctx) Error!void {
        const g = (try self.get());
        const out = rt.ret(ctx);
        rt.newArray(out, 6);
        for ([6]i64{ g.min[0], g.min[1], g.min[2], g.min[0] + g.size[0] - 1, g.min[1] + g.size[1] - 1, g.min[2] + g.size[2] - 1 }) |v| {
            var zv: c.zval = undefined;
            rt.setLong(&zv, v);
            _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
        }
    }

    pub fn set(self: *Grid, x: i64, y: i64, z: i64, resistance: f64) Error!void {
        (try self.get()).set(x, y, z, resistance) catch |e| return switch (e) {
            error.InvalidArgument => rt.valueError("Resistance must not be NAN, use setInvalid()", .{}),
            else => fail(e),
        };
    }

    pub fn setInvalid(self: *Grid, x: i64, y: i64, z: i64) Error!void {
        (try self.get()).setInvalid(x, y, z) catch |e| return fail(e);
    }

    pub fn fill(self: *Grid, resistance: f64) Error!void {
        (try self.get()).fill(resistance) catch return rt.valueError("Resistance must not be NAN", .{});
    }

    pub fn setPacked(self: *Grid, values: []const u8) Error!void {
        const g = (try self.get());
        if (values.len != g.cellCount() * 8) return rt.valueError("Expected {d} bytes, one double per cell", .{g.cellCount() * 8});
        const tmp = rt.allocator.alloc(f64, g.cellCount()) catch return rt.oom();
        defer rt.allocator.free(tmp);
        for (tmp, 0..) |*v, i| v.* = region.readDouble(values[i * 8 ..][0..8]);
        g.setPacked(tmp) catch |e| return fail(e);
    }
};

/// mt_rand($min, $max), sharing PHP's generator state.
const PhpRng = struct {
    pub fn range(_: *PhpRng, min: i64, max: i64) i64 {
        return c.php_mt_rand_common(min, max);
    }
};

fn argGrid(ctx: Ctx, n: u32) Error!*ex.Grid {
    const o = try vector.argObject(ctx, n, rt.cePtr(ResistanceGridClass.entry));
    const w = ResistanceGridClass.fromObject(phpz.zend.Object.from(o)) catch return rt.typeError("Invalid ResistanceGrid", .{});
    const b = w.backing() orelse return rt.typeError("ResistanceGrid is not initialized", .{});
    if (b.grid == null) return rt.typeError("ResistanceGrid is not initialized", .{});
    return &b.grid.?;
}

fn retList(out: *c.zval, items: []const i64) void {
    rt.newArray(out, @intCast(items.len));
    for (items) |v| {
        var zv: c.zval = undefined;
        rt.setLong(&zv, v);
        _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
    }
}

fn params(ctx: Ctx, radius_arg: u32) Error!ex.Params {
    const radius = try ctx.call.expectArg(radius_arg, .{ .float = .{} }, {});
    const rays = if (ctx.call.argCount() >= radius_arg + 1) try ctx.call.expectArg(radius_arg + 1, .{ .int = .{} }, {}) else 16;
    const step = if (ctx.call.argCount() >= radius_arg + 2) try ctx.call.expectArg(radius_arg + 2, .{ .float = .{} }, {}) else 0.3;
    const p = ex.Params{ .radius = radius, .rays = rays, .step_len = step };
    p.validate() catch |e| return fail(e);
    return p;
}

pub const ExplosionMath = struct {
    pub fn __construct() void {}

    pub fn traceRays(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(3, 5);
        const g = try argGrid(ctx, 1);
        const source = try vector.argV3(ctx, 2);
        const p = try params(ctx, 3);
        var list: std.ArrayList(i64) = .empty;
        defer list.deinit(rt.allocator);
        var rng = PhpRng{};
        ex.traceRays(g, rt.allocator, source, p, &rng, &list) catch |e| return fail(e);
        retList(rt.ret(ctx), list.items);
    }

    pub fn traceRay(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(6, 8);
        const g = try argGrid(ctx, 1);
        const source = try vector.argV3(ctx, 2);
        const radius = try ctx.call.expectArg(3, .{ .float = .{} }, {});
        const i = try ctx.call.expectArg(4, .{ .int = .{} }, {});
        const j = try ctx.call.expectArg(5, .{ .int = .{} }, {});
        const k = try ctx.call.expectArg(6, .{ .int = .{} }, {});
        const rays = if (ctx.call.argCount() >= 7) try ctx.call.expectArg(7, .{ .int = .{} }, {}) else 16;
        const step = if (ctx.call.argCount() >= 8) try ctx.call.expectArg(8, .{ .float = .{} }, {}) else 0.3;
        const p = ex.Params{ .radius = radius, .rays = rays, .step_len = step };
        p.validate() catch |e| return fail(e);
        if (!ex.isBoundaryRay(p, i, j, k)) return rt.valueError("({d}, {d}, {d}) is not one of the explosion's rays", .{ i, j, k });
        var list: std.ArrayList(i64) = .empty;
        defer list.deinit(rt.allocator);
        var sink = ex.ListSink{ .list = &list, .allocator = rt.allocator, .grid = g };
        var rng = PhpRng{};
        ex.traceRay(g, source, p, i, j, k, &rng, &sink) catch |e| return fail(e);
        retList(rt.ret(ctx), list.items);
    }

    pub fn rayCount(rays: ?i64) Error!i64 {
        const r = rays orelse 16;
        if (r < 2 or r > 64) return rt.valueError("rays must be between 2 and 64", .{});
        return ex.rayCount(r);
    }

    pub fn exposure(ctx: Ctx) Error!f64 {
        try ctx.call.expectArgCount(3, 3);
        const r = try region.argRegion(ctx, 1);
        const origin = try vector.argV3(ctx, 2);
        const b = try region.validBox(try aabb.argBox(ctx, 3));
        return core.raycast.exposure(r, origin, b) catch |e| return region.fail(e);
    }

    pub fn exposures(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(3, 3);
        const r = try region.argRegion(ctx, 1);
        const origin = try vector.argV3(ctx, 2);
        const arr = (try ctx.call.expectArg(3, .{ .array = .{} }, {})).ptr();
        const out = rt.ret(ctx);
        rt.newArray(out, arr.nNumOfElements);
        errdefer {
            c.zval_ptr_dtor(out);
            rt.setNull(out);
        }
        var pos: c.HashPosition = 0;
        c.zend_hash_internal_pointer_reset_ex(arr, &pos);
        while (c.zend_hash_get_current_data_ex(arr, &pos)) |raw| : (_ = c.zend_hash_move_forward_ex(arr, &pos)) {
            const zv = rt.deref(raw);
            if (rt.ztype(zv) != rt.IS_OBJECT or !rt.instanceOf(zv.value.obj, aabb.bb_ce)) {
                c.zend_argument_type_error(3, "must contain only pocketmine\\math\\AxisAlignedBB, %s found", c.zend_zval_value_name(zv));
                return error.PhpException;
            }
            const b = try region.validBox(try aabb.readBox(zv.value.obj));
            const e = core.raycast.exposure(r, origin, b) catch |err| return region.fail(err);
            var val: c.zval = undefined;
            rt.setDouble(&val, e);
            var key: c.zval = undefined;
            c.zend_hash_get_current_key_zval_ex(arr, &key, &pos);
            _ = c.array_set_zval_key(out.value.arr, &key, &val);
            c.zval_ptr_dtor(&key);
        }
    }
};

pub const ResistanceGridClass = phpz.Class("qmath\\ResistanceGrid", Grid, .{ .deinit = Grid.deinit });
pub const ExplosionMathClass = phpz.Class("qmath\\ExplosionMath", ExplosionMath, .{});
