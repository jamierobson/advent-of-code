const std = @import("std");
const types = @import("types.zig");
const part1 = @import("Part1.zig");
const part2 = @import("Part2.zig");

pub fn getValidityAssessedIdRangesFromBuffer(allocator: std.mem.Allocator, buffer: []const u8) !std.ArrayList(types.IdGroup) {
    const idRanges = try getRanges(allocator, buffer);
    return try getInvalidIdsForRanges(allocator, idRanges);
}

pub fn getRanges(allocator: std.mem.Allocator, buffer: []const u8) ![]types.IdRange {
    var idRanges: std.ArrayList(types.IdRange) = .empty;
    var index: u32 = 0;

    while (index < buffer.len) {
        const nextRangeFromBuffer = try getNextRangeFromBuffer(allocator, index, buffer);
        const nextIdRange = try parseRange(nextRangeFromBuffer);
        try idRanges.append(allocator, nextIdRange);

        index = nextRangeFromBuffer.lastReadIndex + 1;
    }

    return idRanges.items;
}

fn getInvalidIdsForRanges(allocator: std.mem.Allocator, idRanges: []types.IdRange) !std.ArrayList(types.IdGroup) {
    var allIdGroups: std.ArrayList(types.IdGroup) = .empty;

    for (idRanges) |idRange| {
        const idGroup = try setInvalidIds(allocator, idRange);
        try allIdGroups.append(allocator, idGroup);
    }
    return allIdGroups;
}

fn setInvalidIds(allocator: std.mem.Allocator, idRange: types.IdRange) !types.IdGroup { // todo: This shoud be in the parts
    var idGroup: types.IdGroup = .init(allocator, idRange);

    for (idGroup.range.start..idGroup.range.end) |id| {
        const stringRepresentation: []u8 = try std.fmt.allocPrint(allocator, "{d}", .{id});
        if (part1.isRepeatedSequenceOfDigits(stringRepresentation)) {
            try idGroup.appendInvalidPartOne(id);
            try idGroup.appendInvalidPartTwo(id);
            // try part1.appendInvalidId(idGroup, id);
            // try part2.appendInvalidId(idGroup, id);
        } else if (try part2.isRepeatedSequenceOfDigits(allocator, stringRepresentation)) {
            try idGroup.appendInvalidPartTwo(id);
        }
    }
    // The range specified above is inclusive lower, exclusive upper.
    const stringRepresentation: []u8 = try std.fmt.allocPrint(allocator, "{d}", .{idGroup.range.end});
    if (part1.isRepeatedSequenceOfDigits(stringRepresentation)) {
        try idGroup.appendInvalidPartOne(idGroup.range.end);
        try idGroup.appendInvalidPartTwo(idGroup.range.end);
        // try part1.appendInvalidId(idGroup, idGroup.range.end);
        // try part2.appendInvalidId(idGroup, idGroup.range.end);
    } else if (try part2.isRepeatedSequenceOfDigits(allocator, stringRepresentation)) {
        try idGroup.appendInvalidPartTwo(idGroup.range.end);
    }

    return idGroup;
}

fn getNextRangeFromBuffer(allocator: std.mem.Allocator, index: u32, buffer: []const u8) !types.IdRangeBufferReadResult {
    var result = types.IdRangeBufferReadResult.init(allocator, index);

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

fn printReadResult(result: types.IdRangeBufferReadResult) !void {
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

fn parseRange(bufferReadResult: types.IdRangeBufferReadResult) !types.IdRange {
    const fromId = try std.fmt.parseUnsigned(u64, bufferReadResult.firstIdFromBuffer.items, 10);
    const toId = try std.fmt.parseUnsigned(u64, bufferReadResult.finalIdFromBuffer.items, 10);
    return .{ .start = fromId, .end = toId };
}
