import 'dart:math';

class TwoDObject {
  final int x;
  final int y;

  TwoDObject(this.x, this.y);

  double heuristic(TwoDObject otherNode) {
    final newX = (x - otherNode.x).abs();
    final newY = (y - otherNode.y).abs();
    return sqrt(newX * newX + newY * newY);
  }

  bool isNeighbor(TwoDObject otherNode) {
    return (otherNode.x == x - 1 && otherNode.y == y) ||
        (otherNode.x == x + 1 && otherNode.y == y) ||
        (otherNode.x == x && otherNode.y == y + 1) ||
        (otherNode.x == x && otherNode.y == y - 1);
  }

  @override
  bool operator ==(Object other) {
    if (other is TwoDObject) {
      return x == other.x && y == other.y;
    }
    return false;
  }

  @override
  int get hashCode {
    return x.hashCode ^ y.hashCode;
  }
}

abstract class ThreeDObject {
  final int x, y, z;

  ThreeDObject(this.x, this.y, this.z);

  bool isConnected(ThreeDObject otherObject) {
    return ((x - otherObject.x).abs() == 1 &&
            y == otherObject.y &&
            z == otherObject.z) ||
        (x == otherObject.x &&
            (y - otherObject.y).abs() == 1 &&
            z == otherObject.z) ||
        (x == otherObject.x &&
            y == otherObject.y &&
            (z - otherObject.z).abs() == 1);
  }

  double distanceTo(ThreeDObject other) {
    return sqrt(
        pow(other.x - x, 2) + pow(other.y - y, 2) + pow(other.z - z, 2),);
  }

  @override
  bool operator ==(Object other) {
    if (other is ThreeDObject) {
      return x == other.x && y == other.y && z == other.z;
    }
    return false;
  }

  @override
  int get hashCode {
    return x.hashCode ^ y.hashCode ^ z.hashCode;
  }
}