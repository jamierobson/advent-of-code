const std = @import("std");
const Day02 = @import("Day02");

pub fn main() !void {
    const idFile: *const [477:0]u8 = @embedFile("ids.txt");

    const isValid = Day02.isValid(idFile);
    std.debug.print("is valid?: {}", isValid);
}
