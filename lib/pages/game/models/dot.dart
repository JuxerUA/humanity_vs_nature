import 'dart:math';

import 'package:flame/game.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class Dot extends Point<int> {
  Dot(super.x, super.y);

  Dot.fromPosition(Vector2 position)
      : super(
          (position.x / SimulationGame.dotSpacing).round(),
          (position.y / SimulationGame.dotSpacing).round(),
        );

  Vector2 get position => Vector2(
        x * SimulationGame.dotSpacing,
        y * SimulationGame.dotSpacing,
      );

  Dot get leftDot => Dot(x - 1, y);

  Dot get rightDot => Dot(x + 1, y);

  Dot get topDot => Dot(x, y - 1);

  Dot get bottomDot => Dot(x, y + 1);
}
