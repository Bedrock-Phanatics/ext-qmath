//! pocketmine\math\Matrix. Quark does not use it; it is ported for completeness on top of the same
//! private PHP array so ArrayAccess keeps working.

const std = @import("std");
const rt = @import("rt.zig");
const phpz = rt.phpz;
const c = rt.c;
const Ctx = rt.Ctx;
const Error = rt.Error;
const ZObj = rt.ZObj;
const vector = @import("vector.zig");

var ce: rt.Ce = undefined;
var p_matrix: rt.Prop = undefined;
var p_rows: rt.Prop = undefined;
var p_cols: rt.Prop = undefined;

pub fn startup() void {
    ce = rt.cePtr(MatrixClass.entry);
    p_matrix = rt.Prop.resolve(ce, "matrix");
    p_rows = rt.Prop.resolve(ce, "rows");
    p_cols = rt.Prop.resolve(ce, "columns");
}

const Dims = struct { rows: i64, cols: i64 };

fn dims(o: ZObj) Error!Dims {
    return .{ .rows = try rt.readLong(o, p_rows), .cols = try rt.readLong(o, p_cols) };
}

/// The private $matrix array, separated so it can be written in place.
fn writable(o: ZObj) Error!*c.zend_array {
    const slot = rt.deref(&rt.props(o)[p_matrix.slot]);
    if (rt.ztype(slot) != rt.IS_ARRAY) return rt.typeError("Matrix::$matrix must be an array", .{});
    const arr: *c.zend_array = slot.value.arr;
    if (arr.gc.refcount > 1 or (arr.gc.u.type_info & (c.GC_IMMUTABLE << c.GC_FLAGS_SHIFT)) != 0) {
        const dup = c.zend_array_dup(arr);
        if ((arr.gc.u.type_info & (c.GC_IMMUTABLE << c.GC_FLAGS_SHIFT)) == 0) arr.gc.refcount -= 1;
        slot.value.arr = dup;
        slot.u1.type_info = c.IS_ARRAY_EX;
        return dup;
    }
    return arr;
}

fn readable(o: ZObj) Error!*c.zend_array {
    const slot = rt.deref(&rt.props(o)[p_matrix.slot]);
    if (rt.ztype(slot) != rt.IS_ARRAY) return rt.typeError("Matrix::$matrix must be an array", .{});
    return slot.value.arr;
}

fn undefinedKey(k: i64) void {
    c.zend_error(c.E_WARNING, "Undefined array key " ++ "%lld", @as(c_longlong, k));
}

/// `$this->matrix[$r][$c]` with PHP's warnings, null when missing.
fn element(arr: *c.zend_array, r: i64, col: i64) ?*c.zval {
    const row_raw = c.zend_hash_index_find(arr, @bitCast(r)) orelse {
        undefinedKey(r);
        c.zend_error(c.E_WARNING, "Trying to access array offset on null");
        return null;
    };
    const row = rt.deref(row_raw);
    if (rt.ztype(row) != rt.IS_ARRAY) {
        c.zend_error(c.E_WARNING, "Trying to access array offset on %s", c.zend_zval_value_name(row));
        return null;
    }
    const v = c.zend_hash_index_find(row.value.arr, @bitCast(col)) orelse {
        undefinedKey(col);
        return null;
    };
    return rt.deref(v);
}

