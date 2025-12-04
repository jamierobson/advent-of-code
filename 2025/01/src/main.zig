const std = @import("std");
// https://ziglang.org/documentation/master/#embedFile
// This function returns a compile time constant pointer to null-terminated,
// fixed-size array with length equal to the byte count of the file given by path.
// The contents of the array are the contents of the file.
// This is equivalent to a string literal with the file contents.

pub fn main() !void {
    const instructionsFile: *const [17053:0]u8 = @embedFile("instructions.txt");
    const result = try inputDialOperations(50, instructionsFile);
    std.debug.print("Times dial ended up at 0: {}. Times dial crossed 0: {}. Instructions that caused us to cross or land on 0: {} Applied {} instructions \n", .{ result.timesDialEqualsZero, result.totalTimesDialCrossedZero, result.instructionsThatCausedDialToCrossZeroOneOrMoreTimes, result.operationsApplied });
}

const Results = struct { timesDialEqualsZero: u32, totalTimesDialCrossedZero: u32, instructionsThatCausedDialToCrossZeroOneOrMoreTimes: u32, operationsApplied: u32, dial: u32 };
const RotationMod100 = struct { newDial: u32, didCrossOrEndOnZero: bool, timesCrossedZero: u32 };

fn inputDialOperations(initialDial: u32, buffer: []const u8) !Results {
    var dial = initialDial;
    var index: u32 = 0;
    var operationIndex: u32 = 0;
    var operationRead: bool = false;
    var timesDialEqualsZero: u32 = 0;
    var totalTimesDialCrossedZero: u32 = 0;
    var numberOfAppliedOperations: u32 = 0;
    var numberOfInstructionsThatCausedDialToCrossZeroOneOrMoreTimes: u32 = 0;

    while (index < buffer.len) {
        if (buffer[index] == '\n' or index == buffer.len - 1) {
            const operation = getOperationFromCharacter(buffer[operationIndex]);
            const rotationSlice = buffer[operationIndex + 1 .. index];
            const rotation = try std.fmt.parseInt(u32, rotationSlice, 10);
            const rotationMod100 = operation(dial, rotation);
            dial = rotationMod100.newDial;
            operationRead = false;
            numberOfAppliedOperations += 1;
            if (dial == 0) {
                timesDialEqualsZero += 1;
            }
            if (rotationMod100.timesCrossedZero > 0) {
                numberOfInstructionsThatCausedDialToCrossZeroOneOrMoreTimes += 1;
            }
            totalTimesDialCrossedZero += rotationMod100.timesCrossedZero;
        } else if (!operationRead) {
            operationIndex = index;
            operationRead = true;
        }
        index += 1;
    }

    return .{ .timesDialEqualsZero = timesDialEqualsZero, .totalTimesDialCrossedZero = totalTimesDialCrossedZero, .instructionsThatCausedDialToCrossZeroOneOrMoreTimes = numberOfInstructionsThatCausedDialToCrossZeroOneOrMoreTimes, .operationsApplied = numberOfAppliedOperations, .dial = dial };
}

fn getOperationFromCharacter(character: u8) *const fn (u32, u32) RotationMod100 {
    return switch (character) {
        'r', 'R' => addMod100,
        'l', 'L' => subtractMod100,
        else => noop,
    };
}

fn addMod100(a: u32, b: u32) RotationMod100 {
    const addResult = a + b;
    const newDial: u32 = @rem(addResult, 100);
    const timesCrossedZero: u32 = if (addResult == 0) 1 else addResult / 100;
    const didCrossZero = timesCrossedZero > 0;

    std.debug.print("\n A(dial):{any}, B(rotation):{any}, EndDial:{any}, Crossed:{any}, a+b:{any}\n", .{
        a,
        b,
        newDial,
        timesCrossedZero,
        addResult,
    });

    return .{ .newDial = newDial, .timesCrossedZero = timesCrossedZero, .didCrossOrEndOnZero = didCrossZero };
}

