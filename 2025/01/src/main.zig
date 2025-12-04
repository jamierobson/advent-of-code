const std = @import("std");
// https://ziglang.org/documentation/master/#embedFile
// This function returns a compile time constant pointer to null-terminated,
// fixed-size array with length equal to the byte count of the file given by path.
// The contents of the array are the contents of the file.
// This is equivalent to a string literal with the file contents.

pub fn main() !void {
    // todo: 6438 is too high. Work out why.
    const instructionsFile: *const [17053:0]u8 = @embedFile("instructions.txt");
    const result = try inputDialOperations(50, instructionsFile);
    std.debug.print("Times dial ended up at 0: {}. Times dial crossed 0: {}. Applied {} instructions \n", .{ result.timesDialEqualsZero, result.timesDialCrossedZero, result.operationsApplied });
}

const Results = struct { timesDialEqualsZero: u32, timesDialCrossedZero: u32, operationsApplied: u32, dial: i32 };
const RotationMod100 = struct { result: i32, timesCrossedZero: u32 };

fn inputDialOperations(initialDial: i32, buffer: []const u8) !Results {
    var dial = initialDial;
    var index: u32 = 0;
    var operationIndex: u32 = 0;
    var operationRead: bool = false;
    var timesDialWasEqualToZero: u32 = 0;
    var timesDialCrossedZero: u32 = 0;
    var numberOfAppliedOperations: u32 = 0;

    while (index < buffer.len) {
        if (buffer[index] == '\n' or index == buffer.len - 1) {
            const operation = getOperationFromCharacter(buffer[operationIndex]);
            const rotationSlice = buffer[operationIndex + 1 .. index];
            const rotation = try std.fmt.parseInt(i32, rotationSlice, 10);
            const rotationMod100 = operation(dial, rotation);
            dial = rotationMod100.result;
            operationRead = false;
            numberOfAppliedOperations += 1;
            if (dial == 0) {
                timesDialWasEqualToZero += 1;
            }
            timesDialCrossedZero += rotationMod100.timesCrossedZero;
        } else if (!operationRead) {
            operationIndex = index;
            operationRead = true;
        }
        index += 1;
    }

    return .{ .timesDialEqualsZero = timesDialWasEqualToZero, .timesDialCrossedZero = timesDialCrossedZero, .operationsApplied = numberOfAppliedOperations, .dial = dial };
}

fn getOperationFromCharacter(character: u8) *const fn (i32, i32) RotationMod100 {
    return switch (character) {
        'r', 'R' => addMod100,
        'l', 'L' => subtractMod100,
        else => noop,
    };
}

fn addMod100(a: i32, b: i32) RotationMod100 {
    var result = a + b;
    var timesCrossedZero: u32 = 0;
    while (result > 99) {
        result -= 100;
        timesCrossedZero += 1;
    }

    return .{ .result = result, .timesCrossedZero = timesCrossedZero };
}

fn subtractMod100(a: i32, b: i32) RotationMod100 {
    var result = a - b;
    var timesCrossedZero: u32 = 0;
    while (result < 0) {
        result += 100;
        timesCrossedZero += 1;
    }

    if (result == 0) {
        timesCrossedZero += 1;
    }

    return .{ .result = result, .timesCrossedZero = timesCrossedZero };
}

fn noop(a: i32, b: i32) RotationMod100 {
    _ = b;
    return .{ .result = a, .timesCrossedZero = 0 };
}

test "Part 1 snapshot test" {
    const initialDial: i32 = 50;
    const expectedTimesDialEqualsZero: u32 = 3;
    const expectedDial: i32 = 32;
    const input: []const u8 = "L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82\n";

    const result = try inputDialOperations(initialDial, input);

    try std.testing.expectEqual(expectedDial, result.dial);
    try std.testing.expectEqual(expectedTimesDialEqualsZero, result.timesDialEqualsZero);
}

test "Part 2 snapshot test" {
    const initialDial: i32 = 50;
    const expectedTimesDialCrossedZero: u32 = 6;
    const expectedDial: i32 = 32;
    const input: []const u8 = "L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82\n";

    const result = try inputDialOperations(initialDial, input);

    try std.testing.expectEqual(expectedDial, result.dial);
    try std.testing.expectEqual(expectedTimesDialCrossedZero, result.timesDialCrossedZero);
}

test "Synthesized snapshot test covering extreme fluctuation around 0" {
    const initialDial: i32 = 1;
    const expectedTimesDialCrossedZero: u32 = 42;
    const expectedDial: i32 = 0;
    // Count                   0   -1  1   0     -1  0       -1    0      1     1     0
    // Crosses                 1    1  0    2    0    11      11    2    11     1     1
    const input: []const u8 = "L1\nL1\nR2\nL101\nL1\nR1001\nL1001\nL199\nR1001\nR100\nL1\n";
    const result = try inputDialOperations(initialDial, input);

    try std.testing.expectEqual(expectedDial, result.dial);
    try std.testing.expectEqual(expectedTimesDialCrossedZero, result.timesDialCrossedZero);
} // todo: Then why is my answer of 6438 incorrect?!

test "add overflows dial from 99 to 0" {
    const expected: i32 = 0;
    const result = addMod100(99, 1);

    try std.testing.expectEqual(expected, result.result);
}

test "add includes times crossing zero" {
    const expected: u32 = 2;
    const result = addMod100(99, 101);

    try std.testing.expectEqual(expected, result.timesCrossedZero);
}

test "add ending on zero increments times crossing" {
    const expected = 1;
    const result = addMod100(99, 1);

    try std.testing.expectEqual(expected, result.timesCrossedZero);
}

test "subtract ending on zero increments times crossing" {
    const expected: u32 = 1;
    const result = subtractMod100(1, 1);

    try std.testing.expectEqual(expected, result.timesCrossedZero);
}

test "subtract includes times crossing zero" {
    const expected: u32 = 2;
    const result = subtractMod100(1, 101);

    try std.testing.expectEqual(expected, result.timesCrossedZero);
}

test "subtract underflows dial from 0 to 99" {
    const expected: i32 = 99;
    const result = subtractMod100(0, 1);

    try std.testing.expectEqual(expected, result.result);
}

test "add overflows from 99 to 0 when adding value larger than 100" {
    const expected: i32 = 1;
    const result = addMod100(99, 102);

    try std.testing.expectEqual(expected, result.result);
}

test "subtracting large number correctly returns between 0 and 99" {
    const expected: i32 = 99;
    const result = subtractMod100(50, 1051);

    try std.testing.expectEqual(expected, result.result);
}

test "noop does nothing" {
    const expected: i32 = 0;
    const result = noop(expected, 1);

    try std.testing.expectEqual(expected, result.result);
}
