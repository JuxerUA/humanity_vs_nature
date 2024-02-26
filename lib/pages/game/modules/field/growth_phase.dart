import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

enum GrowthPhase {
  ground(1),
  seeds(1),
  young(1),
  medium(1),
  mature(1);

  const GrowthPhase(this.requiredGas);

  final double requiredGas;

  Color getColor() {
    switch (this) {
      case GrowthPhase.ground:
        return Colors.brown;
      case GrowthPhase.seeds:
        return Colors.green;
      case GrowthPhase.young:
        return Colors.lightGreenAccent;
      case GrowthPhase.medium:
        return [
          Colors.lime,
          Colors.limeAccent,
          Colors.yellowAccent,
          Colors.yellow
        ].random();
      case GrowthPhase.mature:
        return [
          Colors.amberAccent,
          Colors.amber,
          Colors.orangeAccent,
          Colors.orange
        ].random();
    }
  }
}
