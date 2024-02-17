import 'dart:math';

import 'package:flame/game.dart';

extension PointExt on Point<int> {
  Vector2 toVector2() {
    return Vector2(x.toDouble(), y.toDouble());
  }
}
