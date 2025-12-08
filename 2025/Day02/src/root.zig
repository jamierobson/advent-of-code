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

const Id = struct {
  stringRepresentation: []u8,
  value: u64
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

fn getInvalidIdsForRanges(allocator: std.mem.Allocator, idRanges: []IdRange) !std.ArrayList(IdGroup) {
    var allIdGroups: std.ArrayList(IdGroup) = .empty;

    for (idRanges) |idRange| {
        const invalidIds = try getInvalidIdsForRange(allocator, idRange);
        const idGroup: IdGroup = .{ .examinedRange = idRange, .invalidIds = invalidIds.items };
        try allIdGroups.append(allocator, idGroup);
    }
    return allIdGroups;
}

fn getInvalidIdsForRange(allocator: std.mem.Allocator, idRange: IdRange) ![]u64 {
    var invalidIds: std.ArrayList(u64) = .empty;
    for (idRange.start..idRange.end) |id: u64| {
        if (!isValid(id)) {
            invalidIds.append(allocator, id);
        }
    }

    if (!isValid(idRange.end)) {
        invalidIds.append(allocator, idRange.end);
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

fn printReadResult(result: IdRangeBufferReadResult) !void {
    var fromNumber: std.ArrayList(u8) = .empty;
    var toNumber: std.ArrayList(u8) = .empty;

    for (result.firstIdFromBuffer.items) |char| {
        try fromNumber.append(result._allocator, char - 48);
    }

    for (result.finalIdFromBuffer.items) |char| {
        try toNumber.append(result._allocator, char - 48);
    }

    std.debug.print("read status: last read index {any} from {any} to {any} \n", .{ result.lastReadIndex, fromNumber, toNumber });
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
        try printReadResult(nextRangeFromBuffer);
        const nextIdRange = try parseRange(nextRangeFromBuffer);
        try idRanges.append(allocator, nextIdRange);

        index = nextRangeFromBuffer.lastReadIndex + 1;
    }

    return idRanges.items;
}

// fn isValid(stringRepresentationOfNumber: []const u8) bool {
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
