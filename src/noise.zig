//! Matches Quark's world generator Simplex noise.

const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const core = rt.core;
const noise = core.noise;
const Ctx = rt.Ctx;
const Error = rt.Error;

fn invalid(comptime msg: []const u8) Error {
    return rt.invalidArgument(msg, .{});
}

pub const Simplex = struct {
    state: ?noise.Simplex = null,

    fn get(self: *Simplex) Error!*noise.Simplex {
        if (self.state) |*st| return st;
        return rt.throwCe(rt.phpCe("zend_ce_error"), "Simplex has not been constructed");
    }

    pub fn __construct(ctx: Ctx) Error!Simplex {
        try ctx.call.expectArgCount(7, 7);
        var st: noise.Simplex = undefined;
        try readPermutation(ctx, &st.perm);
        inline for (0..3) |a| {
            st.offset[a] = try ctx.call.expectArg(2 + a, .{ .float = .{} }, {});
            if (!std.math.isFinite(st.offset[a])) return rt.valueError("Offsets must be finite", .{});
        }
        st.octaves = try ctx.call.expectArg(5, .{ .int = .{} }, {});
        st.persistence = try ctx.call.expectArg(6, .{ .float = .{} }, {});
        st.expansion = try ctx.call.expectArg(7, .{ .float = .{} }, {});
        if (st.octaves < 1 or st.octaves > 64) return rt.valueError("octaves must be between 1 and 64", .{});
        if (!std.math.isFinite(st.persistence) or !std.math.isFinite(st.expansion)) return rt.valueError("persistence and expansion must be finite", .{});
        return .{ .state = st };
    }

    pub fn getNoise2D(self: *Simplex, x: f64, y: f64) Error!f64 {
        return (try self.get()).getNoise2D(x, y);
    }

    pub fn getNoise3D(self: *Simplex, x: f64, y: f64, z: f64) Error!f64 {
        return (try self.get()).getNoise3D(x, y, z);
    }

    pub fn noise2D(self: *Simplex, x: f64, z: f64, normalized: ?bool) Error!f64 {
        return (try self.get()).noise2D(x, z, normalized orelse false);
    }

    pub fn noise3D(self: *Simplex, x: f64, y: f64, z: f64, normalized: ?bool) Error!f64 {
        return (try self.get()).noise3D(x, y, z, normalized orelse false);
    }

    pub fn getFastNoise1D(self: *Simplex, ctx: Ctx, x_size: i64, rate: i64, x: i64, y: i64, z: i64) Error!void {
        if (rate == 0) return invalid("samplingRate cannot be 0");
        if (x_size < 0 or rate < 0) return rt.valueError("xSize and samplingRate must not be negative", .{});
        if (x_size >= noise.max_samples) return rt.valueError("Sample grid is too large", .{});
        if (@rem(x_size, rate) != 0) return invalid("xSize % samplingRate must return 0");
        const n: usize = @intCast(x_size + 1);
        const buf = rt.allocator.alloc(f64, n) catch return rt.oom();
        defer rt.allocator.free(buf);
        noise.fastNoise1D(try self.get(), buf, x_size, rate, x, y, z);
        const out = rt.ret(ctx);
        rt.newArray(out, @intCast(n));
        for (buf) |v| appendDouble(out, v);
    }

    pub fn getFastNoise2D(self: *Simplex, ctx: Ctx, x_size: i64, z_size: i64, rate: i64, x: i64, y: i64, z: i64) Error!void {
        try sampling(x_size, rate, "xSize");
        try sampling(z_size, rate, "zSize");
        const xs: usize = @intCast(x_size + 1);
        const zs: usize = @intCast(z_size + 1);
        if (xs * zs > noise.max_samples) return rt.valueError("Sample grid is too large", .{});
        const buf = rt.allocator.alloc(f64, xs * zs) catch return rt.oom();
        defer rt.allocator.free(buf);
        const set = rt.allocator.alloc(bool, xs * zs) catch return rt.oom();
        defer rt.allocator.free(set);
        noise.fastNoise2D(try self.get(), buf, set, x_size, z_size, rate, x, y, z);
        const out = rt.ret(ctx);
        rt.newArray(out, @intCast(xs));
        for (0..xs) |i| {
            var row: c.zval = undefined;
            rt.newArray(&row, @intCast(zs));
            for (0..zs) |k| {
                if (set[i * zs + k]) appendDouble(&row, buf[i * zs + k]) else appendNull(&row);
            }
            _ = c.zend_hash_next_index_insert(out.value.arr, &row);
        }
    }

    fn grid(x_size: i64, y_size: i64, z_size: i64, xr: i64, yr: i64, zr: i64, x: i64, y: i64, z: i64) Error!noise.Sampling3D {
        try sampling(x_size, xr, "xSize");
        try sampling(y_size, yr, "ySize");
        try sampling(z_size, zr, "zSize");
        const g = noise.Sampling3D{ .size = .{ x_size, y_size, z_size }, .rate = .{ xr, yr, zr }, .origin = .{ x, y, z } };
        g.validate() catch return rt.valueError("Sample grid is too large", .{});
        return g;
    }

    pub fn getFastNoise3D(self: *Simplex, ctx: Ctx, x_size: i64, y_size: i64, z_size: i64, xr: i64, yr: i64, zr: i64, x: i64, y: i64, z: i64) Error!void {
        const g = try grid(x_size, y_size, z_size, xr, yr, zr, x, y, z);
        const buf = rt.allocator.alloc(f64, g.len()) catch return rt.oom();
        defer rt.allocator.free(buf);
        const set = rt.allocator.alloc(bool, g.len()) catch return rt.oom();
        defer rt.allocator.free(set);
        noise.fastNoise3D(try self.get(), buf, set, g);
        const out = rt.ret(ctx);
        const xs: usize = @intCast(x_size + 1);
        const ys: usize = @intCast(y_size + 1);
        const zs: usize = @intCast(z_size + 1);
        rt.newArray(out, @intCast(xs));
        var i: usize = 0;
        for (0..xs) |_| {
            var plane: c.zval = undefined;
            rt.newArray(&plane, @intCast(zs));
            for (0..zs) |_| {
                var column: c.zval = undefined;
                rt.newArray(&column, @intCast(ys));
                for (0..ys) |_| {
                    var zv: c.zval = undefined;
                    if (set[i]) rt.setDouble(&zv, buf[i]) else rt.setLong(&zv, 0);
                    _ = c.zend_hash_next_index_insert(column.value.arr, &zv);
                    i += 1;
                }
                _ = c.zend_hash_next_index_insert(plane.value.arr, &column);
            }
            _ = c.zend_hash_next_index_insert(out.value.arr, &plane);
        }
    }

    pub fn getFastNoise3DPacked(self: *Simplex, ctx: Ctx, x_size: i64, y_size: i64, z_size: i64, xr: i64, yr: i64, zr: i64, x: i64, y: i64, z: i64) Error!void {
        const g = try grid(x_size, y_size, z_size, xr, yr, zr, x, y, z);
        const buf = rt.allocator.alloc(f64, g.len()) catch return rt.oom();
        defer rt.allocator.free(buf);
        const set = rt.allocator.alloc(bool, g.len()) catch return rt.oom();
        defer rt.allocator.free(set);
        noise.fastNoise3D(try self.get(), buf, set, g);
        const s: *c.zend_string = c.zend_string_alloc(buf.len * 8, false);
        const dst = s.val();
        for (buf, 0..) |v, k| std.mem.writeInt(u64, dst[k * 8 ..][0..8], @bitCast(v), .little);
        dst[buf.len * 8] = 0;
        const out = rt.ret(ctx);
        out.value.str = s;
        out.u1.type_info = c.IS_STRING_EX;
    }
};

