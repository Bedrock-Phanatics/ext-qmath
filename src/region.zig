//! qmath\CollisionRegion, Collision, MoveResult, SweepResult and CollisionDataException.

const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const core = rt.core;
const collision = core.collision;
const Box = rt.Box;
const Ctx = rt.Ctx;
const Error = rt.Error;
const ZObj = rt.ZObj;
const vector = @import("vector.zig");
const aabb = @import("aabb.zig");

pub var exception_ce: rt.Ce = undefined;
var move_ce: rt.Ce = undefined;
var sweep_ce: rt.Ce = undefined;
var mr: [11]rt.Prop = undefined;
var sr: [4]rt.Prop = undefined;

const move_props = [11][]const u8{ "dx", "dy", "dz", "boundingBox", "collidedX", "collidedY", "collidedZ", "collidedHorizontally", "collidedVertically", "onGround", "stepped" };

pub fn startup() void {
    exception_ce = rt.cePtr(CollisionDataExceptionClass.entry);
    move_ce = rt.cePtr(MoveResultClass.entry);
    sweep_ce = rt.cePtr(SweepResultClass.entry);
    inline for (move_props, 0..) |n, i| mr[i] = rt.Prop.resolve(move_ce, n);
    sr = .{ rt.Prop.resolve(sweep_ce, "time"), rt.Prop.resolve(sweep_ce, "face"), rt.Prop.resolve(sweep_ce, "box"), rt.Prop.resolve(sweep_ce, "key") };
}

/// Converts a native error into the matching PHP exception.
pub fn fail(err: anyerror) Error {
    return switch (err) {
        error.PhpException, error.UnwindExit => @errorCast(err),
        error.OutOfMemory => rt.oom(),
        error.OutOfRange => rt.throwCe(exception_ce, "The query needs cells outside the region"),
        error.UnknownCell => rt.throwCe(exception_ce, "The query needs a cell with no collision data"),
        error.InvalidBox => rt.valueError("Bounding boxes must be finite with min <= max", .{}),
        error.InvalidInfo => rt.valueError("Invalid collision info, or boxes given for INFO_CUBE or INFO_NONE", .{}),
        error.TooManyBoxes => rt.valueError("Too many collision boxes for one cell", .{}),
        error.RegionTooLarge => rt.valueError("Region bounds are inverted or exceed CollisionRegion::MAX_CELLS", .{}),
        error.Frozen => rt.throwCe(rt.phpCe("spl_ce_LogicException"), "Cannot modify a frozen collision region"),
        error.ZeroLength => rt.invalidArgument(core.voxel.zero_length_message, .{}),
        error.TooManySamples => rt.valueError("Bounding box is too large to sample", .{}),
        else => rt.throwFmt(rt.phpCe("zend_ce_error"), "qmath: {s}", .{@errorName(err)}),
    };
}

