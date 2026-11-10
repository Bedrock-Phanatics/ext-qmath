//! Operation for operation like Quark so generated terrain is unchanged.

const std = @import("std");
const Allocator = std.mem.Allocator;
const num = @import("num.zig");

const grad3 = [12][3]f64{
    .{ 1, 1, 0 }, .{ -1, 1, 0 }, .{ 1, -1, 0 }, .{ -1, -1, 0 },
    .{ 1, 0, 1 }, .{ -1, 0, 1 }, .{ 1, 0, -1 }, .{ -1, 0, -1 },
    .{ 0, 1, 1 }, .{ 0, -1, 1 }, .{ 0, 1, -1 }, .{ 0, -1, -1 },
};

// Typed f64 so the constants are rounded exactly like PHP's double arithmetic.
const sqrt3: f64 = 1.73205080756887729352744634151;
const F2: f64 = 0.5 * (sqrt3 - 1.0);
const G2: f64 = (3.0 - sqrt3) / 6.0;
const G22: f64 = G2 * 2.0 - 1.0;
const F3: f64 = 1.0 / 3.0;
const G3: f64 = 1.0 / 6.0;

/// Quark samples 16x128x16 per chunk, this bounds one native call.
pub const max_samples: usize = 1 << 20;

pub const Error = error{ OutOfMemory, InvalidArgument };

