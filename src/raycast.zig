const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const core = rt.core;
const geom = core.geom;
const voxel = core.voxel;
const Num = rt.Num;
const NumVec = rt.NumVec;
const Box = rt.Box;
const Ctx = rt.Ctx;
const Error = rt.Error;
const vector = @import("vector.zig");
const aabb = @import("aabb.zig");
const region = @import("region.zig");

var hit_ce: rt.Ce = undefined;
var hit_block: [3]rt.Prop = undefined;

pub fn startup() void {
    hit_ce = rt.cePtr(VoxelHitClass.entry);
    hit_block = .{ rt.Prop.resolve(hit_ce, "blockX"), rt.Prop.resolve(hit_ce, "blockY"), rt.Prop.resolve(hit_ce, "blockZ") };
}

const State = enum { zero_length, fresh, running, done };

pub const Iter = struct {
    ray: voxel.Ray = undefined,
    initial: ?voxel.Ray = null,
    state: State = .done,
    index: i64 = 0,
    cached: c.zval = std.mem.zeroes(c.zval),

    pub fn __construct() Iter {
        return .{};
    }

    fn deinit(self: *Iter) void {
        self.drop();
    }

    /// Clears the slot before releasing, a destructor may re-enter the iterator.
    fn drop(self: *Iter) void {
        var old = self.cached;
        self.cached = std.mem.zeroes(c.zval);
        if (rt.ztype(&old) != rt.IS_UNDEF) c.zval_ptr_dtor(&old);
    }

    fn gc(self: *Iter, buf: *phpz.GcBuffer) void {
        if (rt.ztype(&self.cached) != rt.IS_UNDEF) buf.add(phpz.Zval.from(&self.cached));
    }

    fn start(self: *Iter) Error!void {
        if (self.state == .fresh or self.state == .zero_length) try self.restart();
    }

    fn restart(self: *Iter) Error!void {
        self.drop();
        if (self.state == .zero_length) {
            // Like a generator that threw, later traversals yield nothing
            self.state = .done;
            return rt.invalidArgument(voxel.zero_length_message, .{});
        }
        self.ray = self.initial orelse return;
        self.index = 0;
        self.state = .running;
    }

    pub fn current(self: *Iter, ctx: Ctx) Error!void {
        try self.start();
        if (self.state != .running) return;
        if (rt.ztype(&self.cached) == rt.IS_UNDEF) vector.newV3(&self.cached, self.ray.block);
        rt.copy(rt.ret(ctx), &self.cached);
    }

    pub fn key(self: *Iter, ctx: Ctx) Error!void {
        try self.start();
        if (self.state == .running) rt.setLong(rt.ret(ctx), self.index);
    }

    pub fn next(self: *Iter) Error!void {
        try self.start();
        if (self.state != .running) return;
        self.drop();
        if (self.ray.advance()) {
            self.index += 1;
        } else {
            self.state = .done;
        }
    }

    pub fn rewind(self: *Iter) Error!void {
        try self.restart();
    }

    pub fn valid(self: *Iter) Error!bool {
        try self.start();
        return self.state == .running;
    }
};

fn newIterator(ctx: Ctx, start: NumVec, end: NumVec) Error!void {
    const w = try VoxelRayIteratorClass.create();
    const b = w.backing().?;
    if (voxel.Ray.init(start, end)) |ray| {
        b.initial = ray;
        b.state = .fresh;
    } else |_| {
        b.state = .zero_length;
    }
    const out = rt.ret(ctx);
    out.value.obj = w.object().ptr();
    out.u1.type_info = c.IS_OBJECT_EX;
}

pub const VoxelRayTrace = struct {
    pub fn __construct() void {}

    pub fn inDirection(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(3, 3);
        const start = try vector.argV3(ctx, 1);
        const dir = try vector.argV3(ctx, 2);
        const max = try ctx.call.expectArg(3, .{ .float = .{} }, {});
        var end: NumVec = undefined;
        inline for (0..3) |a| end[a] = start[a].add(Num.f(dir[a].toFloat() * max));
        try newIterator(ctx, start, end);
    }

    pub fn betweenPoints(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        try newIterator(ctx, try vector.argV3(ctx, 1), try vector.argV3(ctx, 2));
    }
};

