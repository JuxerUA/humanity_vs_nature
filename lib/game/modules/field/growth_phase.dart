import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

enum GrowthPhase {
  ground,
  young,
  medium,
  mature;

  Color getColor() {
    switch (this) {
      case GrowthPhase.ground:
        return Colors.brown;
      case GrowthPhase.young:
        return Colors.lightGreenAccent;
      case GrowthPhase.medium:
        return [
          Colors.lime,
          Colors.limeAccent,
          Colors.yellowAccent,
          //Colors.yellow
        ].random();
      case GrowthPhase.mature:
        return [
          //Colors.amberAccent,
          Colors.amber,
          Colors.orangeAccent,
          Colors.orange
        ].random();
    }
  }
}