pub const Simplex = struct {
    perm: [512]u8,
    offset: [3]f64,
    octaves: i64,
    persistence: f64,
    expansion: f64,

    fn hashIndex(v: f64) struct { i: i64, h: usize } {
        const i = num.dvalToLval(v);
        return .{ .i = i, .h = @intCast(@as(u64, @bitCast(i)) & 255) };
    }

    pub fn getNoise3D(self: *const Simplex, x_in: f64, y_in: f64, z_in: f64) f64 {
        const x = x_in + self.offset[0];
        const y = y_in + self.offset[1];
        const z = z_in + self.offset[2];

        const s = (x + y + z) * F3;
        const ci = hashIndex(x + s);
        const cj = hashIndex(y + s);
        const ck = hashIndex(z + s);
        const t = num.Num.i(ci.i).add(num.Num.i(cj.i)).add(num.Num.i(ck.i)).toFloat() * G3;
        const x0 = x - (@as(f64, @floatFromInt(ci.i)) - t);
        const y0 = y - (@as(f64, @floatFromInt(cj.i)) - t);
        const z0 = z - (@as(f64, @floatFromInt(ck.i)) - t);

        var o1: [3]u1 = undefined;
        var o2: [3]u1 = undefined;
        if (x0 >= y0) {
            if (y0 >= z0) {
                o1 = .{ 1, 0, 0 };
                o2 = .{ 1, 1, 0 };
            } else if (x0 >= z0) {
                o1 = .{ 1, 0, 0 };
                o2 = .{ 1, 0, 1 };
            } else {
                o1 = .{ 0, 0, 1 };
                o2 = .{ 1, 0, 1 };
            }
        } else {
            if (y0 < z0) {
                o1 = .{ 0, 0, 1 };
                o2 = .{ 0, 1, 1 };
            } else if (x0 < z0) {
                o1 = .{ 0, 1, 0 };
                o2 = .{ 0, 1, 1 };
            } else {
                o1 = .{ 0, 1, 0 };
                o2 = .{ 1, 1, 0 };
            }
        }

        const x1 = x0 - @as(f64, @floatFromInt(o1[0])) + G3;
        const y1 = y0 - @as(f64, @floatFromInt(o1[1])) + G3;
        const z1 = z0 - @as(f64, @floatFromInt(o1[2])) + G3;
        const x2 = x0 - @as(f64, @floatFromInt(o2[0])) + 2.0 * G3;
        const y2 = y0 - @as(f64, @floatFromInt(o2[1])) + 2.0 * G3;
        const z2 = z0 - @as(f64, @floatFromInt(o2[2])) + 2.0 * G3;
        const x3 = x0 - 1.0 + 3.0 * G3;
        const y3 = y0 - 1.0 + 3.0 * G3;
        const z3 = z0 - 1.0 + 3.0 * G3;

        const ii = ci.h;
        const jj = cj.h;
        const kk = ck.h;
        const p = &self.perm;
        var n: f64 = 0;

        const t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0;
        if (t0 > 0) {
            const g = grad3[p[ii + p[jj + p[kk]]] % 12];
            n += t0 * t0 * t0 * t0 * (g[0] * x0 + g[1] * y0 + g[2] * z0);
        }
        const t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1;
        if (t1 > 0) {
            const g = grad3[p[ii + o1[0] + p[jj + o1[1] + p[kk + o1[2]]]] % 12];
            n += t1 * t1 * t1 * t1 * (g[0] * x1 + g[1] * y1 + g[2] * z1);
        }
        const t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2;
        if (t2 > 0) {
            const g = grad3[p[ii + o2[0] + p[jj + o2[1] + p[kk + o2[2]]]] % 12];
            n += t2 * t2 * t2 * t2 * (g[0] * x2 + g[1] * y2 + g[2] * z2);
        }
        const t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3;
        if (t3 > 0) {
            const g = grad3[p[ii + 1 + p[jj + 1 + p[kk + 1]]] % 12];
            n += t3 * t3 * t3 * t3 * (g[0] * x3 + g[1] * y3 + g[2] * z3);
        }
        return 32.0 * n;
    }

    pub fn getNoise2D(self: *const Simplex, x_in: f64, y_in: f64) f64 {
        const x = x_in + self.offset[0];
        const y = y_in + self.offset[1];

        const s = (x + y) * F2;
        const ci = hashIndex(x + s);
        const cj = hashIndex(y + s);
        const t = num.Num.i(ci.i).add(num.Num.i(cj.i)).toFloat() * G2;
        const x0 = x - (@as(f64, @floatFromInt(ci.i)) - t);
        const y0 = y - (@as(f64, @floatFromInt(cj.i)) - t);

        const o: [2]u1 = if (x0 > y0) .{ 1, 0 } else .{ 0, 1 };
        const x1 = x0 - @as(f64, @floatFromInt(o[0])) + G2;
        const y1 = y0 - @as(f64, @floatFromInt(o[1])) + G2;
        const x2 = x0 + G22;
        const y2 = y0 + G22;

        const ii = ci.h;
        const jj = cj.h;
        const p = &self.perm;
        var n: f64 = 0;

        const t0 = 0.5 - x0 * x0 - y0 * y0;
        if (t0 > 0) {
            const g = grad3[p[ii + p[jj]] % 12];
            n += t0 * t0 * t0 * t0 * (g[0] * x0 + g[1] * y0);
        }
        const t1 = 0.5 - x1 * x1 - y1 * y1;
        if (t1 > 0) {
            const g = grad3[p[ii + o[0] + p[jj + o[1]]] % 12];
            n += t1 * t1 * t1 * t1 * (g[0] * x1 + g[1] * y1);
        }
        const t2 = 0.5 - x2 * x2 - y2 * y2;
        if (t2 > 0) {
            const g = grad3[p[ii + 1 + p[jj + 1]] % 12];
            n += t2 * t2 * t2 * t2 * (g[0] * x2 + g[1] * y2);
        }
        return 70.0 * n;
    }

    /// What normalized noise is divided by, zero for some negative persistences.
    pub fn amplitude(self: *const Simplex) f64 {
        var amp: f64 = 1;
        var max: f64 = 0;
        var i: i64 = 0;
        while (i < self.octaves) : (i += 1) {
            max += amp;
            amp *= self.persistence;
        }
        return max;
    }

    pub fn noise2D(self: *const Simplex, x_in: f64, z_in: f64, normalized: bool) f64 {
        var result: f64 = 0;
        var amp: f64 = 1;
        var freq: f64 = 1;
        var max: f64 = 0;
        const x = x_in * self.expansion;
        const z = z_in * self.expansion;
        var i: i64 = 0;
        while (i < self.octaves) : (i += 1) {
            result += self.getNoise2D(x * freq, z * freq) * amp;
            max += amp;
            freq *= 2;
            amp *= self.persistence;
        }
        if (normalized) result /= max;
        return result;
    }

    pub fn noise3D(self: *const Simplex, x_in: f64, y_in: f64, z_in: f64, normalized: bool) f64 {
        var result: f64 = 0;
        var amp: f64 = 1;
        var freq: f64 = 1;
        var max: f64 = 0;
        const x = x_in * self.expansion;
        const y = y_in * self.expansion;
        const z = z_in * self.expansion;
        var i: i64 = 0;
        while (i < self.octaves) : (i += 1) {
            result += self.getNoise3D(x * freq, y * freq, z * freq) * amp;
            max += amp;
            freq *= 2;
            amp *= self.persistence;
        }
        if (normalized) result /= max;
        return result;
    }
};

/// Int addition first, then to float, like PHP.
fn coord(base: i64, off: i64) f64 {
    return num.Num.i(base).add(num.Num.i(off)).toFloat();
}

fn ratio(a: i64, b: i64) f64 {
    return @as(f64, @floatFromInt(a)) / @as(f64, @floatFromInt(b));
}

