const std = @import("std");
const module = @import("./root.zig");
const part1 = @import("./Part1.zig");
const part2 = @import("./Part2.zig");

pub fn main() !void {
    const idFile = @embedFile("ids.txt");

    var gpaInstance: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = gpaInstance.allocator();
    var arenaInstance = std.heap.ArenaAllocator.init(gpa);
    defer arenaInstance.deinit();
    const arenaAllocator = arenaInstance.allocator();

    const result = try module.getValidityAssessedIdRangesFromBuffer(arenaAllocator, idFile);
    const part1Sum = part1.getSumOfInvalidInRanges(result.items);
    const part2Sum = part2.getSumOfInvalidInRanges(result.items);
    std.debug.print("Total range: Part 1 = {any}, Part 2 = {any}", .{ part1Sum, part2Sum });
}

test "Part 1 snapshot test" {
    const expected: u128 = 1227775554;
    const input: []const u8 = "1-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862";

    var arenaInstance: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaInstance.deinit();
    const arenaAllocator = arenaInstance.allocator();

    const groups = try module.getValidityAssessedIdRangesFromBuffer(arenaAllocator, input);
    const result = part1.getSumOfInvalidInRanges(groups.items);

    try std.testing.expectEqual(expected, result);
}

test "Part 2 snapshot test" {
    const expected: u128 = 4174379265;
    const input: []const u8 = "1-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

    var arenaInstance: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arenaInstance.deinit();
    const arenaAllocator = arenaInstance.allocator();

    const groups = try module.getValidityAssessedIdRangesFromBuffer(arenaAllocator, input);
    const result = part2.getSumOfInvalidInRanges(groups.items);

    try std.testing.expectEqual(expected, result);
}
