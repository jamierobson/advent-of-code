const std = @import("std");

pub const IdRange = struct { start: u64, end: u64 };

pub const IdGroup = struct {
    const Self = @This();

    _allocator: std.mem.Allocator,
    range: IdRange,
    invalidIdsPartOne: std.ArrayList(u64),
    invalidIdsPartTwo: std.ArrayList(u64),

    pub fn init(allocator: std.mem.Allocator, idRange: IdRange) Self {
        return .{ ._allocator = allocator, .range = idRange, .invalidIdsPartOne = .empty, .invalidIdsPartTwo = .empty };
    }
    pub fn appendInvalidPartOne(self: *Self, id: u64) !void {
        try self.invalidIdsPartOne.append(self._allocator, id);
    }
};

pub const IdRangeBufferReadResult = struct {
    const Self = @This();

    _allocator: std.mem.Allocator,
    lastReadIndex: u32,
    firstIdFromBuffer: std.ArrayList(u8),
    finalIdFromBuffer: std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator, initialIndex: u32) IdRangeBufferReadResult {
        return .{ ._allocator = allocator, .lastReadIndex = initialIndex, .firstIdFromBuffer = .empty, .finalIdFromBuffer = .empty };
    }

    pub fn appendToFirstId(self: *Self, char: u8) !void {
        try self.firstIdFromBuffer.append(self._allocator, char);
    }

    pub fn appendToFinalId(self: *Self, char: u8) !void {
        try self.finalIdFromBuffer.append(self._allocator, char);
    }
};
