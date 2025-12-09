const types = @import("types.zig");

pub fn getSumOfInvalidInRanges(idGroups: []types.IdGroup) u128 {
    var totalSum: u128 = 0;
    for (idGroups) |group| {
        totalSum += getSumOfInvalidInRange(group);
    }

    return totalSum;
}

fn getSumOfInvalidInRange(idGroup: types.IdGroup) u128 {
    var sum: u128 = 0;
    for (idGroup.invalidIdsPartTwo) |id| {
        sum += id;
    }

    return sum;
}
