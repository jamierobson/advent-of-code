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

pub fn isRepeatedSequenceOfDigits(allocator: std.mem.Allocator, stringRepresentationOfNumber: []const u8) !bool {
    var sequenceLength: u8 = 1;
    while (sequenceLength <= (stringRepresentationOfNumber.len / 2)) {
        if (try isRepetedSequenceOfDigitsOfLength(allocator, stringRepresentationOfNumber, sequenceLength)) {
            return true;
        }

        sequenceLength += 1;
    }

    return false;
}

fn isRepetedSequenceOfDigitsOfLength(allocator: std.mem.Allocator, stringRepresentationOfNumber: []const u8, sequenceLength: u8) !bool {
    if (@rem(stringRepresentationOfNumber.len, sequenceLength) != 0) return false; // We can't have a repetition of a sequence if the sequence length doesn't divide the length of the number
    _ = allocator;
    const numberOfPartitions = stringRepresentationOfNumber.len / sequenceLength;

    // Example: 9 digit number, looking to sequences of length 3
    // Need to do compare indexes in paritions like
    // 0 1 2 (partition 1)
    // 3 4 5 (partition 2)
    // 6 7 8 (partition 3)

    for (1..numberOfPartitions) |partitionNumber| { // partition 1, and 2
        for (0..sequenceLength) |indexWithinPartition| { // offsets 0, 1, 2

            // Compare characters in a different partition, with the same offset within that parition
            const thisCharacterIndex = partitionNumber * sequenceLength + indexWithinPartition;
            const compareToPreviousCharacterIndex = (partitionNumber - 1) * sequenceLength + indexWithinPartition;

            std.debug.print("sequence length of {any}. compare index {any} ({any}) to index {any} ({any}) \n", .{ sequenceLength, thisCharacterIndex, stringRepresentationOfNumber[thisCharacterIndex] - 48, compareToPreviousCharacterIndex, stringRepresentationOfNumber[compareToPreviousCharacterIndex] - 48 });

            if (stringRepresentationOfNumber[thisCharacterIndex] != stringRepresentationOfNumber[compareToPreviousCharacterIndex]) return false;
        }
    }

    return true;
}

test "any repeated number is a repeated sequence" {
    const expected = true;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "33333"));
}

test "any repeated pair of numbers is a repeated sequence" {
    const expected = true;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "1212"));
}

test "any numbers repeated three times is a repeated sequence" {
    const expected = true;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "123451234512345"));
}

test "simple repeated pattern with any out of sequence ending is not repeated sequence" {
    const expected = false;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "1211"));
}

test "any repeated pattern with any out of sequence ending is not repeated sequence" {
    const expected = false;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "1231230"));
}

test "Snapshot - all invalid ids from prompt" {
    const expected = true;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "11"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "22"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "99"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "111"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "999"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "1010"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "1188511885"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "222222"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "446446"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "38593859"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "565656"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "824824824"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "2121212121"));
}
