abstract class IResultReporter {
  void start();
  void reportResult(int day, dynamic part1, dynamic part2);
}


class ResultReporter implements IResultReporter {
  var stopwatch = Stopwatch();

  @override
  void start() {
    stopwatch = Stopwatch();
    stopwatch.start();
  }

  @override
  void reportResult(int day, dynamic part1, dynamic part2) {
    stopwatch.stop();
    print('Day $day part 1: $part1 part 2: $part2 executed in ${stopwatch.elapsedMilliseconds} MS');
  }
}