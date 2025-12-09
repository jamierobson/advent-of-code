const std = @import("std");

const IdRange = struct { start: u64, end: u64 };

const IdGroup = struct {
    const Self = @This();
    examinedRange: IdRange,
    invalidIdsPartOne: []u64,
    invalidIdsPartTwo: []u64,
    pub fn sumOfInvalidPartOne(self: Self) u128 {
        return sumOfInvalid(self.invalidIdsPartOne);
    }
    pub fn sumOfInvalidPartTwo(self: Self) u128 {
        return sumOfInvalid(self.invalidIdsPartTwo);
    }

    fn sumOfInvalid(numbers: []u64) u128 {
        var sum: u128 = 0;
        for (numbers) |i| {
            sum += i;
        }

        return sum;
    }
};

const IdRangeBufferReadResult = struct {
    const Self = @This();
    _allocator: std.mem.Allocator = undefined,

    lastReadIndex: u32 = 0,
    firstIdFromBuffer: std.ArrayList(u8),
    finalIdFromBuffer: std.ArrayList(u8),

    fn init(allocator: std.mem.Allocator, initialIndex: u32) IdRangeBufferReadResult {
        return .{ ._allocator = allocator, .lastReadIndex = initialIndex, .firstIdFromBuffer = .empty, .finalIdFromBuffer = .empty };
    }

    fn appendToFirstId(self: *Self, char: u8) !void {
        try self.firstIdFromBuffer.append(self._allocator, char);
    }

    fn appendToFinalId(self: *Self, char: u8) !void {
        try self.finalIdFromBuffer.append(self._allocator, char);
    }
};

pub fn getValidityAssessedIdRangesFromBuffer(allocator: std.mem.Allocator, buffer: []const u8) !std.ArrayList(IdGroup) {
    const idRanges = try getRanges(allocator, buffer);
    return try getInvalidIdsForRanges(allocator, idRanges);
}

pub fn getSumOfInvalidInRangePartOne(idRanges: []IdGroup) u128 {
    var totalSum: u128 = 0;
    for (idRanges) |range| {
        totalSum += range.sumOfInvalidPartOne();
    }

    return totalSum;
}

pub fn getSumOfInvalidInRangePartTwo(idRanges: []IdGroup) u128 {
    var totalSum: u128 = 0;
    for (idRanges) |range| {
        totalSum += range.sumOfInvalidPartOne();
    }

    return totalSum;
}

fn getInvalidIdsForRanges(allocator: std.mem.Allocator, idRanges: []IdRange) !std.ArrayList(IdGroup) {
    var allIdGroups: std.ArrayList(IdGroup) = .empty;

    for (idRanges) |idRange| {
        const invalidIds = try getInvalidIdsForRange(allocator, idRange);
        const idGroup: IdGroup = .{ .examinedRange = idRange, .invalidIdsPartOne = invalidIds, .invalidIdsPartTwo = undefined };
        try allIdGroups.append(allocator, idGroup);
    }
    return allIdGroups;
}

fn getInvalidIdsForRange(allocator: std.mem.Allocator, idRange: IdRange) ![]u64 {
    var invalidIds: std.ArrayList(u64) = .empty;
    for (idRange.start..idRange.end) |id| {
        const stringRepresentation: []u8 = try std.fmt.allocPrint(allocator, "{d}", .{id});
        if (isRepeatedSequenceOfDigits(stringRepresentation)) {
            try invalidIds.append(allocator, id);
        }
    }

    // The range specified above is inclusive lower, exclusive upper.
    const stringRepresentation: []u8 = try std.fmt.allocPrint(allocator, "{d}", .{idRange.end});
    if (isRepeatedSequenceOfDigits(stringRepresentation)) {
        try invalidIds.append(allocator, idRange.end);
    }

    return invalidIds.items;
}

