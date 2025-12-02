const std = @import("std");
// https://ziglang.org/documentation/master/#embedFile
// This function returns a compile time constant pointer to null-terminated,
// fixed-size array with length equal to the byte count of the file given by path.
// The contents of the array are the contents of the file.
// This is equivalent to a string literal with the file contents.
const instructionsFile: *const [17053:0]u8 = @embedFile("instructions.txt");

pub fn main() !void {
    var dial: i32 = 50;
    var index: u32 = 0;

    var operationIndex: u32 = 0;
    var operationRead: bool = false;
    var timesDialWasEqualToZero: u32 = 0;
    var numberOfAppliedOperations: u32 = 0;

    while (index <= instructionsFile.len) {
        if (instructionsFile[index] == '\n' or index == instructionsFile.len) {
            const operation = getOperationFromCharacter(instructionsFile[operationIndex]);
            const rotationSlice = instructionsFile[operationIndex + 1 .. index];
            const rotation = try std.fmt.parseInt(i32, rotationSlice, 10);
            dial = operation(dial, rotation);
            operationRead = false;
            numberOfAppliedOperations += 1;
            if (dial == 0) {
                std.debug.print("Incrementing after {} instructions \n", .{numberOfAppliedOperations});
                timesDialWasEqualToZero += 1;
            }
        } else if (!operationRead) {
            operationIndex = index;
            operationRead = true;
        }
        index += 1;
    }

    std.debug.print("Result: {}, after parsing {} instructions \n", .{ timesDialWasEqualToZero, numberOfAppliedOperations });
}

pub fn getOperationFromCharacter(character: u8) *const fn (i32, i32) i32 {
    return switch (character) {
        'r', 'R' => add,
        'l', 'L' => subtract,
        else => noop,
    };
}

pub fn add(a: i32, b: i32) i32 {
    return @rem(a + b, 100);
}

fn subtract(a: i32, b: i32) i32 {
    const subtractionResult = @rem(a - b, 100);
    return if (subtractionResult >= 0) subtractionResult else 100 + subtractionResult;
}

fn noop(a: i32, b: i32) i32 {
    _ = b;
    return a;
}

test "add overflows from 99 to 0" {
    const expected = 0;
    const result = add(99, 1);

    try std.testing.expectEqual(expected, result);
}

test "subtract underflows from 0 to 99" {
    const expected = 99;
    const result = subtract(0, 1);

    try std.testing.expectEqual(expected, result);
}

test "add overflows from 99 to 0 when adding value larger than 100" {
    const expected = 1;
    const result = add(99, 102);

    try std.testing.expectEqual(expected, result);
}

test "subtracting large number correctly returns between 0 and 99" {
    const expected = 99;
    const result = subtract(50, 1051);

    try std.testing.expectEqual(expected, result);
}

test "noop does nothing" {
    const expected = 0;
    const result = noop(expected, 1);

    try std.testing.expectEqual(expected, result);
}