/// `$this->matrix[$r][$c] = $value`
fn setRaw(arr: *c.zend_array, r: i64, col: i64, value: *c.zval) Error!void {
    var row: *c.zval = undefined;
    if (c.zend_hash_index_find(arr, @bitCast(r))) |found| {
        row = rt.deref(found);
        if (rt.ztype(row) == rt.IS_NULL) rt.newArray(row, 0);
    } else {
        var fresh: c.zval = undefined;
        rt.newArray(&fresh, 0);
        row = c.zend_hash_index_update(arr, @bitCast(r), &fresh);
    }
    if (rt.ztype(row) != rt.IS_ARRAY) return rt.throwCe(rt.phpCe("zend_ce_error"), "Cannot use a scalar value as an array");
    const row_arr: *c.zend_array = row.value.arr;
    if (row_arr.gc.refcount > 1 or (row_arr.gc.u.type_info & (c.GC_IMMUTABLE << c.GC_FLAGS_SHIFT)) != 0) {
        const dup = c.zend_array_dup(row_arr);
        if ((row_arr.gc.u.type_info & (c.GC_IMMUTABLE << c.GC_FLAGS_SHIFT)) == 0) row_arr.gc.refcount -= 1;
        row.value.arr = dup;
        row.u1.type_info = c.IS_ARRAY_EX;
    }
    store(row.value.arr, col, value);
}

/// `$arr[$k] = $v`. The old value is released last because its destructor may modify the array.
fn store(arr: *c.zend_array, k: i64, v: *c.zval) void {
    const slot: *c.zval = c.zend_hash_index_lookup(arr, @bitCast(k));
    var old = slot.*;
    slot.* = v.*;
    c.zval_ptr_dtor(&old);
}

fn floatParam(zv: *c.zval) Error!f64 {
    return switch (rt.ztype(zv)) {
        rt.IS_DOUBLE => zv.value.dval,
        rt.IS_LONG => @floatFromInt(zv.value.lval),
        else => blk: {
            _ = rt.typeError("pocketmine\\math\\Matrix::setElement(): Argument #3 ($value) must be of type float, %s given", .{c.zend_zval_value_name(zv)}) catch {};
            break :blk error.PhpException;
        },
    };
}

fn floatReturn(zv: ?*c.zval, comptime method: []const u8) Error!f64 {
    const v = zv orelse return rt.typeError("pocketmine\\math\\Matrix::" ++ method ++ "(): Return value must be of type float, null returned", .{});
    return switch (rt.ztype(v)) {
        rt.IS_DOUBLE => v.value.dval,
        rt.IS_LONG => @floatFromInt(v.value.lval),
        else => rt.typeError("pocketmine\\math\\Matrix::" ++ method ++ "(): Return value must be of type float, %s returned", .{c.zend_zval_value_name(v)}),
    };
}

fn checkBounds(d: Dims, r: i64, col: i64) Error!void {
    // QuarkMath allows row == rows and column == columns, keep that.
    if (r > d.rows or r < 0 or col > d.cols or col < 0) {
        return rt.invalidArgument("Row or column out of bounds (have {d} rows {d} columns)", .{ d.rows, d.cols });
    }
}

const Op = enum { add, sub, mul, div };

fn binary(op: Op, a: *c.zval, b: *c.zval) Error!c.zval {
    var r: c.zval = undefined;
    rt.setNull(&r);
    const res = switch (op) {
        .add => c.add_function(&r, a, b),
        .sub => c.sub_function(&r, a, b),
        .mul => c.mul_function(&r, a, b),
        .div => c.div_function(&r, a, b),
    };
    if (res != c.SUCCESS or phpz.exception.hasPending()) {
        c.zval_ptr_dtor(&r);
        return error.PhpException;
    }
    return r;
}

fn nullZval() c.zval {
    var z: c.zval = undefined;
    rt.setNull(&z);
    return z;
}

/// `new Matrix($rows, $cols)` into `out`.
fn construct(out: *c.zval, rows: i64, cols: i64) Error!ZObj {
    const o = rt.newObject(out, ce);
    try init(o, rows, cols, null);
    return o;
}

fn init(o: ZObj, rows_in: i64, cols_in: i64, set: ?*c.zend_array) Error!void {
    var zv: c.zval = undefined;
    rt.setLong(&zv, @max(1, rows_in));
    try rt.writeZval(o, p_rows, &zv);
    rt.setLong(&zv, @max(1, cols_in));
    try rt.writeZval(o, p_cols, &zv);
    try setFrom(o, set);
}

