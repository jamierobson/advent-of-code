//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

const IdRange = struct { start: u32, end: u32 };
const SumOfInvalidIdsInRange = struct { range: IdRange, sumOfInvalid: u32 };
const RangeIndexes = struct { startByteIndex: u32, separatorByteIndex: u32, endByteIndex: u32 };

pub fn calculateSumOfInvalidIdsInRanges(allocator: std.mem.Allocator, buffer: []const u8) !std.ArrayList(SumOfInvalidIdsInRange) {
    const rangeIndexes = try getRangeIndexes(allocator, buffer);
    const idRanges = try getIdRanges(allocator, rangeIndexes);

    _ = idRanges;
    return .empty;
}

fn getIdRanges(allocator: std.mem.Allocator, rangeIndexes: std.ArrayList(RangeIndexes)) !std.ArrayList(RangeIndexes) {
    var idRanges: std.ArrayList(IdRange) = .empty;

    for (rangeIndexes.items) |rangeIndex| {
        const idRange = try getIdRange(rangeIndex);
        try idRanges.append(allocator, idRange);
    }

    return .empty;
}

fn getIdRange(rangeIndexes: RangeIndexes) !IdRange {
    _ = rangeIndexes;
    return .{ .start = 0, .end = 0 };
}

fn getRangeIndexes(allocator: std.mem.Allocator, buffer: []const u8) !std.ArrayList(RangeIndexes) {
    var idRanges: std.ArrayList(RangeIndexes) = .empty;
    var index: u32 = 1;

    var indexOfStartCharacter: u32 = 0;
    var indexOfSeparator: u32 = 0;

    while (index < buffer.len) {
        if (index == buffer.len - 1) {
            // just in case - but should be unreachable
            break;
        }

        if (buffer[index] == ',') {
            try idRanges.append(allocator, .{ .startByteIndex = indexOfStartCharacter, .separatorByteIndex = indexOfSeparator, .endByteIndex = index - 1 });
            indexOfStartCharacter = buffer[index + 1];
        }

        if (buffer[index] == '-') {
            indexOfSeparator = index;
        }
        index += 1;
    }

    return idRanges;
}

fn isValid(stringRepresentationOfNumber: []const u8) bool {
    return !isRepeatedSequenceOfDigits(stringRepresentationOfNumber);
}

fn isRepeatedSequenceOfDigits(stringRepresentationOfNumber: []const u8) bool {
    const s: u128 = @rem(stringRepresentationOfNumber.len, 2);
    if (s != 0) return false;

    var i: usize = 0;
    var j: usize = stringRepresentationOfNumber.len / 2;

    while (j < stringRepresentationOfNumber.len) {
        if (stringRepresentationOfNumber[i] != stringRepresentationOfNumber[j]) return false;

        i += 1;
        j += 1;
    }

    return true;
}

test "odd lengths cannot be repeated strings" {
    const expected = false;

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("1"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("111"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("11111"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("1111111"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("111111111"));
}

test "sample input from prompty 95-115 - valid" {
    try std.testing.expectEqual(true, isValid("95"));
    try std.testing.expectEqual(true, isValid("96"));
    try std.testing.expectEqual(true, isValid("97"));
    try std.testing.expectEqual(true, isValid("98"));

    try std.testing.expectEqual(true, isValid("100"));
    try std.testing.expectEqual(true, isValid("101"));
    try std.testing.expectEqual(true, isValid("102"));
    try std.testing.expectEqual(true, isValid("103"));
    try std.testing.expectEqual(true, isValid("104"));
    try std.testing.expectEqual(true, isValid("105"));
    try std.testing.expectEqual(true, isValid("106"));
    try std.testing.expectEqual(true, isValid("107"));
    try std.testing.expectEqual(true, isValid("108"));
    try std.testing.expectEqual(true, isValid("109"));
    try std.testing.expectEqual(true, isValid("110"));
    try std.testing.expectEqual(true, isValid("111"));
    try std.testing.expectEqual(true, isValid("112"));
    try std.testing.expectEqual(true, isValid("113"));
    try std.testing.expectEqual(true, isValid("114"));
    try std.testing.expectEqual(true, isValid("115"));
}

test "sample input from prompty 95-115 - invalid" {
    try std.testing.expectEqual(false, isValid("99"));
}
