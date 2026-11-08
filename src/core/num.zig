//! PHP number semantics for values typed `int|float`.
//! Integer arithmetic overflows to float exactly like the Zend VM so ported code keeps its types.

const std = @import("std");

pub const Num = union(enum) {
    int: i64,
    float: f64,

    pub fn f(v: f64) Num {
        return .{ .float = v };
    }

    pub fn i(v: i64) Num {
        return .{ .int = v };
    }

    pub fn toFloat(self: Num) f64 {
        return switch (self) {
            .int => |v| @floatFromInt(v),
            .float => |v| v,
        };
    }

    pub fn add(a: Num, b: Num) Num {
        if (a == .int and b == .int) {
            const r = @addWithOverflow(a.int, b.int);
            if (r[1] == 0) return .{ .int = r[0] };
            return .{ .float = @as(f64, @floatFromInt(a.int)) + @as(f64, @floatFromInt(b.int)) };
        }
        return .{ .float = a.toFloat() + b.toFloat() };
    }

    pub fn sub(a: Num, b: Num) Num {
        if (a == .int and b == .int) {
            const r = @subWithOverflow(a.int, b.int);
            if (r[1] == 0) return .{ .int = r[0] };
            return .{ .float = @as(f64, @floatFromInt(a.int)) - @as(f64, @floatFromInt(b.int)) };
        }
        return .{ .float = a.toFloat() - b.toFloat() };
    }

    pub fn mul(a: Num, b: Num) Num {
        if (a == .int and b == .int) {
            const r = @mulWithOverflow(a.int, b.int);
            if (r[1] == 0) return .{ .int = r[0] };
            return .{ .float = @as(f64, @floatFromInt(a.int)) * @as(f64, @floatFromInt(b.int)) };
        }
        return .{ .float = a.toFloat() * b.toFloat() };
    }

    /// Unary minus, which PHP compiles to a multiplication by -1.
    pub fn neg(a: Num) Num {
        return mul(a, .{ .int = -1 });
    }

    /// abs() for int|float.
    pub fn abs(a: Num) Num {
        return switch (a) {
            .int => |v| if (v == std.math.minInt(i64)) .{ .float = -@as(f64, @floatFromInt(v)) } else .{ .int = if (v < 0) -v else v },
            .float => |v| .{ .float = @abs(v) },
        };
    }

    pub fn eqlStrict(a: Num, b: Num) bool {
        return switch (a) {
            .int => |x| b == .int and b.int == x,
            .float => |x| b == .float and b.float == x,
        };
    }
};

/// zend_dval_to_lval(): the (int) cast of a float, modular for out of range values.
pub fn dvalToLval(d: f64) i64 {
    if (!std.math.isFinite(d)) return 0;
    if (!fitsLong(d)) {
        const two_pow_64: f64 = 18446744073709551616.0;
        var dmod = @rem(d, two_pow_64);
        if (dmod < 0) dmod += two_pow_64;
        const u: u64 = @intFromFloat(dmod);
        return @bitCast(u);
    }
    return @intFromFloat(d);
}

/// ZEND_DOUBLE_FITS_LONG()
pub fn fitsLong(d: f64) bool {
    return !(d >= 9223372036854775808.0 or d < -9223372036854775808.0);
}

/// (int) floor($v) as used by QuarkMath for int|float values.
pub fn floorInt(v: Num) i64 {
    return dvalToLval(@floor(v.toFloat()));
}

pub fn ceilInt(v: Num) i64 {
    return dvalToLval(@ceil(v.toFloat()));
}

/// The `<=>` result of a float against 0, NaN compares greater like ZEND_THREEWAY_COMPARE.
pub fn spaceshipZero(v: f64) i64 {
    if (v == 0) return 0;
    if (v < 0) return -1;
    return 1;
}

const testing = std.testing;

test "int arithmetic overflows to float" {
    const max = Num.i(std.math.maxInt(i64));
    try testing.expectEqual(Num.f(9223372036854775808.0), max.add(Num.i(1)));
    try testing.expectEqual(Num.i(3), Num.i(1).add(Num.i(2)));
    try testing.expectEqual(Num.f(2.5), Num.i(1).add(Num.f(1.5)));
    try testing.expectEqual(Num.f(-9223372036854775808.0 - 1.0), Num.i(std.math.minInt(i64)).sub(Num.i(1)));
    try testing.expectEqual(Num.f(9223372036854775808.0), Num.i(std.math.minInt(i64)).neg());
    try testing.expectEqual(Num.i(-5), Num.i(5).neg());
    try testing.expect(max.mul(Num.i(2)) == .float);
}

test "abs keeps ints except PHP_INT_MIN" {
    try testing.expectEqual(Num.i(4), Num.i(-4).abs());
    try testing.expectEqual(Num.f(9223372036854775808.0), Num.i(std.math.minInt(i64)).abs());
    try testing.expectEqual(Num.f(1.5), Num.f(-1.5).abs());
}

test "dvalToLval matches PHP casts" {
    try testing.expectEqual(@as(i64, 0), dvalToLval(std.math.nan(f64)));
    try testing.expectEqual(@as(i64, 0), dvalToLval(std.math.inf(f64)));
    try testing.expectEqual(@as(i64, -3), dvalToLval(-3.9));
    try testing.expectEqual(@as(i64, 3), dvalToLval(3.9));
    // (int) 1e19 in PHP 8.4 on 64-bit
    try testing.expectEqual(@as(i64, -8446744073709551616), dvalToLval(1e19));
    try testing.expectEqual(@as(i64, 8446744073709551616), dvalToLval(-1e19));
    try testing.expectEqual(@as(i64, std.math.minInt(i64)), dvalToLval(-9223372036854775808.0));
    try testing.expectEqual(@as(i64, std.math.minInt(i64)), dvalToLval(9223372036854775808.0));
}

test "floor and ceil to int" {
    try testing.expectEqual(@as(i64, -2), floorInt(Num.f(-1.5)));
    try testing.expectEqual(@as(i64, -1), ceilInt(Num.f(-1.5)));
    try testing.expectEqual(@as(i64, 7), floorInt(Num.i(7)));
}