fn newHit(out: *c.zval, h: core.raycast.BlockHit) void {
    var box: c.zval = undefined;
    const box_obj = aabb.newBox(&box, h.hit.box);
    const o = aabb.newRayTraceResult(out, hit_ce, box_obj, h.hit.face, h.hit.hit);
    c.zval_ptr_dtor(&box);
    inline for (0..3) |a| rt.setLong(rt.initSlot(o, hit_block[a]), h.cell[a]);
}

pub const VoxelHit = struct {
    pub fn __construct(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(6, 6);
        _ = try vector.argObject(ctx, 1, aabb.bb_ce);
        const face = try ctx.call.expectArg(2, .{ .int = .{} }, {});
        _ = try vector.argObject(ctx, 3, vector.v3_ce);
        const o = rt.this(ctx);
        var zv: c.zval = undefined;
        try rt.writeZval(o, aabb.rtr[0], rt.arg(ctx, 1));
        rt.setLong(&zv, face);
        try rt.writeZval(o, aabb.rtr[1], &zv);
        try rt.writeZval(o, aabb.rtr[2], rt.arg(ctx, 3));
        inline for (0..3) |a| {
            rt.setLong(&zv, try ctx.call.expectArg(4 + a, .{ .int = .{} }, {}));
            try rt.writeZval(o, hit_block[a], &zv);
        }
    }
};

const max_batch_segments = 1 << 20;