fn setFrom(o: ZObj, m: ?*c.zend_array) Error!void {
    const d = try dims(o);
    var r: i64 = 0;
    while (r < d.rows) : (r += 1) {
        var row: c.zval = undefined;
        rt.newArray(&row, @intCast(std.math.clamp(d.cols, 0, 1 << 20)));
        const src_row: ?*c.zval = if (m) |mm| (if (c.zend_hash_index_find(mm, @bitCast(r))) |x| rt.deref(x) else null) else null;
        var col: i64 = 0;
        while (col < d.cols) : (col += 1) {
            var v: c.zval = undefined;
            const found: ?*c.zval = if (src_row != null and rt.ztype(src_row.?) == rt.IS_ARRAY) c.zend_hash_index_find(src_row.?.value.arr, @bitCast(col)) else null;
            if (found != null and rt.ztype(rt.deref(found.?)) != rt.IS_NULL) {
                rt.copy(&v, rt.deref(found.?));
            } else {
                rt.setLong(&v, 0);
            }
            _ = c.zend_hash_next_index_insert(row.value.arr, &v);
        }
        // Replacing a row can run destructors, so look the array up again each time.
        const arr = writable(o) catch |e| {
            c.zval_ptr_dtor(&row);
            return e;
        };
        store(arr, r, &row);
    }
}

fn argMatrix(ctx: Ctx, n: u32) Error!ZObj {
    return vector.argObject(ctx, n, ce);
}

fn cloneThis(ctx: Ctx) Error!ZObj {
    const o = rt.this(ctx);
    const copy = o.handlers.*.clone_obj.?(o) orelse return error.PhpException;
    const out = rt.ret(ctx);
    out.value.obj = copy;
    out.u1.type_info = c.IS_OBJECT_EX;
    if (phpz.exception.hasPending()) return error.PhpException;
    return copy;
}

fn setElementChecked(o: ZObj, r: i64, col: i64, value: *c.zval) Error!void {
    try checkBounds(try dims(o), r, col);
    var d: c.zval = undefined;
    rt.setDouble(&d, try floatParam(value));
    try setRaw(try writable(o), r, col, &d);
}

fn getElementChecked(o: ZObj, r: i64, col: i64) Error!f64 {
    try checkBounds(try dims(o), r, col);
    return floatReturn(element(try readable(o), r, col), "getElement");
}

fn elementOrNull(arr: *c.zend_array, r: i64, col: i64) c.zval {
    var v = nullZval();
    if (element(arr, r, col)) |e| rt.copy(&v, e);
    return v;
}

