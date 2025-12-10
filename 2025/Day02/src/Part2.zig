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
    for (idGroup.invalidIdsPartTwo) |id| {
        sum += id;
    }

    return sum;
}

pub fn isRepeatedSequenceOfDigits(stringRepresentationOfNumber: []const u8) bool {
    if (allCharactersAreEqual(stringRepresentationOfNumber)) {
        return true;
    }

    for (2..stringRepresentationOfNumber.len / 2 + 1) |candidateRepetitionLength| {
        if (isRepeatedSequenceOfDigitsOfLength(stringRepresentationOfNumber, candidateRepetitionLength)) {
            return true;
        }
    }

    return false;

    // if all digits are equal, return true;
    // Otherwise Go through all divisors up to and equal len/2. if get any repetitions, then return true;

    // for tryRepetitionsOfThisLength <= len/2 {
    // if @rem(len, tryRepetitionsOfThisLength) != 0 skip, else
    // comparativeIndices = (i, j, k, ..., z)
    // while (lastComparativeIndex < len) {
    // if string[i] != string[j] != string[k] != .... // Move on to the next one;
    // (i, j, k, ..., z)++
    // } return true (found a repetition)
    // } return false // didn't find a single duplicate when examining everything
}

pub fn isRepeatedSequenceOfDigitsOfLength(stringRepresentationOfNumber: []const u8, candidateRepetitionLength: u8) bool {
    const remainder: u128 = @rem(stringRepresentationOfNumber.len, candidateRepetitionLength);
    if (remainder != 0) return false;

    var indices: [candidateRepetitionLength]u8 = 0 ** candidateRepetitionLength;
    for (1..candidateRepetitionLength) |i| {
        indices[i] = (stringRepresentationOfNumber.len * i) / candidateRepetitionLength;
    }

    while (indices[candidateRepetitionLength - 1] < stringRepresentationOfNumber.len) {
        // Check if all bits equal each other. if false, return false,
        // iterate and increment all indices
    }

    return true;
}

fn allCharactersAreEqual(stringRepresentationOfNumber: []const u8) bool {
    for (1..stringRepresentationOfNumber.len) |i| { //exclusive upper
        if (stringRepresentationOfNumber[i - 1] != stringRepresentationOfNumber[i]) {
            break;
        }

        if (i == stringRepresentationOfNumber.len - 1) {
            return true;
        }
    }

    return false;
}

test "testRange" {
    const stringRepresentationOfNumber: []const u8 = "12345";

    for (1..stringRepresentationOfNumber.len) |i| {
        std.debug.print("\n index {any}: char {any}", .{ i, stringRepresentationOfNumber[i] - 48 });
    }
}

test "any repeated number is a repeated sequence" {
    const expected = true;

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("33"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("3333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("33333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("333333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("3333333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("33333333"));
}

test "any repeated pair of numbers is a repeated sequence" {
    const expected = true;

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("1212"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("123123"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("12341234"));
}

test "any numbers repeated three times is a repeated sequence" {
    const expected = true;

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("121212"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("123123123"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("1234123412345"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("2121212121"));
}

test "any repeated pattern with any out of sequence ending is not repeated sequence" {
    const expected = false;

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("334"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("2121212118"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("2121212119"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("2121212120"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("2121212122"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("2121212123"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("2121212124"));
}

test "all invalid ids from prompt" {
    const expected = true;

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("11"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("22"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("99"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("111"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("999"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("1010"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("1188511885"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("222222"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("446446"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("38593859"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("565656"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("824824824"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits("2121212121"));
}
