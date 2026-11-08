//! Property slots are read and written directly when that matches normal access.
//! Unset, lazy or hooked properties go through the object handlers instead.

const std = @import("std");
pub const phpz = @import("phpz");
pub const c = phpz.c;
pub const core = @import("core/root.zig");
pub const Num = core.num.Num;
pub const NumVec = core.geom.NumVec;
pub const Vec = core.geom.Vec;
pub const Box = core.geom.Box;
pub const Ctx = phpz.Ctx;
pub const Error = phpz.exception.Error;
pub const ZObj = *c.zend_object;
pub const Ce = *c.zend_class_entry;

pub const IS_UNDEF: u8 = 0;
pub const IS_NULL: u8 = 1;
pub const IS_FALSE: u8 = 2;
pub const IS_TRUE: u8 = 3;
pub const IS_LONG: u8 = 4;
pub const IS_DOUBLE: u8 = 5;
pub const IS_STRING: u8 = 6;
pub const IS_ARRAY: u8 = 7;
pub const IS_OBJECT: u8 = 8;
pub const IS_REFERENCE: u8 = 10;

pub inline fn ztype(zv: *const c.zval) u8 {
    return zv.u1.v.type;
}

pub inline fn deref(zv: *c.zval) *c.zval {
    return if (ztype(zv) == IS_REFERENCE) &zv.value.ref.*.val else zv;
}

pub inline fn setLong(zv: *c.zval, v: i64) void {
    zv.value.lval = v;
    zv.u1.type_info = IS_LONG;
}

pub inline fn setDouble(zv: *c.zval, v: f64) void {
    zv.value.dval = v;
    zv.u1.type_info = IS_DOUBLE;
}

pub inline fn setBool(zv: *c.zval, v: bool) void {
    zv.u1.type_info = if (v) IS_TRUE else IS_FALSE;
}

pub inline fn setNull(zv: *c.zval) void {
    zv.u1.type_info = IS_NULL;
}

pub inline fn setNum(zv: *c.zval, n: Num) void {
    switch (n) {
        .int => |v| setLong(zv, v),
        .float => |v| setDouble(zv, v),
    }
}

pub inline fn props(o: ZObj) [*]c.zval {
    return @ptrCast(&o._properties_table);
}

/// Data symbols need DLL import handling on Windows.
pub inline fn phpCe(comptime symbol: []const u8) Ce {
    return phpz.ClassEntry.builtin(symbol).ptr();
}

pub inline fn cePtr(entry: *phpz.ClassEntry) Ce {
    return entry.ptr();
}

pub inline fn objOf(zv: *c.zval) ZObj {
    return zv.value.obj;
}

pub inline fn ret(ctx: Ctx) *c.zval {
    return ctx.retval.ptr();
}

pub inline fn this(ctx: Ctx) ZObj {
    return ctx.call.this().?.ptr();
}

pub inline fn arg(ctx: Ctx, n: u32) *c.zval {
    return ctx.call.arg(n);
}

pub fn instanceOf(o: ZObj, ce: Ce) bool {
    return o.ce == ce or c.instanceof_function_slow(o.ce, ce);
}

pub const Prop = struct {
    slot: u32 = 0,
    name: *c.zend_string = undefined,
    /// Declaring class, so private properties stay reachable.
    scope: Ce = undefined,

    pub fn resolve(ce: Ce, comptime name: []const u8) Prop {
        const zname = c.zend_string_init_interned.?(name.ptr, name.len, true);
        const found = c.zend_hash_find(&ce.properties_info, zname) orelse @panic("qmath: missing property " ++ name);
        const info: *c.zend_property_info = @ptrCast(@alignCast(found.*.value.ptr));
        const base = @offsetOf(c.zend_object, "_properties_table");
        return .{ .slot = @intCast((@as(usize, info.offset) - base) / @sizeOf(c.zval)), .name = zname, .scope = info.ce };
    }
};

/// Subclasses may redeclare inherited properties with hooks, which breaks direct slot access.
pub fn plainSlots(ce: Ce, base: Ce, list: []const Prop) bool {
    if (ce == base) return true;
    const table = ce.properties_info_table orelse return false;
    for (list) |p| {
        const info = table[p.slot] orelse return false;
        if (info.*.hooks != null) return false;
    }
    return true;
}

fn readSlow(o: ZObj, name: *c.zend_string, rv: *c.zval) Error!*c.zval {
    rv.u1.type_info = IS_UNDEF;
    const res = o.handlers.*.read_property.?(o, name, c.BP_VAR_R, null, rv);
    if (phpz.exception.hasPending()) {
        if (res == rv) c.zval_ptr_dtor(rv);
        return error.PhpException;
    }
    return deref(res);
}