pub const Backing = struct {
    region: ?collision.Region = null,

    pub fn __construct(min_x: i64, min_y: i64, min_z: i64, max_x: i64, max_y: i64, max_z: i64) Error!Backing {
        const r = collision.Region.init(rt.allocator, .{ min_x, min_y, min_z }, .{ max_x, max_y, max_z }) catch |e| return fail(e);
        return .{ .region = r };
    }

    fn deinit(self: *Backing) void {
        if (self.region) |*r| r.deinit();
        self.region = null;
    }

    fn clone(self: *const Backing) Error!Backing {
        const r = self.region orelse return .{};
        var copy = r.clone(rt.allocator) catch |e| return fail(e);
        copy.frozen = r.frozen;
        return .{ .region = copy };
    }

    fn get(self: *Backing) Error!*collision.Region {
        if (self.region) |*r| return r;
        return rt.throwCe(rt.phpCe("zend_ce_error"), "CollisionRegion has not been constructed");
    }

    pub fn getBounds(self: *Backing, ctx: Ctx) Error!void {
        const r = (try self.get());
        const max = r.maxCorner();
        const out = rt.ret(ctx);
        rt.newArray(out, 6);
        for ([6]i64{ r.min[0], r.min[1], r.min[2], max[0], max[1], max[2] }) |v| {
            var zv: c.zval = undefined;
            rt.setLong(&zv, v);
            _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
        }
    }

    pub fn getVersion(self: *Backing) Error!i64 {
        return @intCast((try self.get()).version & std.math.maxInt(i64));
    }

    pub fn isFrozen(self: *Backing) Error!bool {
        return (try self.get()).frozen;
    }

    pub fn freeze(self: *Backing) Error!void {
        (try self.get()).frozen = true;
    }

    pub fn snapshot(self: *Backing, ctx: Ctx) Error!void {
        var copy = (try self.get()).clone(rt.allocator) catch |e| return fail(e);
        errdefer copy.deinit();
        copy.frozen = true;
        const w = try CollisionRegionClass.create();
        w.backing().?.* = .{ .region = copy };
        const out = rt.ret(ctx);
        out.value.obj = w.object().ptr();
        out.u1.type_info = c.IS_OBJECT_EX;
    }

    pub fn contains(self: *Backing, x: i64, y: i64, z: i64) Error!bool {
        return (try self.get()).index(x, y, z) != null;
    }

    pub fn isKnown(self: *Backing, x: i64, y: i64, z: i64) Error!bool {
        _ = (try self.get()).cellInfo(x, y, z) catch return false;
        return true;
    }

    pub fn setCell(self: *Backing, ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(4, 5);
        const x = try ctx.call.expectArg(1, .{ .int = .{} }, {});
        const y = try ctx.call.expectArg(2, .{ .int = .{} }, {});
        const z = try ctx.call.expectArg(3, .{ .int = .{} }, {});
        const info = try parseInfo(try ctx.call.expectArg(4, .{ .int = .{} }, {}));
        var buf: [collision.max_boxes_per_cell]Box = undefined;
        var n: usize = 0;
        if (ctx.call.argCount() >= 5) {
            const list = try ctx.call.expectArg(5, .{ .array = .{} }, {});
            n = try readBoxList(list.ptr(), &buf, 5);
        }
        (try self.get()).setCell(x, y, z, info, buf[0..n]) catch |e| return cellFail(e, x, y, z);
    }

    pub fn setCellPacked(self: *Backing, x: i64, y: i64, z: i64, info: i64, boxes: []const u8) Error!void {
        const kind = try parseInfo(info);
        var buf: [collision.max_boxes_per_cell]Box = undefined;
        const n = try readPackedBoxes(boxes, &buf);
        (try self.get()).setCell(x, y, z, kind, buf[0..n]) catch |e| return cellFail(e, x, y, z);
    }

    pub fn fill(self: *Backing, info: i64) Error!void {
        (try self.get()).fill(try parseInfo(info)) catch |e| return fail(e);
    }

    pub fn invalidateCell(self: *Backing, x: i64, y: i64, z: i64) Error!void {
        (try self.get()).invalidateCell(x, y, z) catch |e| return fail(e);
    }

    pub fn invalidateBlock(self: *Backing, x: i64, y: i64, z: i64) Error!void {
        (try self.get()).invalidateBlock(x, y, z) catch |e| return fail(e);
    }

    pub fn invalidateChunk(self: *Backing, chunk_x: i64, chunk_z: i64) Error!void {
        (try self.get()).invalidateChunk(chunk_x, chunk_z) catch |e| return fail(e);
    }

    pub fn invalidateAll(self: *Backing) Error!void {
        (try self.get()).invalidateAll() catch |e| return fail(e);
    }

    pub fn isComplete(self: *Backing, ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(1, 1);
        const b = try validBox(try aabb.argBox(ctx, 1));
        return (try self.get()).isComplete(b);
    }

    pub fn getCollisionBoxes(self: *Backing, ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const b = try validBox(try aabb.argBox(ctx, 1));
        const alloc = rt.allocator;
        var list: std.ArrayList(Box) = .empty;
        defer list.deinit(alloc);
        collision.collectBoxes((try self.get()), alloc, b, &list) catch |e| return fail(e);
        retBoxes(rt.ret(ctx), list.items);
    }

    pub fn collides(self: *Backing, ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(1, 1);
        const b = try validBox(try aabb.argBox(ctx, 1));
        return (try self.get()).collides(b) catch |e| return fail(e);
    }

    pub fn getCellBoxes(self: *Backing, ctx: Ctx, x: i64, y: i64, z: i64) Error!void {
        var scratch: Box = undefined;
        const boxes = (try self.get()).ownBoxes(x, y, z, &scratch) catch |e| return fail(e);
        retBoxes(rt.ret(ctx), boxes);
    }

    pub fn getCellInfo(self: *Backing, x: i64, y: i64, z: i64) Error!i64 {
        const info = (try self.get()).cellInfo(x, y, z) catch |e| switch (e) {
            error.UnknownCell => return -1,
            else => return fail(e),
        };
        return @intFromEnum(info);
    }
};

