//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try stdout.flush(); // Don't forget to flush!
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn getLargestJoltageFrom(input: []const u8) u8 {
    // First Take each character, parse to its digit.
    // For each, compare the rest.

    // If next is the last, then move on to second pass
    // If none are bigger, move on to second pass
    // Otherwise - next is

    // Second pass:
    // Pick the largest number from what's left: chosen digits index onwards.
    _ = input;
    return 0;
}

pub fn getTotalOutputJoltageFrom(input: []const u8) u8 {
    _ = input;
    return 0;
}

test "snapshot 987654321111111" {
    const input = "987654321111111";
    const expected = 98;

    const result = getLargestJoltageFrom(input);

    try std.testing.expectEqual(expected, result);
}

test "snapshot 811111111111119" {
    const input = "811111111111119";
    const expected = 89;

    const result = getLargestJoltageFrom(input);

    try std.testing.expectEqual(expected, result);
}

test "snapshot 234234234234278" {
    const input = "234234234234278";
    const expected = 78;

    const result = getLargestJoltageFrom(input);

    try std.testing.expectEqual(expected, result);
}

test "snapshot 818181911112111" {
    const input = "818181911112111";
    const expected = 92;

    const result = getLargestJoltageFrom(input);

    try std.testing.expectEqual(expected, result);
}

test "snapshot total joltage" {
    const input = "987654321111111\n811111111111119\n234234234234278\n818181911112111";
    const expected = 357;

    const result = getTotalOutputJoltageFrom(input);

    try std.testing.expectEqual(expected, result);
}
