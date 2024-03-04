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

  @override
  void update(double dt) {
    super.update(dt);

    if ((target.position - position).length2 < 25) {
      game.foodModule.remove(this);
      return;
    }

    final center =
        vertices.reduce((prev, e) => prev + e) / vertices.length.toDouble();

    for (final vertex in vertices) {
      final diffToTarget = target.position - (vertex + position);
      final diffToCenter = center - vertex;
      vertex
        ..addScaled(diffToTarget, dt * 0.5)
        ..addScaled(diffToCenter, 0.4);
    }

    position = position + vertices.first;
  }
}