fn sampling(size: i64, rate: i64, comptime name: []const u8) Error!void {
    if (rate <= 0) return rt.valueError("Sampling rates must be positive", .{});
    if (size < 0) return rt.valueError(name ++ " must not be negative", .{});
    if (size >= noise.max_samples) return rt.valueError("Sample grid is too large", .{});
    if (@rem(size, rate) != 0) return invalid(name ++ " % samplingRate must return 0");
}

fn appendDouble(arr: *c.zval, v: f64) void {
    var zv: c.zval = undefined;
    rt.setDouble(&zv, v);
    _ = c.zend_hash_next_index_insert(arr.value.arr, &zv);
}

fn appendNull(arr: *c.zval) void {
    var zv: c.zval = undefined;
    rt.setNull(&zv);
    _ = c.zend_hash_next_index_insert(arr.value.arr, &zv);
}

/// Takes 256 entries (mirrored to 512) or all 512, as an int list or byte string.
fn readPermutation(ctx: Ctx, perm: *[512]u8) Error!void {
    const zv = rt.arg(ctx, 1);
    switch (rt.ztype(zv)) {
        rt.IS_STRING => {
            const bytes = rt.zstr(zv.value.str);
            if (bytes.len != 256 and bytes.len != 512) return rt.valueError("Permutation strings must be 256 or 512 bytes", .{});
            @memcpy(perm[0..bytes.len], bytes);
            if (bytes.len == 256) @memcpy(perm[256..], bytes);
        },
        rt.IS_ARRAY => {
            const arr: *c.zend_array = zv.value.arr;
            const n = arr.nNumOfElements;
            if (n != 256 and n != 512) return rt.valueError("Permutation arrays must have 256 or 512 entries", .{});
            var i: usize = 0;
            while (i < n) : (i += 1) {
                const item = c.zend_hash_index_find(arr, @intCast(i)) orelse return rt.valueError("Permutation arrays must be lists", .{});
                const v = rt.deref(item);
                if (rt.ztype(v) != rt.IS_LONG or v.value.lval < 0 or v.value.lval > 255) return rt.valueError("Permutation entries must be ints between 0 and 255", .{});
                perm[i] = @intCast(v.value.lval);
            }
            if (n == 256) @memcpy(perm[256..], perm[0..256]);
        },
        else => {
            c.zend_argument_type_error(1, "must be of type array|string, %s given", c.zend_zval_value_name(zv));
            return error.PhpException;
        },
    }
}

pub const SimplexClass = phpz.Class("qmath\\Simplex", Simplex, .{});