pub const Matrix = struct {
    pub fn offsetExists(ctx: Ctx) Error!bool {
        try ctx.call.expectArgCount(1, 1);
        const k = c.zval_get_long(rt.arg(ctx, 1));
        const v = c.zend_hash_index_find(try readable(rt.this(ctx)), @bitCast(k)) orelse return false;
        return rt.ztype(rt.deref(v)) != rt.IS_NULL;
    }

    pub fn offsetGet(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const k = c.zval_get_long(rt.arg(ctx, 1));
        const v = c.zend_hash_index_find(try readable(rt.this(ctx)), @bitCast(k)) orelse {
            undefinedKey(k);
            return;
        };
        rt.copy(rt.ret(ctx), rt.deref(v));
    }

    pub fn offsetSet(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(2, 2);
        const k = c.zval_get_long(rt.arg(ctx, 1));
        const arr = try writable(rt.this(ctx));
        var v: c.zval = undefined;
        rt.copy(&v, rt.deref(rt.arg(ctx, 2)));
        store(arr, k, &v);
    }

    pub fn offsetUnset(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const k = c.zval_get_long(rt.arg(ctx, 1));
        _ = c.zend_hash_index_del(try writable(rt.this(ctx)), @bitCast(k));
    }

    pub fn __construct(ctx: Ctx, rows: i64, columns: i64, initial: ?*phpz.zend.Array) Error!void {
        try init(rt.this(ctx), rows, columns, if (initial) |s| s.ptr() else null);
    }

    pub fn set(ctx: Ctx, m: *phpz.zend.Array) Error!void {
        try setFrom(rt.this(ctx), m.ptr());
    }

    pub fn getRows(ctx: Ctx) Error!i64 {
        return rt.readLong(rt.this(ctx), p_rows);
    }

    pub fn getColumns(ctx: Ctx) Error!i64 {
        return rt.readLong(rt.this(ctx), p_cols);
    }

    pub fn setElement(ctx: Ctx, row: i64, column: i64, value: f64) Error!void {
        var v: c.zval = undefined;
        rt.setDouble(&v, value);
        try setElementChecked(rt.this(ctx), row, column, &v);
    }

    pub fn getElement(ctx: Ctx, row: i64, column: i64) Error!f64 {
        return getElementChecked(rt.this(ctx), row, column);
    }

    pub fn isSquare(ctx: Ctx) Error!bool {
        const d = try dims(rt.this(ctx));
        return d.rows == d.cols;
    }

    fn sameShape(a: Dims, b: Dims) Error!void {
        if (a.rows != b.rows or a.cols != b.cols) return rt.invalidArgument("Matrix does not have the same number of rows and/or columns", .{});
    }

    pub fn add(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const o = rt.this(ctx);
        const other = try argMatrix(ctx, 1);
        const d = try dims(o);
        try sameShape(d, try dims(other));
        const out = rt.ret(ctx);
        const result = try construct(out, d.rows, d.cols);
        // Warnings and string conversions can run PHP code, pinning keeps this array valid.
        const arr = try readable(o);
        rt.pinArray(arr);
        defer rt.unpinArray(arr);
        var r: i64 = 0;
        while (r < d.rows) : (r += 1) {
            var col: i64 = 0;
            while (col < d.cols) : (col += 1) {
                var e: c.zval = undefined;
                rt.setDouble(&e, try getElementChecked(other, r, col));
                var mine = elementOrNull(arr, r, col);
                defer c.zval_ptr_dtor(&mine);
                var sum = try binary(.add, &mine, &e);
                defer c.zval_ptr_dtor(&sum);
                try setElementChecked(result, r, col, &sum);
            }
        }
    }

    fn scalarOp(ctx: Ctx, op: Op, other: ?ZObj, number: f64) Error!void {
        const o = rt.this(ctx);
        const d = try dims(o);
        if (other) |m| try sameShape(d, try dims(m));
        const result = try cloneThis(ctx);
        // Warnings and string conversions can run PHP code, pinning keeps this array valid.
        const arr = try readable(o);
        rt.pinArray(arr);
        defer rt.unpinArray(arr);
        var n: c.zval = undefined;
        rt.setDouble(&n, number);
        var r: i64 = 0;
        while (r < d.rows) : (r += 1) {
            var col: i64 = 0;
            while (col < d.cols) : (col += 1) {
                var rhs = n;
                if (other) |m| rt.setDouble(&rhs, try getElementChecked(m, r, col));
                var mine = elementOrNull(arr, r, col);
                defer c.zval_ptr_dtor(&mine);
                var v = try binary(op, &mine, &rhs);
                defer c.zval_ptr_dtor(&v);
                try setElementChecked(result, r, col, &v);
            }
        }
    }

    pub fn subtract(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        try scalarOp(ctx, .sub, try argMatrix(ctx, 1), 0);
    }

    pub fn multiplyScalar(ctx: Ctx, number: f64) Error!void {
        try scalarOp(ctx, .mul, null, number);
    }

    pub fn divideScalar(ctx: Ctx, number: f64) Error!void {
        try scalarOp(ctx, .div, null, number);
    }

    pub fn transpose(ctx: Ctx) Error!void {
        const o = rt.this(ctx);
        const d = try dims(o);
        const result = try construct(rt.ret(ctx), d.cols, d.rows);
        // Warnings and string conversions can run PHP code, pinning keeps this array valid.
        const arr = try readable(o);
        rt.pinArray(arr);
        defer rt.unpinArray(arr);
        var r: i64 = 0;
        while (r < d.rows) : (r += 1) {
            var col: i64 = 0;
            while (col < d.cols) : (col += 1) {
                var v = elementOrNull(arr, r, col);
                defer c.zval_ptr_dtor(&v);
                try setElementChecked(result, col, r, &v);
            }
        }
    }

    pub fn product(ctx: Ctx) Error!void {
        try ctx.call.expectArgCount(1, 1);
        const o = rt.this(ctx);
        const other = try argMatrix(ctx, 1);
        const d = try dims(o);
        const od = try dims(other);
        if (d.cols != od.rows) return rt.invalidArgument("Expected a matrix with {d} rows", .{d.cols});
        const result = try construct(rt.ret(ctx), d.rows, od.cols);
        // Warnings and string conversions can run PHP code, pinning keeps this array valid.
        const arr = try readable(o);
        rt.pinArray(arr);
        defer rt.unpinArray(arr);
        var i: i64 = 0;
        while (i < d.rows) : (i += 1) {
            var j: i64 = 0;
            while (j < od.cols) : (j += 1) {
                var sum: c.zval = undefined;
                rt.setLong(&sum, 0);
                defer c.zval_ptr_dtor(&sum);
                var k: i64 = 0;
                while (k < d.cols) : (k += 1) {
                    var e: c.zval = undefined;
                    rt.setDouble(&e, try getElementChecked(other, k, j));
                    var mine = elementOrNull(arr, i, k);
                    defer c.zval_ptr_dtor(&mine);
                    var prod = try binary(.mul, &mine, &e);
                    defer c.zval_ptr_dtor(&prod);
                    const next = try binary(.add, &sum, &prod);
                    c.zval_ptr_dtor(&sum);
                    sum = next;
                }
                try setElementChecked(result, i, j, &sum);
            }
        }
    }

    pub fn determinant(ctx: Ctx) Error!f64 {
        const o = rt.this(ctx);
        const d = try dims(o);
        if (d.rows != d.cols) return rt.throwCe(rt.phpCe("spl_ce_LogicException"), "Cannot calculate determinant of a non-square matrix");
        // Warnings and string conversions can run PHP code, pinning keeps this array valid.
        const arr = try readable(o);
        rt.pinArray(arr);
        defer rt.unpinArray(arr);
        const at = struct {
            fn f(a: *c.zend_array, r: i64, col: i64) c.zval {
                return elementOrNull(a, r, col);
            }
        }.f;
        switch (d.rows) {
            1 => {
                var v = at(arr, 0, 0);
                defer c.zval_ptr_dtor(&v);
                return floatReturn(if (rt.ztype(&v) == rt.IS_NULL) null else &v, "determinant");
            },
            2 => {
                var m00 = at(arr, 0, 0);
                var m11 = at(arr, 1, 1);
                var m01 = at(arr, 0, 1);
                var m10 = at(arr, 1, 0);
                defer for ([_]*c.zval{ &m00, &m11, &m01, &m10 }) |z| c.zval_ptr_dtor(z);
                var a = try binary(.mul, &m00, &m11);
                defer c.zval_ptr_dtor(&a);
                var b = try binary(.mul, &m01, &m10);
                defer c.zval_ptr_dtor(&b);
                var r = try binary(.sub, &a, &b);
                defer c.zval_ptr_dtor(&r);
                return floatReturn(&r, "determinant");
            },
            3 => {
                var m: [3][3]c.zval = undefined;
                for (0..3) |r| for (0..3) |col| {
                    m[r][col] = at(arr, @intCast(r), @intCast(col));
                };
                defer for (0..3) |r| for (0..3) |col| c.zval_ptr_dtor(&m[r][col]);
                const terms = [6][3][2]u8{
                    .{ .{ 0, 0 }, .{ 1, 1 }, .{ 2, 2 } },
                    .{ .{ 0, 1 }, .{ 1, 2 }, .{ 2, 0 } },
                    .{ .{ 0, 2 }, .{ 1, 0 }, .{ 2, 1 } },
                    .{ .{ 2, 0 }, .{ 1, 1 }, .{ 0, 2 } },
                    .{ .{ 2, 1 }, .{ 1, 2 }, .{ 0, 0 } },
                    .{ .{ 2, 2 }, .{ 1, 0 }, .{ 0, 1 } },
                };
                var acc = nullZval();
                defer c.zval_ptr_dtor(&acc);
                for (terms, 0..) |t, ti| {
                    var p1 = try binary(.mul, &m[t[0][0]][t[0][1]], &m[t[1][0]][t[1][1]]);
                    defer c.zval_ptr_dtor(&p1);
                    var p2 = try binary(.mul, &p1, &m[t[2][0]][t[2][1]]);
                    defer c.zval_ptr_dtor(&p2);
                    if (ti == 0) {
                        rt.copy(&acc, &p2);
                    } else {
                        const next = try binary(if (ti < 3) .add else .sub, &acc, &p2);
                        c.zval_ptr_dtor(&acc);
                        acc = next;
                    }
                }
                return floatReturn(&acc, "determinant");
            },
            else => return rt.throwCe(rt.phpCe("spl_ce_LogicException"), "Not implemented"),
        }
    }

    pub fn __toString(ctx: Ctx) Error!void {
        const o = rt.this(ctx);
        const d = try dims(o);
        // Warnings and string conversions can run PHP code, pinning keeps this array valid.
        const arr = try readable(o);
        rt.pinArray(arr);
        defer rt.unpinArray(arr);
        var buf: std.ArrayList(u8) = .empty;
        defer buf.deinit(rt.allocator);
        const rows = rt.NumText.of(rt.Num.i(d.rows));
        const cols = rt.NumText.of(rt.Num.i(d.cols));
        buf.appendSlice(rt.allocator, "Matrix(") catch return rt.oom();
        buf.appendSlice(rt.allocator, rows.slice()) catch return rt.oom();
        buf.append(rt.allocator, 'x') catch return rt.oom();
        buf.appendSlice(rt.allocator, cols.slice()) catch return rt.oom();
        buf.append(rt.allocator, ';') catch return rt.oom();
        const glue = c.zend_string_init_interned.?(",", 1, false);
        defer c.zend_string_release(glue);
        var r: i64 = 0;
        while (r < d.rows) : (r += 1) {
            const row_raw = c.zend_hash_index_find(arr, @bitCast(r)) orelse {
                undefinedKey(r);
                return rt.typeError("implode(): Argument #1 ($array) must be of type array, string given", .{});
            };
            const row = rt.deref(row_raw);
            if (rt.ztype(row) != rt.IS_ARRAY) return rt.typeError("implode(): Argument #2 ($array) must be of type ?array, %s given", .{c.zend_zval_value_name(row)});
            var joined: c.zval = undefined;
            c.php_implode(glue, row.value.arr, &joined);
            defer c.zval_ptr_dtor(&joined);
            if (phpz.exception.hasPending()) return error.PhpException;
            buf.appendSlice(rt.allocator, rt.zstr(joined.value.str)) catch return rt.oom();
            buf.append(rt.allocator, ';') catch return rt.oom();
        }
        // substr($s, 0, -1) drops the final row separator
        const body = buf.items;
        const trimmed = if (d.rows > 0) body[0 .. body.len - 1] else body;
        rt.retString(rt.ret(ctx), &.{ trimmed, ")" });
    }
};

fn registerArrayAccess(register_fn: anytype) *phpz.ClassEntry {
    return register_fn(.{.builtin("ArrayAccess")});
}

pub const MatrixClass = phpz.Class("pocketmine\\math\\Matrix", Matrix, .{ .register = registerArrayAccess });