pub const Raycast = struct {
    pub fn __construct() void {}

    pub fn voxels(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 3);
        const start = try vector.argV3(ctx, 1);
        const end = try vector.argV3(ctx, 2);
        const limit = if (ctx.call.argCount() >= 3) try ctx.call.expectArg(3, .{ .int = .{} }, {}) else 4096;
        if (limit < 1 or limit > 1 << 24) return rt.valueError("limit must be between 1 and 16777216", .{});
        var ray = voxel.Ray.init(start, end) catch |e| return region.fail(e);
        const out = rt.ret(ctx);
        rt.newArray(out, 0);
        var count: i64 = 0;
        while (true) {
            const cell = ray.cell() orelse {
                c.zval_ptr_dtor(out);
                rt.setNull(out);
                return rt.valueError("Voxel coordinates overflowed", .{});
            };
            count += 1;
            if (count > limit) {
                c.zval_ptr_dtor(out);
                rt.setNull(out);
                return rt.valueError("The ray visits more than {d} voxels", .{limit});
            }
            for (cell) |v| {
                var zv: c.zval = undefined;
                rt.setLong(&zv, v);
                _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
            }
            if (!ray.advance()) break;
        }
    }

    pub fn blocks(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(3, 3);
        const r = try region.argRegion(ctx, 1);
        const start = try vector.argV3(ctx, 2);
        const end = try vector.argV3(ctx, 3);
        var budget = core.raycast.Budget{};
        const h = (core.raycast.firstBlock(r, start, end, &budget) catch |e| return region.fail(e)) orelse return;
        newHit(rt.ret(ctx), h);
    }

    pub fn lineOfSight(ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(3, 3);
        const r = try region.argRegion(ctx, 1);
        const start = try vector.argV3(ctx, 2);
        const end = try vector.argV3(ctx, 3);
        var budget = core.raycast.Budget{};
        const h = core.raycast.firstBlock(r, start, end, &budget) catch |e| switch (e) {
            error.ZeroLength => return true,
            else => return region.fail(e),
        };
        return h == null;
    }

    pub fn boxes(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(3, 4);
        const start = try vector.argV3(ctx, 1);
        var end = try vector.argV3(ctx, 2);
        const arr = (try ctx.call.expectArg(3, .{ .array = .{} }, {})).ptr();
        const e = if (ctx.call.argCount() >= 4) try ctx.call.expectArg(4, .{ .float = .{} }, {}) else 0.0;

        var best: ?core.geom.Intercept = null;
        var best_box: Box = undefined;
        var best_key: c.zval = undefined;
        rt.setNull(&best_key);
        defer c.zval_ptr_dtor(&best_key);
        var distance: f64 = geom.php_int_max_f;
        var pos: c.HashPosition = 0;
        c.zend_hash_internal_pointer_reset_ex(arr, &pos);
        while (c.zend_hash_get_current_data_ex(arr, &pos)) |raw| : (_ = c.zend_hash_move_forward_ex(arr, &pos)) {
            const zv = rt.deref(raw);
            if (rt.ztype(zv) != rt.IS_OBJECT or !rt.instanceOf(zv.value.obj, aabb.bb_ce)) {
                c.zend_argument_type_error(3, "must contain only quark\\math\\AxisAlignedBB, %s found", c.zend_zval_value_name(zv));
                return error.PhpException;
            }
            const box = (try aabb.readBox(zv.value.obj)).expand(.{ e, e, e });
            const h = geom.calculateIntercept(box, start, end) orelse continue;
            const d = geom.distanceSquaredNum(start, h.hit);
            if (d < distance) {
                distance = d;
                best = h;
                best_box = box;
                c.zval_ptr_dtor(&best_key);
                c.zend_hash_get_current_key_zval_ex(arr, &best_key, &pos);
                end = .{ Num.f(h.hit[0]), Num.f(h.hit[1]), Num.f(h.hit[2]) };
            }
        }
        const h = best orelse return;
        const out = rt.ret(ctx);
        rt.newArray(out, 2);
        var key: c.zval = undefined;
        rt.copy(&key, &best_key);
        _ = c.zend_hash_next_index_insert(out.value.arr, &key);
        var box: c.zval = undefined;
        const box_obj = aabb.newBox(&box, best_box);
        var res: c.zval = undefined;
        _ = aabb.newRayTraceResult(&res, aabb.rtr_ce, box_obj, h.face, h.hit);
        c.zval_ptr_dtor(&box);
        _ = c.zend_hash_next_index_insert(out.value.arr, &res);
    }

    pub fn batchBlocks(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        const r = try region.argRegion(ctx, 1);
        const segments = try ctx.call.expectArg(2, .{ .string = .{} }, {});
        if (segments.len % 48 != 0) return rt.valueError("Segments must be a multiple of 48 bytes", .{});
        const n = segments.len / 48;
        if (n > max_batch_segments) return rt.valueError("Too many segments", .{});
        const out = rt.ret(ctx);
        const s: *c.zend_string = c.zend_string_alloc(n * 56, false);
        const dst = s.val()[0 .. n * 56];
        var budget = core.raycast.Budget{};
        for (0..n) |i| {
            var v: [6]f64 = undefined;
            inline for (0..6) |k| v[k] = region.readDouble(segments[i * 48 + k * 8 ..][0..8]);
            const start = NumVec{ Num.f(v[0]), Num.f(v[1]), Num.f(v[2]) };
            const end = NumVec{ Num.f(v[3]), Num.f(v[4]), Num.f(v[5]) };
            const rec = dst[i * 56 ..][0..56];
            const hit = core.raycast.firstBlock(r, start, end, &budget) catch |e| {
                c.zend_string_efree(s);
                return region.fail(e);
            };
            if (hit) |h| {
                writeLong(rec[0..8], h.hit.face);
                inline for (0..3) |a| writeLong(rec[8 + a * 8 ..][0..8], h.cell[a]);
                inline for (0..3) |a| region.writeDouble(rec[32 + a * 8 ..][0..8], h.hit.hit[a]);
            } else {
                writeLong(rec[0..8], -1);
                @memset(rec[8..], 0);
            }
        }
        s.val()[n * 56] = 0;
        out.value.str = s;
        out.u1.type_info = c.IS_STRING_EX;
    }
};

fn writeLong(b: *[8]u8, v: i64) void {
    std.mem.writeInt(i64, b, v, .little);
}

pub const VoxelRayTraceClass = phpz.Class("quark\\math\\VoxelRayTrace", VoxelRayTrace, .{});
pub const VoxelHitClass = phpz.Class("quark\\math\\collision\\VoxelHit", VoxelHit, .{ .register = registerHit });
pub const VoxelRayIteratorClass = phpz.Class("quark\\math\\VoxelRayIterator", Iter, .{ .deinit = Iter.deinit, .gc = Iter.gc, .register = registerIterator });
pub const RaycastClass = phpz.Class("quark\\math\\collision\\Raycast", Raycast, .{});

fn registerHit(register_fn: anytype) *phpz.ClassEntry {
    return register_fn(.{aabb.RayTraceResultClass.entry});
}

fn registerIterator(register_fn: anytype) *phpz.ClassEntry {
    return register_fn(.{.builtin("Iterator")});
}