fn cellFail(err: anyerror, x: i64, y: i64, z: i64) Error {
    if (err == error.OutOfRange) return rt.valueError("Cell {d} {d} {d} is outside the region", .{ x, y, z });
    return fail(err);
}

fn parseInfo(v: i64) Error!collision.Info {
    return collision.Info.fromInt(v) orelse rt.valueError("Invalid collision info {d}", .{v});
}

pub fn validBox(b: Box) Error!Box {
    if (!b.isValid()) return fail(error.InvalidBox);
    return b;
}

/// Reads a PHP list of AxisAlignedBB into `buf`.
fn readBoxList(arr: *c.zend_array, buf: []Box, arg_num: u32) Error!usize {
    const count = arr.nNumOfElements;
    if (count > buf.len) return fail(error.TooManyBoxes);
    var n: usize = 0;
    var pos: c.HashPosition = 0;
    c.zend_hash_internal_pointer_reset_ex(arr, &pos);
    while (c.zend_hash_get_current_data_ex(arr, &pos)) |zv_raw| : (_ = c.zend_hash_move_forward_ex(arr, &pos)) {
        const zv = rt.deref(zv_raw);
        if (rt.ztype(zv) != rt.IS_OBJECT or !rt.instanceOf(zv.value.obj, aabb.bb_ce)) {
            c.zend_argument_type_error(arg_num, "must contain only pocketmine\\math\\AxisAlignedBB, %s found", c.zend_zval_value_name(zv));
            return error.PhpException;
        }
        buf[n] = try aabb.readBox(zv.value.obj);
        n += 1;
    }
    return n;
}

/// Parses six little-endian doubles per box.
pub fn readPackedBoxes(bytes: []const u8, buf: []Box) Error!usize {
    if (bytes.len % 48 != 0) return rt.valueError("Packed boxes must be a multiple of 48 bytes", .{});
    const n = bytes.len / 48;
    if (n > buf.len) return fail(error.TooManyBoxes);
    for (0..n) |i| {
        var v: [6]f64 = undefined;
        inline for (0..6) |k| v[k] = readDouble(bytes[i * 48 + k * 8 ..][0..8]);
        buf[i] = Box.init(v[0], v[1], v[2], v[3], v[4], v[5]);
    }
    return n;
}

pub inline fn readDouble(b: *const [8]u8) f64 {
    return @bitCast(std.mem.readInt(u64, b, .little));
}

pub inline fn writeDouble(b: *[8]u8, v: f64) void {
    std.mem.writeInt(u64, b, @bitCast(v), .little);
}

fn retBoxes(out: *c.zval, boxes: []const Box) void {
    rt.newArray(out, @intCast(boxes.len));
    for (boxes) |b| {
        var zv: c.zval = undefined;
        _ = aabb.newBox(&zv, b);
        _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
    }
}

/// The CollisionRegion argument `n`, with ZPP's error for other types.
pub fn argRegion(ctx: Ctx, n: u32) Error!*collision.Region {
    const o = try vector.argObject(ctx, n, rt.cePtr(CollisionRegionClass.entry));
    const w = CollisionRegionClass.fromObject(phpz.zend.Object.from(o)) catch return rt.typeError("Invalid CollisionRegion", .{});
    const b = w.backing() orelse return rt.typeError("CollisionRegion is not initialized", .{});
    if (b.region == null) return rt.typeError("CollisionRegion is not initialized", .{});
    return &b.region.?;
}

fn finite(v: f64, comptime name: []const u8) Error!f64 {
    if (!std.math.isFinite(v)) return rt.valueError(name ++ " must be finite", .{});
    return v;
}

fn newMoveResult(out: *c.zval, r: collision.MoveResult) void {
    const o = rt.newObject(out, move_ce);
    inline for (0..3) |a| rt.setDouble(rt.initSlot(o, mr[a]), r.d[a]);
    _ = aabb.newBox(rt.initSlot(o, mr[3]), r.bb);
    const flags = [7]bool{ r.collided[0], r.collided[1], r.collided[2], r.horizontal, r.vertical, r.on_ground, r.stepped };
    inline for (flags, 0..) |f, i| rt.setBool(rt.initSlot(o, mr[4 + i]), f);
}

fn newSweepResult(out: *c.zval, time: f64, face: i64, box: *c.zval, key: *c.zval) void {
    const o = rt.newObject(out, sweep_ce);
    rt.setDouble(rt.initSlot(o, sr[0]), time);
    rt.setLong(rt.initSlot(o, sr[1]), face);
    rt.copy(rt.initSlot(o, sr[2]), box);
    rt.copy(rt.initSlot(o, sr[3]), key);
}

