//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub fn isValid(stringRepresentationOfNumber: []const u8) bool {
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