pub fn validateSampling(size: i64, rate: i64) Error!void {
    if (size < 0 or size >= max_samples or rate <= 0 or @rem(size, rate) != 0) return error.InvalidArgument;
}

/// `out` has xSize + 1 entries.
pub fn fastNoise1D(s: *const Simplex, out: []f64, x_size: i64, rate: i64, x: i64, y: i64, z: i64) void {
    var xx: i64 = 0;
    while (xx <= x_size) : (xx += rate) out[@intCast(xx)] = s.noise3D(coord(xx, x), @floatFromInt(y), @floatFromInt(z), false);
    xx = 0;
    while (xx < x_size) : (xx += 1) {
        if (@rem(xx, rate) == 0) continue;
        const nx = @divTrunc(xx, rate) * rate;
        const q0 = out[@intCast(nx)];
        const q1 = out[@intCast(nx + rate)];
        out[@intCast(xx)] = ratio(nx + rate - xx, rate) * q0 + ratio(xx - nx, rate) * q1;
    }
}

/// `out` is [x][z] with (xSize + 1) * (zSize + 1) entries, `set` marks filled ones.
pub fn fastNoise2D(s: *const Simplex, out: []f64, set: []bool, x_size: i64, z_size: i64, rate: i64, x: i64, y: i64, z: i64) void {
    const zs: usize = @intCast(z_size + 1);
    @memset(set, false);
    var xx: i64 = 0;
    while (xx <= x_size) : (xx += rate) {
        var zz: i64 = 0;
        while (zz <= z_size) : (zz += rate) {
            const i = @as(usize, @intCast(xx)) * zs + @as(usize, @intCast(zz));
            out[i] = s.noise3D(coord(x, xx), @floatFromInt(y), coord(z, zz), false);
            set[i] = true;
        }
    }
    xx = 0;
    while (xx < x_size) : (xx += 1) {
        var zz: i64 = 0;
        while (zz < z_size) : (zz += 1) {
            if (@rem(xx, rate) == 0 and @rem(zz, rate) == 0) continue;
            const nx = @divTrunc(xx, rate) * rate;
            const nz = @divTrunc(zz, rate) * rate;
            const at = struct {
                fn f(o: []const f64, w: usize, a: i64, b: i64) f64 {
                    return o[@as(usize, @intCast(a)) * w + @as(usize, @intCast(b))];
                }
            }.f;
            const dx1 = ratio(nx + rate - xx, rate);
            const dx2 = ratio(xx - nx, rate);
            const v = ratio(nz + rate - zz, rate) * (dx1 * at(out, zs, nx, nz) + dx2 * at(out, zs, nx + rate, nz)) +
                ratio(zz - nz, rate) * (dx1 * at(out, zs, nx, nz + rate) + dx2 * at(out, zs, nx + rate, nz + rate));
            const i = @as(usize, @intCast(xx)) * zs + @as(usize, @intCast(zz));
            out[i] = v;
            set[i] = true;
        }
    }
}

pub const Sampling3D = struct {
    size: [3]i64,
    rate: [3]i64,
    origin: [3]i64,

    pub fn validate(self: Sampling3D) Error!void {
        var total: u64 = 1;
        for (0..3) |a| {
            try validateSampling(self.size[a], self.rate[a]);
            total = std.math.mul(u64, total, @intCast(self.size[a] + 1)) catch return error.InvalidArgument;
        }
        if (total > max_samples) return error.InvalidArgument;
    }

    pub fn len(self: Sampling3D) usize {
        return @intCast((self.size[0] + 1) * (self.size[1] + 1) * (self.size[2] + 1));
    }

    pub fn index(self: Sampling3D, x: i64, y: i64, z: i64) usize {
        return @intCast((x * (self.size[2] + 1) + z) * (self.size[1] + 1) + y);
    }
};

