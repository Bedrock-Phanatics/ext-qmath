//! PHP calls the C runtime's math, which is looked up in the process at startup because
//! compiler-rt copies can differ in the last bit. Zig's versions stand in until init().

const std = @import("std");
const builtin = @import("builtin");

const Unary = *const fn (f64) callconv(.c) f64;
const Binary = *const fn (f64, f64) callconv(.c) f64;

pub var sin: Unary = &zigSin;
pub var cos: Unary = &zigCos;
pub var atan2: Binary = &zigAtan2;
pub var fmod: Binary = &zigFmod;
pub var pow: Binary = &zigPow;
pub var native: bool = false;

fn zigSin(x: f64) callconv(.c) f64 {
    return @sin(x);
}

fn zigCos(x: f64) callconv(.c) f64 {
    return @cos(x);
}

fn zigAtan2(y: f64, x: f64) callconv(.c) f64 {
    return std.math.atan2(y, x);
}

fn zigFmod(x: f64, y: f64) callconv(.c) f64 {
    return @rem(x, y);
}

fn zigPow(x: f64, y: f64) callconv(.c) f64 {
    return std.math.pow(f64, x, y);
}

extern "kernel32" fn GetModuleHandleA(name: ?[*:0]const u8) callconv(.winapi) ?*anyopaque;
extern "kernel32" fn GetProcAddress(module: *anyopaque, name: [*:0]const u8) callconv(.winapi) ?*anyopaque;

const Resolver = struct {
    handle: *anyopaque,

    fn find(self: Resolver, comptime T: type, name: [*:0]const u8) ?T {
        const p = if (builtin.os.tag == .windows) GetProcAddress(self.handle, name) else std.c.dlsym(self.handle, name);
        return @ptrCast(@alignCast(p orelse return null));
    }
};

fn resolver() ?Resolver {
    if (builtin.os.tag == .windows) {
        // PHP's Windows builds link the Universal CRT dynamically, debug builds its debug variant.
        for ([_][*:0]const u8{ "ucrtbase.dll", "ucrtbased.dll" }) |dll| {
            if (GetModuleHandleA(dll)) |h| return .{ .handle = h };
        }
        return null;
    }
    // The main program's handle searches the global scope, where PHP's libm lives.
    return .{ .handle = std.c.dlopen(null, .{ .LAZY = true }) orelse return null };
}

pub inline fn sinFn(x: f64) f64 {
    return sin(x);
}

pub inline fn cosFn(x: f64) f64 {
    return cos(x);
}

pub inline fn atan2Fn(y: f64, x: f64) f64 {
    return atan2(y, x);
}

pub inline fn fmodFn(x: f64, y: f64) f64 {
    return fmod(x, y);
}

pub inline fn powFn(x: f64, y: f64) f64 {
    return pow(x, y);
}

/// Called once during module startup, before any other thread runs.
pub fn init() void {
    const r = resolver() orelse return;
    const s = r.find(Unary, "sin") orelse return;
    const c = r.find(Unary, "cos") orelse return;
    const a = r.find(Binary, "atan2") orelse return;
    const f = r.find(Binary, "fmod") orelse return;
    const p = r.find(Binary, "pow") orelse return;
    sin = s;
    cos = c;
    atan2 = a;
    fmod = f;
    pow = p;
    native = true;
}

test "resolves the C runtime" {
    init();
    // A standalone test binary may not load libm at all, PHP always does.
    if (!native) return error.SkipZigTest;
    try std.testing.expectEqual(@as(f64, 9), pow(3, 2));
    try std.testing.expectEqual(@as(f64, 0), sin(0));
}
