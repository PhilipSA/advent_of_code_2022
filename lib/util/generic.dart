class Pair<T> {
  final T first;
  final T second;

  Pair(this.first, this.second);
}

bool areMapsEqual<K, V>(Map<K, V> map1, Map<K, V> map2) {
  if (map1.length == map2.length) {
    var mapsEqual = true;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) {
        mapsEqual = false;
        break;
      }
    }
    return mapsEqual;
  } else {
    return false;
  }
}
