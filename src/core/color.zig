const std = @import("std");

pub const Rgba = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    /// Masks every channel with 0xff like the PHP constructor.
    pub fn init(r: i64, g: i64, b: i64, a: i64) Rgba {
        return .{ .r = mask(r), .g = mask(g), .b = mask(b), .a = mask(a) };
    }

    fn mask(v: i64) u8 {
        return @truncate(@as(u64, @bitCast(v)));
    }

    pub fn fromRGB(code: i64) Rgba {
        return init(code >> 16, code >> 8, code, 0xff);
    }

    pub fn fromARGB(code: i64) Rgba {
        return init(code >> 16, code >> 8, code, code >> 24);
    }

    pub fn fromRGBA(code: i64) Rgba {
        return init(code >> 24, code >> 16, code >> 8, code);
    }

    pub fn toARGB(self: Rgba) i64 {
        return (@as(i64, self.a) << 24) | (@as(i64, self.r) << 16) | (@as(i64, self.g) << 8) | self.b;
    }

    pub fn toRGBA(self: Rgba) i64 {
        return (@as(i64, self.r) << 24) | (@as(i64, self.g) << 16) | (@as(i64, self.b) << 8) | self.a;
    }

    pub fn toRGB(self: Rgba) i64 {
        return (@as(i64, self.r) << 16) | (@as(i64, self.g) << 8) | self.b;
    }

    pub fn lerp(self: Rgba, to: Rgba, t_in: f64) Rgba {
        const t = if (std.math.isNan(t_in)) 0 else std.math.clamp(t_in, 0.0, 1.0);
        return .{ .r = lerpChannel(self.r, to.r, t), .g = lerpChannel(self.g, to.g, t), .b = lerpChannel(self.b, to.b, t), .a = lerpChannel(self.a, to.a, t) };
    }

    fn lerpChannel(a: u8, b: u8, t: f64) u8 {
        const fa: f64 = @floatFromInt(a);
        const fb: f64 = @floatFromInt(b);
        return @intFromFloat(@round(fa + (fb - fa) * t));
    }

    /// Straight (non-premultiplied) alpha.
    pub fn blend(self: Rgba, over: Rgba) Rgba {
        const sa = @as(f64, @floatFromInt(over.a)) / 255.0;
        const da = @as(f64, @floatFromInt(self.a)) / 255.0;
        const oa = sa + da * (1 - sa);
        if (oa <= 0) return .{ .r = 0, .g = 0, .b = 0, .a = 0 };
        const ch = struct {
            fn f(s: u8, d: u8, sa_: f64, da_: f64, oa_: f64) u8 {
                const v = (@as(f64, @floatFromInt(s)) * sa_ + @as(f64, @floatFromInt(d)) * da_ * (1 - sa_)) / oa_;
                return @intFromFloat(@round(std.math.clamp(v, 0, 255)));
            }
        }.f;
        return .{
            .r = ch(over.r, self.r, sa, da, oa),
            .g = ch(over.g, self.g, sa, da, oa),
            .b = ch(over.b, self.b, sa, da, oa),
            .a = @intFromFloat(@round(oa * 255)),
        };
    }

    /// Hue in degrees [0, 360), saturation and value in [0, 1].
    pub fn toHSV(self: Rgba) [3]f64 {
        const r = @as(f64, @floatFromInt(self.r)) / 255.0;
        const g = @as(f64, @floatFromInt(self.g)) / 255.0;
        const b = @as(f64, @floatFromInt(self.b)) / 255.0;
        const max = @max(r, g, b);
        const min = @min(r, g, b);
        const d = max - min;
        return .{ hue(r, g, b, max, d), if (max == 0) 0 else d / max, max };
    }

    pub fn toHSL(self: Rgba) [3]f64 {
        const r = @as(f64, @floatFromInt(self.r)) / 255.0;
        const g = @as(f64, @floatFromInt(self.g)) / 255.0;
        const b = @as(f64, @floatFromInt(self.b)) / 255.0;
        const max = @max(r, g, b);
        const min = @min(r, g, b);
        const d = max - min;
        const l = (max + min) / 2;
        const s = if (d == 0) 0 else d / (1 - @abs(2 * l - 1));
        return .{ hue(r, g, b, max, d), s, l };
    }

    pub fn fromHSV(h: f64, s: f64, v: f64, a: u8) Rgba {
        const sv = clamp01(s);
        const vv = clamp01(v);
        const c = vv * sv;
        return fromChroma(h, c, vv - c, a);
    }

    pub fn fromHSL(h: f64, s: f64, l: f64, a: u8) Rgba {
        const sl = clamp01(s);
        const ll = clamp01(l);
        const c = (1 - @abs(2 * ll - 1)) * sl;
        return fromChroma(h, c, ll - c / 2, a);
    }

    fn fromChroma(h_in: f64, c: f64, m: f64, a: u8) Rgba {
        const h = if (std.math.isFinite(h_in)) @mod(h_in, 360.0) else 0;
        const hp = h / 60.0;
        const x = c * (1 - @abs(@mod(hp, 2.0) - 1));
        const rgb: [3]f64 = switch (@as(u3, @intFromFloat(@min(@floor(hp), 5)))) {
            0 => .{ c, x, 0 },
            1 => .{ x, c, 0 },
            2 => .{ 0, c, x },
            3 => .{ 0, x, c },
            4 => .{ x, 0, c },
            else => .{ c, 0, x },
        };
        return .{ .r = to8(rgb[0] + m), .g = to8(rgb[1] + m), .b = to8(rgb[2] + m), .a = a };
    }

    fn to8(v: f64) u8 {
        return @intFromFloat(@round(std.math.clamp(v, 0, 1) * 255));
    }

    fn clamp01(v: f64) f64 {
        return if (std.math.isNan(v)) 0 else std.math.clamp(v, 0, 1);
    }

    fn hue(r: f64, g: f64, b: f64, max: f64, d: f64) f64 {
        if (d == 0) return 0;
        var h: f64 = if (max == r)
            @mod((g - b) / d, 6.0)
        else if (max == g)
            (b - r) / d + 2
        else
            (r - g) / d + 4;
        h *= 60;
        if (h < 0) h += 360;
        return h;
    }
};