fn readNumSlow(o: ZObj, p: Prop) Error!Num {
    var rv: c.zval = undefined;
    const zv = try readSlow(o, p.name, &rv);
    defer c.zval_ptr_dtor(&rv);
    return switch (ztype(zv)) {
        IS_LONG => Num.i(zv.value.lval),
        IS_DOUBLE => Num.f(zv.value.dval),
        else => typeError("Typed property %s::$%s must be of type int|float, %s read", .{ zstrC(o.ce.*.name), zstrC(p.name), c.zend_zval_type_name(zv) }),
    };
}

pub inline fn readNum(o: ZObj, p: Prop, plain: bool) Error!Num {
    if (plain) {
        const zv = deref(&props(o)[p.slot]);
        switch (ztype(zv)) {
            IS_LONG => return Num.i(zv.value.lval),
            IS_DOUBLE => return Num.f(zv.value.dval),
            else => {},
        }
    }
    return readNumSlow(o, p);
}

/// Typed float properties always hold a double once initialized.
pub inline fn readFloat(o: ZObj, p: Prop) Error!f64 {
    const zv = deref(&props(o)[p.slot]);
    if (ztype(zv) == IS_DOUBLE) return zv.value.dval;
    return (try readNumSlow(o, p)).toFloat();
}

pub inline fn readFloatOf(o: ZObj, p: Prop, plain: bool) Error!f64 {
    if (plain) return readFloat(o, p);
    return (try readNumSlow(o, p)).toFloat();
}

pub fn writeNum(o: ZObj, p: Prop, plain: bool, n: Num) Error!void {
    if (plain) {
        const zv = &props(o)[p.slot];
        switch (ztype(zv)) {
            IS_UNDEF, IS_LONG, IS_DOUBLE => {
                // Unset slots are only written directly while constructing without magic.
                if (ztype(zv) != IS_UNDEF or (o.ce.*.__set == null and !lazy(o))) {
                    setNum(zv, n);
                    zv.u2.extra = 0;
                    return;
                }
            },
            IS_REFERENCE => {
                const ref = zv.value.ref;
                const r = switch (n) {
                    .int => |v| c.zend_try_assign_typed_ref_long(ref, v),
                    .float => |v| c.zend_try_assign_typed_ref_double(ref, v),
                };
                if (r != c.SUCCESS) return error.PhpException;
                return;
            },
            else => {},
        }
    }
    var tmp: c.zval = undefined;
    setNum(&tmp, n);
    c.zend_update_property_ex(p.scope, o, p.name, &tmp);
    if (phpz.exception.hasPending()) return error.PhpException;
}

fn lazy(o: ZObj) bool {
    return c.zend_object_is_lazy(o);
}

pub fn writeZval(o: ZObj, p: Prop, value: *c.zval) Error!void {
    c.zend_update_property_ex(p.scope, o, p.name, value);
    if (phpz.exception.hasPending()) return error.PhpException;
}

pub inline fn retObjectCopy(out: *c.zval, o: ZObj) void {
    o.gc.refcount += 1;
    out.value.obj = o;
    out.u1.type_info = c.IS_OBJECT_EX;
}

/// Keeps the object alive while PHP code, like a property hook, may drop other references.
pub inline fn hold(o: ZObj) void {
    o.gc.refcount += 1;
}

pub inline fn release(o: ZObj) void {
    c.zend_object_release(o);
}

/// A pinned array stays unmodified, user writes separate a copy.
pub inline fn pinArray(arr: *c.zend_array) void {
    if ((arr.gc.u.type_info & (c.GC_IMMUTABLE << c.GC_FLAGS_SHIFT)) == 0) arr.gc.refcount += 1;
}

pub inline fn unpinArray(arr: *c.zend_array) void {
    c.zend_array_release(arr);
}

pub inline fn newArray(out: *c.zval, size: u32) void {
    out.value.arr = c._zend_new_array(size);
    out.u1.type_info = c.IS_ARRAY_EX;
}

pub inline fn newObject(out: *c.zval, ce: Ce) ZObj {
    _ = c.object_init_ex(out, ce);
    return out.value.obj;
}

/// Clears the uninitialized flag like a first assignment.
pub inline fn initSlot(o: ZObj, p: Prop) *c.zval {
    const zv = &props(o)[p.slot];
    zv.u2.extra = 0;
    return zv;
}

pub inline fn copy(dst: *c.zval, src: *const c.zval) void {
    c.phpz_zval_copy(dst, src);
}

pub fn throwCe(ce: Ce, msg: [:0]const u8) Error {
    _ = c.zend_throw_exception(ce, msg.ptr, 0);
    return error.PhpException;
}

pub fn throwFmt(ce: Ce, comptime fmt: []const u8, args: anytype) Error {
    var buf: [512]u8 = undefined;
    const msg = std.fmt.bufPrintSentinel(&buf, fmt, args, 0) catch buf[0..0 :0];
    return throwCe(ce, msg);
}

