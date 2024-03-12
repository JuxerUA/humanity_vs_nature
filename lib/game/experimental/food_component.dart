import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class FoodComponent extends PolygonComponent with HasGameRef<SimulationGame> {
  FoodComponent(
    this.target,
    Color color,
    super.vertices,
  ) {
    paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  final PositionComponent target;
  double speed = 150;

  @override
  FutureOr<void> onLoad() {
    anchor = Anchor.center;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final direction = target.position - position;
    final length = direction.normalize();
    position += direction * speed * dt;
    speed += dt;
    size *= 0.5;

    if (length < 10) {
      game.foodModule.remove(this);
      return;
    }
  }
}
