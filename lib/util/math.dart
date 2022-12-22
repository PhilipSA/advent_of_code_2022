class IntRange {
  final int lowest;
  final int highest;

  IntRange(this.lowest, this.highest);

  bool isWithinRange(IntRange otherRange) {
    return (lowest <= otherRange.lowest && highest >= otherRange.highest) || (otherRange.lowest <= lowest && otherRange.highest >= highest);
  }

  bool doesRangeOverlap(IntRange otherRange) {
    return (highest >= otherRange.lowest && lowest <= otherRange.highest) || (lowest >= otherRange.highest && highest <= otherRange.highest);
  }

  factory IntRange.createFromRangeString(String input) {
    final split = input.split('-');
    return IntRange(int.parse(split[0]), int.parse(split[1]));
  }
}

int manhattanDistance(int x1, int y1, int x2, int y2) {
  return (x1 - x2).abs() + (y1 - y2).abs();
}