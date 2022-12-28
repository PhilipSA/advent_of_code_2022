import 'package:test/test.dart';

void main() {
  List<int> findCommonSequentialPattern(List<int> list) {
    final pattern = <int>[];
    for (var i = 0; i < list.length; i++) {
      final current = list[i];
      if (pattern.contains(current)) {
        continue;
      }
      for (var j = i + 1; j < list.length; j++) {
        final next = list[j];
        if (current + 1 == next) {
          pattern.add(current);
          var patternRepeated = true;
          for (var k = j + 1; k < list.length; k++) {
            final next = list[k];
            if (next != current) {
              patternRepeated = false;
              break;
            }
          }
          if (!patternRepeated) {
            break;
          }
        }
      }
    }
    return pattern;
  }

  test('validate right answers', () {
    print(findCommonSequentialPattern([1, 2, 3, 1, 2, 3, 4, 5, 6, 6, 7, 1, 2, 3, 4, 5, 6, 5, 7, 1, 2, 3]));
  });
}
