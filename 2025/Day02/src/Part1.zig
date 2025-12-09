const std = @import("std");
const types = @import("types.zig");

pub fn getSumOfInvalidInRanges(idGroups: []types.IdGroup) u128 {
    var totalSum: u128 = 0;
    for (idGroups) |group| {
        totalSum += getSumOfInvalidInRange(group);
    }

    return totalSum;
}

fn getSumOfInvalidInRange(idGroup: types.IdGroup) u128 {
    var sum: u128 = 0;
    for (idGroup.invalidIdsPartOne.items) |id| {
        sum += id;
    }

    return sum;
}

pub fn isRepeatedSequenceOfDigits(stringRepresentationOfNumber: []const u8) bool {
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

// todo: Understand why this fails at runtime. We seem to need a @ConstCast() somewhere
// error: expected type '*<T>', found '*const <T>'
// note: <T> = array_list.Aligned(u64,null)
// note: cast discards const qualifier
pub fn appendInvalidId(group: types.IdGroup, id: u64) !void {
    try group.invalidIdsPartOne.append(group._allocator, id);
}

test "Odd lengths cannot be repeated strings" {
    const expected = false;

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("1"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("111"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("11111"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("1111111"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("111111111"));
}

test "Sample input from prompty 95-115 - valid" {
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("95"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("96"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("97"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("98"));

    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("100"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("101"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("102"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("103"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("104"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("105"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("106"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("107"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("108"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("109"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("110"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("111"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("112"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("113"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("114"));
    try std.testing.expectEqual(false, isRepeatedSequenceOfDigits("115"));
}

test "Sample input from prompty 95-115 - invalid" {
    try std.testing.expectEqual(true, isRepeatedSequenceOfDigits("99"));
}