/// Entries PHP never writes stay int 0 there, `set` reports them.
pub fn fastNoise3D(s: *const Simplex, out: []f64, set: []bool, g: Sampling3D) void {
    @memset(out, 0);
    @memset(set, false);
    const xs = g.size[0];
    const ys = g.size[1];
    const zs = g.size[2];
    const xr = g.rate[0];
    const yr = g.rate[1];
    const zr = g.rate[2];

    var xx: i64 = 0;
    while (xx <= xs) : (xx += xr) {
        var zz: i64 = 0;
        while (zz <= zs) : (zz += zr) {
            var yy: i64 = 0;
            while (yy <= ys) : (yy += yr) {
                const i = g.index(xx, yy, zz);
                out[i] = s.noise3D(coord(g.origin[0], xx), coord(g.origin[1], yy), coord(g.origin[2], zz), true);
                set[i] = true;
            }
        }
    }

    const x_step = 1.0 / @as(f64, @floatFromInt(xr));
    const y_step = 1.0 / @as(f64, @floatFromInt(yr));
    const z_step = 1.0 / @as(f64, @floatFromInt(zr));

    var lx: i64 = 0;
    while (lx < xs) : (lx += xr) {
        const rx = lx + xr;
        var lz: i64 = 0;
        while (lz < zs) : (lz += zr) {
            const rz = lz + zr;
            var ly: i64 = 0;
            while (ly < ys) : (ly += yr) {
                const ry = ly + yr;
                const c000 = out[g.index(lx, ly, lz)];
                const c100 = out[g.index(rx, ly, lz)];
                const c001 = out[g.index(lx, ry, lz)];
                const c101 = out[g.index(rx, ry, lz)];
                const c010 = out[g.index(lx, ly, rz)];
                const c110 = out[g.index(rx, ly, rz)];
                const c011 = out[g.index(lx, ry, rz)];
                const c111 = out[g.index(rx, ry, rz)];

                var x_step_i: i64 = 0;
                while (x_step_i < xr) : (x_step_i += 1) {
                    const dx2 = @as(f64, @floatFromInt(x_step_i)) * x_step;
                    const dx1 = 1 - dx2;
                    const x00 = (c000 * dx1) + (c100 * dx2);
                    const x01 = (c001 * dx1) + (c101 * dx2);
                    const x10 = (c010 * dx1) + (c110 * dx2);
                    const x11 = (c011 * dx1) + (c111 * dx2);

                    var z_step_i: i64 = 0;
                    while (z_step_i < zr) : (z_step_i += 1) {
                        const dz2 = @as(f64, @floatFromInt(z_step_i)) * z_step;
                        const dz1 = 1 - dz2;
                        const z0 = x00 * dz1 + x10 * dz2;
                        const z1 = x01 * dz1 + x11 * dz2;

                        var y_step_i: i64 = if (x_step_i == 0 and z_step_i == 0) 1 else 0;
                        while (y_step_i < yr) : (y_step_i += 1) {
                            const dy2 = @as(f64, @floatFromInt(y_step_i)) * y_step;
                            const dy1 = 1 - dy2;
                            const i = g.index(lx + x_step_i, ly + y_step_i, lz + z_step_i);
                            out[i] = dy1 * z0 + dy2 * z1;
                            set[i] = true;
                        }
                    }
                }
            }
        }
    }
}

const testing = std.testing;

fn testSimplex() Simplex {
    var s = Simplex{ .perm = undefined, .offset = .{ 12.25, 40.5, 99.75 }, .octaves = 4, .persistence = 0.25, .expansion = 1.0 / 32.0 };
    for (0..256) |i| s.perm[i] = @intCast((i * 151 + 7) % 256);
    for (0..256) |i| s.perm[i + 256] = s.perm[i];
    return s;
}

test "noise is bounded and deterministic" {
    const s = testSimplex();
    var x: f64 = -300;
    while (x < 300) : (x += 7.3) {
        const v = s.noise3D(x, x * 0.5, -x, true);
        try testing.expect(v >= -1.0 and v <= 1.0);
        try testing.expectEqual(v, s.noise3D(x, x * 0.5, -x, true));
        const w = s.noise2D(x, -x, true);
        try testing.expect(w >= -1.0 and w <= 1.0);
    }
}

test "sampled grid matches samples at sample points" {
    const s = testSimplex();
    const g = Sampling3D{ .size = .{ 16, 32, 16 }, .rate = .{ 4, 8, 4 }, .origin = .{ -32, 0, 48 } };
    try g.validate();
    const out = try testing.allocator.alloc(f64, g.len());
    defer testing.allocator.free(out);
    const set = try testing.allocator.alloc(bool, g.len());
    defer testing.allocator.free(set);
    fastNoise3D(&s, out, set, g);
    try testing.expectEqual(s.noise3D(-32 + 4, 8, 48 + 12, true), out[g.index(4, 8, 12)]);
    // never written by the PHP implementation
    try testing.expect(!set[g.index(16, 1, 0)]);
    try testing.expect(set[g.index(3, 5, 7)]);
}

test "invalid sampling is rejected" {
    try testing.expectError(error.InvalidArgument, validateSampling(16, 0));
    try testing.expectError(error.InvalidArgument, validateSampling(15, 4));
    const g = Sampling3D{ .size = .{ 4096, 4096, 4096 }, .rate = .{ 1, 1, 1 }, .origin = .{ 0, 0, 0 } };
    try testing.expectError(error.InvalidArgument, g.validate());
}