fn subtractMod100(a: u32, b: u32) RotationMod100 {
    var timesCrossedZero = b / 100;
    const bDividedBy100Remainder = @rem(b, 100);
    const subtractionWouldBeNegative = bDividedBy100Remainder > a;
    const newDial = if (subtractionWouldBeNegative) 100 + a - bDividedBy100Remainder else a - bDividedBy100Remainder;

    if (subtractionWouldBeNegative) {
        timesCrossedZero += 1;
    }

    if (newDial == 0) {
        timesCrossedZero += 1;
    }

    // Such a gnarly hack
    if (a == 0) {
        timesCrossedZero -= 1;
    }

    const didCrossZero = (timesCrossedZero > 0);
    std.debug.print("\n A(dial):{any}, B(rotation):{any}, b%100(rotation):{any}, EndDial:{any}, Crossed:{any}, \n", .{ a, b, bDividedBy100Remainder, newDial, timesCrossedZero });

    return .{ .newDial = newDial, .timesCrossedZero = timesCrossedZero, .didCrossOrEndOnZero = didCrossZero };
}

fn noop(a: u32, b: u32) RotationMod100 {
    _ = b;
    return .{ .newDial = a, .timesCrossedZero = 0, .didCrossOrEndOnZero = false };
}

test "subtraction from 0 should not register crossing dial" {
    const expectedTimesCrossed = 0;

    const result = subtractMod100(0, 5);

    try std.testing.expectEqual(expectedTimesCrossed, result.timesCrossedZero);
}

test "addition from 0 should not register crossing dial" {
    const expectedTimesCrossed = 0;

    const result = addMod100(0, 5);

    try std.testing.expectEqual(expectedTimesCrossed, result.timesCrossedZero);
}

test "Part 1 snapshot test" {
    const initialDial: u32 = 50;
    const expectedTimesDialEqualsZero: u32 = 3;
    const expectedDial: u32 = 32;
    const input: []const u8 = "L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82\n";

    const result = try inputDialOperations(initialDial, input);

    try std.testing.expectEqual(expectedDial, result.dial);
    try std.testing.expectEqual(expectedTimesDialEqualsZero, result.timesDialEqualsZero);
}

test "Part 2 snapshot test" {
    const initialDial: u32 = 50;
    const expectedTimesDialCrossedZero: u32 = 6;
    const expectedDial: u32 = 32;
    const input: []const u8 = "L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82\n";

    const result = try inputDialOperations(initialDial, input);

    try std.testing.expectEqual(expectedDial, result.dial);
    try std.testing.expectEqual(expectedTimesDialCrossedZero, result.totalTimesDialCrossedZero);
}

test "Synthesized snapshot test covering extreme fluctuation around 0" {
    const initialDial: u32 = 1;
    const expectedTimesDialCrossedZero: u32 = 39;
    const expectedDial: u32 = 0;
    // Count                   0   -1  1   0     -1  0       -1    0      1     1     0
    // Crosses                 1    0  1   2    0    11      10    2     10     1     1
    const input: []const u8 = "L1\nL1\nR2\nL101\nL1\nR1001\nL1001\nL199\nR1001\nR100\nL1\n";
    const result = try inputDialOperations(initialDial, input);

    try std.testing.expectEqual(expectedDial, result.dial);
    try std.testing.expectEqual(expectedTimesDialCrossedZero, result.totalTimesDialCrossedZero);
}

test "add overflows dial from 99 to 0" {
    const expected: u32 = 0;
    const result = addMod100(99, 1);

    try std.testing.expectEqual(expected, result.newDial);
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
    const expected: u32 = 99;
    const result = subtractMod100(0, 1);

    try std.testing.expectEqual(expected, result.newDial);
}

test "add overflows from 99 to 0 when adding value larger than 100" {
    const expected: u32 = 1;
    const result = addMod100(99, 102);

    try std.testing.expectEqual(expected, result.newDial);
}

test "subtracting large number correctly returns between 0 and 99" {
    const expected: u32 = 99;
    const result = subtractMod100(50, 1051);

    try std.testing.expectEqual(expected, result.newDial);
}

test "noop does nothing" {
    const expected: u32 = 0;
    const result = noop(expected, 1);

    try std.testing.expectEqual(expected, result.newDial);
}
