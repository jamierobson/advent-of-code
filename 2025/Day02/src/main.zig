const std = @import("std");
const module = @import("./root.zig");

pub fn main() !void {
    const idFile = @embedFile("ids.txt");

    var general_purpose_allocator: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const gpa = general_purpose_allocator.allocator();

    const result = try module.calculateSumOfInvalidIdsInRanges(gpa, idFile);
    // defer result.deinit(gpa); // todo: I'm sure that we should be deiniting this but I'm struggling with a compilation error
    var totalSum: u32 = 0;
    for (result.items) |range| {
        totalSum += range.sumOfInvalid;
    }
    std.debug.print("Total range: {any}", .{totalSum});
}