fn getNextRangeFromBuffer(allocator: std.mem.Allocator, index: u32, buffer: []const u8) !IdRangeBufferReadResult {
    var result = IdRangeBufferReadResult.init(allocator, index);

    var haveEncounteredSeprator: bool = false;

    while (result.lastReadIndex < buffer.len) {
        // Only in the final case should we ever get to the buffer.len, however we avoid risking out of bounds.

        if (buffer[result.lastReadIndex] == ',') {
            return result;
        }

        if (buffer[result.lastReadIndex] == '-') {
            haveEncounteredSeprator = true;
        } else if (haveEncounteredSeprator) {
            try result.appendToFinalId(buffer[result.lastReadIndex]);
        } else {
            try result.appendToFirstId(buffer[result.lastReadIndex]);
        }

        result.lastReadIndex += 1;
    }

    return result;
}

fn printParseResult(allocator: std.mem.Allocator, id: u64, stringRepresenration: []u8) !void {
    const displayable = try getScaledDisplayNumericalRepresentation(allocator, stringRepresenration);

    std.debug.print("u64: {any}, []u8: {any} \n", .{ id, displayable });
}

fn printReadResult(result: IdRangeBufferReadResult) !void {
    const fromNumber: std.ArrayList(u8) = try getScaledDisplayNumericalRepresentation(result._allocator, result.firstIdFromBuffer.items);
    const toNumber: std.ArrayList(u8) = try getScaledDisplayNumericalRepresentation(result._allocator, result.finalIdFromBuffer.items);

    std.debug.print("read status: last read index {any} from {any} to {any} \n", .{ result.lastReadIndex, fromNumber, toNumber });
}

fn getScaledDisplayNumericalRepresentation(allocator: std.mem.Allocator, bytes: []u8) !std.ArrayList(u8) {
    var displayRepresentation: std.ArrayList(u8) = .empty;

    for (bytes) |char| {
        try displayRepresentation.append(allocator, char - 48);
    }

    return displayRepresentation;
}

fn parseRange(bufferReadResult: IdRangeBufferReadResult) !IdRange {
    const fromId = try std.fmt.parseUnsigned(u64, bufferReadResult.firstIdFromBuffer.items, 10);
    const toId = try std.fmt.parseUnsigned(u64, bufferReadResult.finalIdFromBuffer.items, 10);
    return .{ .start = fromId, .end = toId };
}

fn getRanges(allocator: std.mem.Allocator, buffer: []const u8) ![]IdRange {
    var idRanges: std.ArrayList(IdRange) = .empty;
    var index: u32 = 0;

    while (index < buffer.len) {
        const nextRangeFromBuffer = try getNextRangeFromBuffer(allocator, index, buffer);
        const nextIdRange = try parseRange(nextRangeFromBuffer);
        try idRanges.append(allocator, nextIdRange);

        index = nextRangeFromBuffer.lastReadIndex + 1;
    }

    return idRanges.items;
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

test "Part 1 snapshot test" {
    const expected: u128 = 1227775554;
    const input: []const u8 = "1-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862";

    var arenaInstance: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaInstance.deinit();
    const arenaAllocator = arenaInstance.allocator();

    const groups = try getValidityAssessedIdRangesFromBuffer(arenaAllocator, input);
    const result = getSumOfInvalidInRangePartOne(groups.items);

    try std.testing.expectEqual(expected, result);
}

test "Part 2 snapshot test" {
    const expected: u128 = 4174379265;
    const input: []const u8 = "1-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

    var arenaInstance: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaInstance.deinit();
    const arenaAllocator = arenaInstance.allocator();

    const groups = try getValidityAssessedIdRangesFromBuffer(arenaAllocator, input);
    const result = getSumOfInvalidInRangePartTwo(groups.items);

    try std.testing.expectEqual(expected, result);
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

test "sample input from prompty 95-115 - invalid" {
    try std.testing.expectEqual(true, isRepeatedSequenceOfDigits("99"));
}
