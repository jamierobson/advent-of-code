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

    const numberOfPartitions = stringRepresentationOfNumber.len / sequenceLength;

    // Initialize indices, e.g. if we are assessing if a string of 9 characters has a repeated string of length 3, then this would be a collection of 3 items: 0, 3, 6
    // var indices = try std.ArrayList(usize).initCapacity(allocator, numberOfPartitions);
    var indices: std.ArrayList(usize) = .empty;
    defer indices.deinit(allocator);

    var partition: usize = 0;
    while (partition < numberOfPartitions) {
        try indices.append(allocator, partition * sequenceLength);
        // indices.items[partition] = partition * sequenceLength;
        partition += 1;
    }

    // Iterates until final index would be out of bounds.
    while (indices.items[numberOfPartitions - 1] < stringRepresentationOfNumber.len) {
        for (1..numberOfPartitions) |i| {
            if (stringRepresentationOfNumber[i - 1] != stringRepresentationOfNumber[i]) {
                return false;
            }
        }

        // The sequence comparison still holds. Continue the comparison.
        // Increment _all_ indices. In our example of a 9 digit number and a 3 digit sequence
        // we iterate from (0, 3, 6) to (1, 4, 7)
        for (0..indices.items.len) |i| {
            indices.items[i] += 1;
        }
    }

    return true;
}

// for 0 .. sequenceLength
// for 0 .. partition

// This is flawed. Todo: merge together with "all characters are equal"
// fn isRepetedSequenceOfCharactersOfLength(allocator: std.mem.Allocator, stringRepresentationOfNumber: []const u8, candidateRepetitionLength: u8) !bool {
//     const remainder: u128 = @rem(stringRepresentationOfNumber.len, candidateRepetitionLength);
//     if (remainder != 0) return false;

//     var indices: std.ArrayList(usize) = .empty;
//     defer indices.deinit(allocator);

//     var indexDivision: u8 = 0;
//     while (indexDivision < candidateRepetitionLength) {
//         try indices.append(allocator, (stringRepresentationOfNumber.len * indexDivision) / candidateRepetitionLength);
//         indexDivision += 1;
//     }

//     while (indices.items[candidateRepetitionLength - 1] < stringRepresentationOfNumber.len) {

//         //If any values are different, we return false, otherwise continue to the next indices.
//         for (1..indices.items.len) |i| {
//             if (stringRepresentationOfNumber[i - 1] != stringRepresentationOfNumber[i]) {
//                 return false;
//             }
//         }

//         // increment all indices. In our example we iterate to (1, 4, 7), then (2, 5, 8), and then (3, 6, 9)
//         // In the while condition, 8 is not < (9-1) and so the comparison is finished, and the answer is - yes, everything is equal
//         for (0..indices.items.len) |i| {
//             indices.items[i] += 1;
//         }
//     }

//     return true;
// }

fn allCharactersAreEqual(stringRepresentationOfNumber: []const u8) bool {
    for (1..stringRepresentationOfNumber.len) |i| { //exclusive upper
        if (stringRepresentationOfNumber[i - 1] != stringRepresentationOfNumber[i]) {
            return false;
        }
    }

    return true;
}

test "any repeated number is a repeated sequence" {
    const expected = true;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "33"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "3333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "33333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "333333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "3333333"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "33333333"));
}

test "any repeated pair of numbers is a repeated sequence" {
    const expected = true;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "1212"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "123123"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "12341234"));
}

test "any numbers repeated three times is a repeated sequence" {
    const expected = true;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "121212"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "123123123"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "1234123412345"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "2121212121"));
}

test "any repeated pattern with any out of sequence ending is not repeated sequence" {
    const expected = false;

    var arenaAllocator: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaAllocator.deinit();
    const allocator = arenaAllocator.allocator();

    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "334"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "2121212118"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "2121212119"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "2121212120"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "2121212122"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "2121212123"));
    try std.testing.expectEqual(expected, isRepeatedSequenceOfDigits(allocator, "2121212124"));
}

test "all invalid ids from prompt" {
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