pub const Collision = struct {
    pub fn __construct() void {}

    pub fn move(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(5, 7);
        const region = try argRegion(ctx, 1);
        const b = try validBox(try aabb.argBox(ctx, 2));
        var d: rt.Vec = undefined;
        d[0] = try finite(try ctx.call.expectArg(3, .{ .float = .{} }, {}), "dx");
        d[1] = try finite(try ctx.call.expectArg(4, .{ .float = .{} }, {}), "dy");
        d[2] = try finite(try ctx.call.expectArg(5, .{ .float = .{} }, {}), "dz");
        const step = if (ctx.call.argCount() >= 6) try finite(try ctx.call.expectArg(6, .{ .float = .{} }, {}), "stepHeight") else 0.0;
        const on_ground = if (ctx.call.argCount() >= 7) try ctx.call.expectArg(7, .{ .bool = .{} }, {}) else false;
        const r = collision.move(region, rt.allocator, b, d, step, on_ground) catch |e| return fail(e);
        newMoveResult(rt.ret(ctx), r);
    }

    pub fn sweep(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(5, 5);
        const region = try argRegion(ctx, 1);
        const b = try validBox(try aabb.argBox(ctx, 2));
        const d = try readDelta(ctx, 3);
        const hit = (collision.sweep(region, rt.allocator, b, d) catch |e| return fail(e)) orelse return;
        var box: c.zval = undefined;
        _ = aabb.newBox(&box, hit.box);
        defer c.zval_ptr_dtor(&box);
        var key: c.zval = undefined;
        rt.setLong(&key, @intCast(hit.index));
        newSweepResult(rt.ret(ctx), hit.time, hit.face, &box, &key);
    }

    pub fn sweepBoxes(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(5, 5);
        const b = try validBox(try aabb.argBox(ctx, 1));
        const d = try readDelta(ctx, 2);
        const arr = (try ctx.call.expectArg(5, .{ .array = .{} }, {})).ptr();
        var best: ?core.geom.Sweep = null;
        var best_val: ?*c.zval = null;
        var best_key: c.zval = undefined;
        rt.setNull(&best_key);
        var pos: c.HashPosition = 0;
        c.zend_hash_internal_pointer_reset_ex(arr, &pos);
        while (c.zend_hash_get_current_data_ex(arr, &pos)) |raw| : (_ = c.zend_hash_move_forward_ex(arr, &pos)) {
            const zv = rt.deref(raw);
            if (rt.ztype(zv) != rt.IS_OBJECT or !rt.instanceOf(zv.value.obj, aabb.bb_ce)) {
                c.zend_argument_type_error(5, "must contain only pocketmine\\math\\AxisAlignedBB, %s found", c.zend_zval_value_name(zv));
                return error.PhpException;
            }
            const box = try validBox(try aabb.readBox(zv.value.obj));
            const s = core.geom.sweep(b, d, box) orelse continue;
            if (best == null or s.time < best.?.time) {
                best = s;
                best_val = zv;
                c.zend_hash_get_current_key_zval_ex(arr, &best_key, &pos);
            }
        }
        const hit = best orelse return;
        defer c.zval_ptr_dtor(&best_key);
        newSweepResult(rt.ret(ctx), hit.time, hit.face, best_val.?, &best_key);
    }
};

fn readDelta(ctx: Ctx, first: u32) Error!rt.Vec {
    return .{
        try finite(try ctx.call.expectArg(first, .{ .float = .{} }, {}), "dx"),
        try finite(try ctx.call.expectArg(first + 1, .{ .float = .{} }, {}), "dy"),
        try finite(try ctx.call.expectArg(first + 2, .{ .float = .{} }, {}), "dz"),
    };
}

const Empty = struct {
    pub fn __construct() void {}
};

fn registerException(register_fn: anytype) *phpz.ClassEntry {
    return register_fn(.{.builtin("RuntimeException")});
}

pub const CollisionDataExceptionClass = phpz.Class("qmath\\CollisionDataException", struct {}, .{ .register = registerException });
pub const CollisionRegionClass = phpz.Class("qmath\\CollisionRegion", Backing, .{ .deinit = Backing.deinit, .clone = Backing.clone });
pub const MoveResultClass = phpz.Class("qmath\\MoveResult", Empty, .{});
pub const SweepResultClass = phpz.Class("qmath\\SweepResult", Empty, .{});
pub const CollisionClass = phpz.Class("qmath\\Collision", Collision, .{});
