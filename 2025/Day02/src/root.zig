const std = @import("std");

const IdRange = struct { start: u64, end: u64 };

const IdGroup = struct {
    const Self = @This();
    examinedRange: IdRange,
    invalidIds: []u64,
    pub fn sumOfInvalid(self: Self) u128 {
        var sum: u128 = 0;
        for (self.invalidIds) |id| {
            sum += id;
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

pub fn getInvalidIdsFromBuffer(allocator: std.mem.Allocator, buffer: []const u8) !std.ArrayList(IdGroup) {
    const idRanges = try getRanges(allocator, buffer);
    return try getInvalidIdsForRanges(allocator, idRanges);
}

pub fn getSumOfInvalidInRange(idRanges: []IdGroup) u128 {
    var totalSum: u128 = 0;
    for (idRanges) |range| {
        totalSum += range.sumOfInvalid();
    }

    return totalSum;
}

fn getInvalidIdsForRanges(allocator: std.mem.Allocator, idRanges: []IdRange) !std.ArrayList(IdGroup) {
    var allIdGroups: std.ArrayList(IdGroup) = .empty;

    for (idRanges) |idRange| {
        const invalidIds = try getInvalidIdsForRange(allocator, idRange);
        const idGroup: IdGroup = .{ .examinedRange = idRange, .invalidIds = invalidIds };
        try allIdGroups.append(allocator, idGroup);
    }
    return allIdGroups;
}

fn getInvalidIdsForRange(allocator: std.mem.Allocator, idRange: IdRange) ![]u64 {
    var invalidIds: std.ArrayList(u64) = .empty;
    for (idRange.start..idRange.end) |id| {
        const stringRepresentation: []u8 = try std.fmt.allocPrint(allocator, "{d}", .{id});
        if (!isValid(stringRepresentation)) {
            try invalidIds.append(allocator, id);
        }
    }

    // The range specified above is inclusive lower, exclusive upper.
    const stringRepresentation: []u8 = try std.fmt.allocPrint(allocator, "{d}", .{idRange.end});
    if (!isValid(stringRepresentation)) {
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

fn isValid(stringRepresentationOfNumber: []u8) bool {
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

test "Part 1 snapshot test" {
    const expected: u128 = 1227775554;
    const input: []const u8 = "1-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862";

    var arenaInstance: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaInstance.deinit();
    const arenaAllocator = arenaInstance.allocator();

    const groups = try getInvalidIdsFromBuffer(arenaAllocator, input);
    const result = getSumOfInvalidInRange(groups.items);

    try std.testing.expectEqual(expected, result);
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