pub fn invalidArgument(comptime fmt: []const u8, args: anytype) Error {
    return throwFmt(phpCe("spl_ce_InvalidArgumentException"), fmt, args);
}

pub fn valueError(comptime fmt: []const u8, args: anytype) Error {
    return throwFmt(phpCe("zend_ce_value_error"), fmt, args);
}

pub fn typeError(comptime fmt: [:0]const u8, args: anytype) Error {
    @call(.auto, c.zend_type_error, .{fmt.ptr} ++ args);
    return error.PhpException;
}

pub fn divisionByZero() Error {
    return throwCe(phpCe("zend_ce_division_by_zero_error"), "Division by zero");
}

pub const NumText = struct {
    /// zend_gcvt() caps precision at 318 digits.
    buf: [512]u8 = undefined,
    len: usize = 0,

    pub fn of(n: Num) NumText {
        var t = NumText{};
        switch (n) {
            .int => |v| t.len = (std.fmt.bufPrint(&t.buf, "{d}", .{v}) catch unreachable).len,
            .float => |v| {
                const s: *c.zend_string = c.zend_double_to_str(v);
                defer c.zend_string_release(s);
                const bytes = zstr(s);
                const n_ = @min(bytes.len, t.buf.len);
                @memcpy(t.buf[0..n_], bytes[0..n_]);
                t.len = n_;
            },
        }
        return t;
    }

    pub fn slice(self: *const NumText) []const u8 {
        return self.buf[0..self.len];
    }
};

pub fn retString(out: *c.zval, parts: []const []const u8) void {
    var total: usize = 0;
    for (parts) |p| total += p.len;
    const s: *c.zend_string = c.zend_string_alloc(total, false);
    var w: usize = 0;
    const dst = s.val()[0..total];
    for (parts) |p| {
        @memcpy(dst[w..][0..p.len], p);
        w += p.len;
    }
    dst.ptr[total] = 0;
    out.value.str = s;
    out.u1.type_info = c.IS_STRING_EX;
}

pub fn retStringBytes(out: *c.zval, bytes: []const u8) void {
    retString(out, &.{bytes});
}

pub fn persistentArray(count: u32) *c.zend_array {
    // Plain malloc, pemalloc has a different signature in debug and release PHP builds.
    const ht = std.heap.c_allocator.create(c.zend_array) catch @panic("qmath: out of memory during startup");
    c._zend_hash_init(ht, count, null, true);
    c.zend_hash_real_init_packed(ht);
    return ht;
}

pub fn freezeArray(ht: *c.zend_array) void {
    // Keep the persistent flag, zend_hash_destroy() uses it to pick the right free.
    ht.gc.refcount = 2;
    ht.gc.u.type_info |= (c.GC_IMMUTABLE | c.GC_NOT_COLLECTABLE) << c.GC_FLAGS_SHIFT;
}

pub fn freeArray(ht: *c.zend_array) void {
    // Debug builds assert a single owner before destroying.
    ht.gc.refcount = 1;
    c.zend_hash_destroy(ht);
    std.heap.c_allocator.destroy(ht);
}

pub inline fn setImmutableArray(zv: *c.zval, ht: *c.zend_array) void {
    zv.value.arr = ht;
    zv.u1.type_info = IS_ARRAY;
}

/// Backed by emalloc so memory_limit applies.
pub const allocator = phpz.heap.php_allocator;

pub fn oom() Error {
    if (!phpz.exception.hasPending()) _ = c.zend_throw_error(null, "Out of memory");
    return error.PhpException;
}

pub inline fn zstr(s: *c.zend_string) []const u8 {
    return s.val()[0..s.len];
}

pub inline fn zstrC(s: [*c]c.zend_string) [*:0]const u8 {
    return @ptrCast(s.*.val());
}

pub fn readLong(o: ZObj, p: Prop) Error!i64 {
    const zv = deref(&props(o)[p.slot]);
    if (ztype(zv) == IS_LONG) return zv.value.lval;
    var rv: c.zval = undefined;
    const res = try readSlow(o, p.name, &rv);
    defer c.zval_ptr_dtor(&rv);
    if (ztype(res) != IS_LONG) return typeError("Typed property must be of type int", .{});
    return res.value.lval;
}

/// Borrowed, `rv` owns the value when it was read through handlers.
pub fn readObject(o: ZObj, p: Prop, rv: *c.zval) Error!?ZObj {
    const slot = deref(&props(o)[p.slot]);
    if (ztype(slot) == IS_OBJECT) return slot.value.obj;
    const res = try readSlow(o, p.name, rv);
    return if (ztype(res) == IS_OBJECT) res.value.obj else null;
}
