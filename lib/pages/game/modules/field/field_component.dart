import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/growth_phase.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FieldComponent extends RectangleComponent
    with HasGameRef<SimulationGame>, TapCallbacks {
  FieldComponent({this.canBeDestroyedByTap = true}) {
    paint = Paint()
      ..color = GrowthPhase.ground.getColor()
      ..style = PaintingStyle.fill;
  }

  static const double gasRadius = SimulationGame.blockSize * 3;

  final bool canBeDestroyedByTap;

  double storedGasForGrowth = 0;
  double gasForTheNextPhase = 0;
  GrowthPhase currentGrowthPhase = GrowthPhase.ground;

  double get area => size.x * size.y;

  @override
  void update(double dt) {
    super.update(dt);
    if (storedGasForGrowth < 1) {
      storedGasForGrowth += game.gasModule.aFieldWantsSomeCO2(position, dt);
    } else if (currentGrowthPhase != GrowthPhase.mature) {
      gasForTheNextPhase += dt * 0.1;
      storedGasForGrowth -= dt * 0.1;

      if (gasForTheNextPhase >= currentGrowthPhase.requiredGas) {
        gasForTheNextPhase -= currentGrowthPhase.requiredGas;
        switch (currentGrowthPhase) {
          case GrowthPhase.ground:
            currentGrowthPhase = GrowthPhase.seeds;
          case GrowthPhase.seeds:
            currentGrowthPhase = GrowthPhase.young;
          case GrowthPhase.young:
            currentGrowthPhase = GrowthPhase.medium;
          case GrowthPhase.medium:
            currentGrowthPhase = GrowthPhase.mature;
          case GrowthPhase.mature:
          //todo
        }
        updatePaintWithColor(currentGrowthPhase.getColor());
      }
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (canBeDestroyedByTap) {
      game.fieldModule.removeField(this);
    }
  }

  void updatePaintWithColor(Color color) {
    paint = paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }
}
