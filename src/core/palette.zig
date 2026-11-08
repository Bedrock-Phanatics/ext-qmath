//! Chunk section palettes in the PalettedBlockArray layout.

const std = @import("std");

pub const section_cells = 4096;

/// Section cell order shared with SubChunk: x, z, y.
pub fn localIndex(lx: u4, ly: u4, lz: u4) u12 {
    return (@as(u12, lx) << 8) | (@as(u12, lz) << 4) | ly;
}

/// Expands a PalettedBlockArray word array (little-endian u32 words) into palette indexes.
pub fn decode(bits_per_block: i64, words: []const u8, palette_len: usize, out: *[section_cells]u16) error{InvalidPalette}!void {
    if (palette_len == 0 or palette_len > section_cells) return error.InvalidPalette;
    if (bits_per_block == 0) {
        if (words.len != 0 or palette_len != 1) return error.InvalidPalette;
        @memset(out, 0);
        return;
    }
    const bpb: u5 = switch (bits_per_block) {
        1, 2, 3, 4, 5, 6, 8, 16 => @intCast(bits_per_block),
        else => return error.InvalidPalette,
    };
    const per_word: usize = 32 / @as(usize, bpb);
    if (words.len != (section_cells + per_word - 1) / per_word * 4) return error.InvalidPalette;
    const mask: u32 = (@as(u32, 1) << bpb) - 1;
    for (out, 0..) |*o, i| {
        const word = std.mem.readInt(u32, words[i / per_word * 4 ..][0..4], .little);
        const idx = (word >> @intCast((i % per_word) * bpb)) & mask;
        if (idx >= palette_len) return error.InvalidPalette;
        o.* = @intCast(idx);
    }
}

const testing = std.testing;

test "word order and padding" {
    var out: [section_cells]u16 = undefined;
    var words: [256 * 4]u8 = @splat(0);
    // 2 bits per block, 16 per word: cell 1 is entry 1 and cell 17 is entry 2
    words[0] = 0b0100;
    words[4] = 0b1000;
    try decode(2, &words, 3, &out);
    try testing.expectEqual(@as(u16, 0), out[0]);
    try testing.expectEqual(@as(u16, 1), out[1]);
    try testing.expectEqual(@as(u16, 2), out[17]);
    try decode(0, "", 1, &out);
    try testing.expect(std.mem.allEqual(u16, &out, 0));
    words[0] = 0b1100;
    try testing.expectError(error.InvalidPalette, decode(2, &words, 3, &out));
    try testing.expectError(error.InvalidPalette, decode(2, words[0..8], 3, &out));
    try testing.expectError(error.InvalidPalette, decode(7, &words, 3, &out));
    try testing.expectError(error.InvalidPalette, decode(0, "", 3, &out));
    // 3 bits per block leaves 2 bits of padding per word
    var w3: [410 * 4]u8 = @splat(0);
    w3[4] = 0b010;
    try decode(3, &w3, 3, &out);
    try testing.expectEqual(@as(u16, 2), out[10]);
    try testing.expectEqual(@as(u16, 0), out[9]);
}
