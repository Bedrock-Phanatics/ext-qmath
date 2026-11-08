const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const Rgba = rt.core.color.Rgba;
const Ctx = rt.Ctx;
const Error = rt.Error;
const vector = @import("vector.zig");

var ce: rt.Ce = undefined;
var p: [4]rt.Prop = undefined; // a, r, g, b

pub fn startup() void {
    ce = rt.cePtr(ColorClass.entry);
    p = .{ rt.Prop.resolve(ce, "a"), rt.Prop.resolve(ce, "r"), rt.Prop.resolve(ce, "g"), rt.Prop.resolve(ce, "b") };
}

fn read(o: rt.ZObj) Error!Rgba {
    var v: [4]u8 = undefined;
    inline for (0..4) |i| v[i] = @truncate(@as(u64, @bitCast(try rt.readLong(o, p[i]))));
    return .{ .a = v[0], .r = v[1], .g = v[2], .b = v[3] };
}

fn self(ctx: Ctx) Error!Rgba {
    return read(rt.this(ctx));
}

fn argColor(ctx: Ctx, n: u32) Error!Rgba {
    return read(try vector.argObject(ctx, n, ce));
}

fn ret(ctx: Ctx, col: Rgba) void {
    newColor(rt.ret(ctx), col);
}

pub fn newColor(out: *c.zval, col: Rgba) void {
    const o = rt.newObject(out, ce);
    const v = [4]u8{ col.a, col.r, col.g, col.b };
    inline for (0..4) |i| rt.setLong(rt.initSlot(o, p[i]), v[i]);
}

fn triple(ctx: Ctx, v: [3]f64) void {
    const out = rt.ret(ctx);
    rt.newArray(out, 3);
    for (v) |d| {
        var zv: c.zval = undefined;
        rt.setDouble(&zv, d);
        _ = c.zend_hash_next_index_insert(out.value.arr, &zv);
    }
}

pub const Color = struct {
    pub fn __construct(ctx: Ctx, r: i64, g: i64, b: i64, a: ?i64) Error!void {
        const col = Rgba.init(r, g, b, a orelse 0xff);
        const o = rt.this(ctx);
        const v = [4]u8{ col.a, col.r, col.g, col.b };
        inline for (0..4) |i| try rt.writeNum(o, p[i], true, rt.Num.i(v[i]));
    }

    pub fn getA(ctx: Ctx) Error!i64 {
        return (try self(ctx)).a;
    }

    pub fn getR(ctx: Ctx) Error!i64 {
        return (try self(ctx)).r;
    }

    pub fn getG(ctx: Ctx) Error!i64 {
        return (try self(ctx)).g;
    }

    pub fn getB(ctx: Ctx) Error!i64 {
        return (try self(ctx)).b;
    }

    pub fn mix(ctx: Ctx) Error!void {
        const n = ctx.call.argCount();
        if (n < 1) return phpz.exception.wrongParameterCount(1, std.math.maxInt(u32));
        var sum = [4]i64{ 0, 0, 0, 0 };
        var i: u32 = 1;
        while (i <= n) : (i += 1) {
            const col = try argColor(ctx, i);
            sum[0] += col.a;
            sum[1] += col.r;
            sum[2] += col.g;
            sum[3] += col.b;
        }
        const cnt: i64 = n;
        ret(ctx, Rgba.init(@divTrunc(sum[1], cnt), @divTrunc(sum[2], cnt), @divTrunc(sum[3], cnt), @divTrunc(sum[0], cnt)));
    }

    pub fn fromRGB(ctx: Ctx, code: i64) void {
        ret(ctx, Rgba.fromRGB(code));
    }

    pub fn fromARGB(ctx: Ctx, code: i64) void {
        ret(ctx, Rgba.fromARGB(code));
    }

    pub fn toARGB(ctx: Ctx) Error!i64 {
        return (try self(ctx)).toARGB();
    }

    pub fn fromRGBA(ctx: Ctx, code: i64) void {
        ret(ctx, Rgba.fromRGBA(code));
    }

    pub fn toRGBA(ctx: Ctx) Error!i64 {
        return (try self(ctx)).toRGBA();
    }

    pub fn equals(ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(1, 1);
        const a = try self(ctx);
        const b = try argColor(ctx, 1);
        return a.a == b.a and a.r == b.r and a.g == b.g and a.b == b.b;
    }

    pub fn toRGB(ctx: Ctx) Error!i64 {
        return (try self(ctx)).toRGB();
    }

    pub fn lerp(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        const a = try self(ctx);
        const b = try argColor(ctx, 1);
        const t = try ctx.call.expectArg(2, .{ .float = .{} }, {});
        ret(ctx, a.lerp(b, t));
    }

    pub fn blend(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        ret(ctx, (try self(ctx)).blend(try argColor(ctx, 1)));
    }

    pub fn toHSV(ctx: Ctx) Error!void {
        triple(ctx, (try self(ctx)).toHSV());
    }

    pub fn fromHSV(ctx: Ctx, h: f64, s: f64, v: f64, a: ?i64) void {
        ret(ctx, Rgba.fromHSV(h, s, v, Rgba.init(0, 0, 0, a orelse 0xff).a));
    }

    pub fn toHSL(ctx: Ctx) Error!void {
        triple(ctx, (try self(ctx)).toHSL());
    }

    pub fn fromHSL(ctx: Ctx, h: f64, s: f64, l: f64, a: ?i64) void {
        ret(ctx, Rgba.fromHSL(h, s, l, Rgba.init(0, 0, 0, a orelse 0xff).a));
    }
};

pub const ColorClass = phpz.Class("pocketmine\\color\\Color", Color, .{});
