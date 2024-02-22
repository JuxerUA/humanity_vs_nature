import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FieldComponent extends RectangleComponent
    with HasGameRef<SimulationGame>, TapCallbacks {
  FieldComponent() {
    paint = Paint()
      ..color = _generateRandomFieldColor()
      ..style = PaintingStyle.fill;
  }

  double get area => size.x * size.y;

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.fieldModule.removeField(this);
  }

  Color _generateRandomFieldColor() {
    final colors = [
      Colors.green,
      Colors.green,
      Colors.green,
      Colors.green,
      Colors.lightGreenAccent,
      Colors.lightGreenAccent,
      Colors.lightGreenAccent,
      Colors.lime,
      Colors.lime,
      Colors.limeAccent,
      Colors.yellowAccent,
      Colors.yellow,
      Colors.amberAccent,
      Colors.amber,
      Colors.orangeAccent,
      Colors.orange,
    ];

    return colors.random();
  }
}
