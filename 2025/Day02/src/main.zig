const std = @import("std");
const module = @import("./root.zig");

pub fn main() !void {
    const idFile = @embedFile("ids.txt");

    var gpaInstance: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = gpaInstance.allocator();
    var arenaInstance = std.heap.ArenaAllocator.init(gpa);
    defer arenaInstance.deinit();
    const arenaAllocator = arenaInstance.allocator();

    const result = try module.getValidityAssessedIdRangesFromBuffer(arenaAllocator, idFile);
    const totalSum = module.getSumOfInvalidInRangePartOne(result.items);
    std.debug.print("Total range: {any}", .{totalSum});
}
