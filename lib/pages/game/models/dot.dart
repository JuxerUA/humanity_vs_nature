import 'dart:math';

import 'package:flame/game.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class Dot extends Point<int> {
  Dot(super.x, super.y);

  Vector2 get position => Vector2(
        x * SimulationGame.dotSpacing,
        y * SimulationGame.dotSpacing,
      );
}
