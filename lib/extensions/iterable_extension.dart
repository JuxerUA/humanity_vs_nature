import 'package:flame/extensions.dart';
import 'package:humanity_vs_nature/pages/game/models/dot.dart';

extension IterableExtension<E> on Iterable<E> {
  E? firstOrNullWhere(bool Function(E element) predicate) {
    for (final element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }
}

extension Field on List<Dot> {
  List<Dot> randomize() {
    final randomizedList = <Dot>[];
    final count = length;
    for (var i = 0; i < count; i++) {
      final randomItem = random();
      randomizedList.add(randomItem);
      remove(randomItem);
    }
    addAll(randomizedList);
    return randomizedList;
  }

  bool thisAreaContainsDot(Dot dot) {
    final vertexCount = length;
    if (vertexCount < 3) return false;

    bool isPointInTriangle(Dot p, Dot a, Dot b, Dot c) {
      final b1 = ((p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y)) <= 0.0;
      final b2 = ((p.x - c.x) * (b.y - c.y) - (b.x - c.x) * (p.y - c.y)) <= 0.0;
      final b3 = ((p.x - a.x) * (c.y - a.y) - (c.x - a.x) * (p.y - a.y)) <= 0.0;

      return (b1 == b2) && (b2 == b3);
    }

    bool isPointInsideConvexQuadrilateral(
        Dot p, Dot p1, Dot p2, Dot p3, Dot p4) {
      return isPointInTriangle(p, p1, p2, p3) ||
          isPointInTriangle(p, p1, p3, p4);
    }

    final p1 = this[0];
    final p2 = this[1];
    final p3 = this[2];

    final p = dot;

    if (vertexCount == 3) {
      return isPointInTriangle(p, p1, p2, p3);
    } else if (vertexCount == 4) {
      final p4 = this[3];
      return isPointInsideConvexQuadrilateral(p, p1, p2, p3, p4);
    }

    return false;
  }
}