const testing = std.testing;

test "packing round trips and masks like pocketmine/color" {
    const c = Rgba.fromARGB(0x80112233);
    try testing.expectEqual(Rgba{ .r = 0x11, .g = 0x22, .b = 0x33, .a = 0x80 }, c);
    try testing.expectEqual(@as(i64, 0x80112233), c.toARGB());
    try testing.expectEqual(@as(i64, 0x11223380), c.toRGBA());
    try testing.expectEqual(Rgba.init(0x11, 0x22, 0x33, 0x80), Rgba.fromRGBA(0x11223380));
    try testing.expectEqual(@as(u8, 0xff), Rgba.init(-1, 0, 0, 0).r);
    try testing.expectEqual(@as(u8, 0x34), Rgba.init(0x1234, 0, 0, 0).r);
}

test "hsv and hsl round trip primary colours" {
    const red = Rgba.init(255, 0, 0, 255);
    try testing.expectEqual([3]f64{ 0, 1, 1 }, red.toHSV());
    try testing.expectEqual(red, Rgba.fromHSV(0, 1, 1, 255));
    const teal = Rgba.init(0, 128, 128, 255);
    const hsl = teal.toHSL();
    try testing.expectEqual(teal, Rgba.fromHSL(hsl[0], hsl[1], hsl[2], 255));
    try testing.expectEqual(Rgba.init(0, 0, 255, 255), Rgba.fromHSV(-120, 1, 1, 255));
}

test "blend and lerp" {
    const white = Rgba.init(255, 255, 255, 255);
    const half_black = Rgba.init(0, 0, 0, 128);
    const b = white.blend(half_black);
    try testing.expectEqual(@as(u8, 255), b.a);
    try testing.expectEqual(@as(u8, 127), b.r);
    try testing.expectEqual(Rgba.init(128, 128, 128, 255), Rgba.init(0, 0, 0, 255).lerp(white, 0.5));
    try testing.expectEqual(white, Rgba.init(0, 0, 0, 255).lerp(white, 7));
}
