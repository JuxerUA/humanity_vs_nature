import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/game/modules/field/growth_phase.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class FieldComponent extends RectangleComponent
    with HasGameRef<SimulationGame>, TapCallbacks {
  FieldComponent({
    required this.owner,
    this.canBeDestroyedByTap = true,
  }) {
    paint = Paint()
      ..color = GrowthPhase.ground.getColor()
      ..style = PaintingStyle.fill;
  }

  static const double gasEarnRadius = SimulationGame.blockSize * 3;
  static const int harvestValuePerBlock = 1000;

  final PositionComponent owner;
  final bool canBeDestroyedByTap;

  double storedGas = 0;
  double remainingGasForMoveToNextPhase = 0;
  GrowthPhase currentGrowthPhase = GrowthPhase.ground;

  double get area => size.x * size.y;

  int get areaInBlocks =>
      (area / (SimulationGame.blockSize * SimulationGame.blockSize)).round();

  @override
  FutureOr<void> onLoad() {
    updateRemainingGas();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (storedGas < 0.5) {
      storedGas += game.gasModule.aFieldWantsSomeCO2(position);
    }

    final usingGas = min(storedGas, dt * 0.1);
    if (usingGas > 0) {
      storedGas -= usingGas;
      remainingGasForMoveToNextPhase -= usingGas;

      if (remainingGasForMoveToNextPhase <= 0) {
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
            _sendHarvestToOwner();
            currentGrowthPhase = GrowthPhase.ground;
        }
        updateRemainingGas();
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

  void _sendHarvestToOwner() {
    final harvestValue = areaInBlocks * harvestValuePerBlock;
    final base = owner;
    if (base is FarmComponent) {
      base.plantFoodAmount += harvestValue;
    } else if (base is CityComponent) {
      base.plantFoodAmount += harvestValue;
    }

    // game.foodModule.add(FoodComponent(
    //   owner,
    //   paint.color,
    //   vertices,
    // )..position = position);
    // currentGrowthPhase = GrowthPhase.ground;
  }

  void updateRemainingGas() {
    remainingGasForMoveToNextPhase +=
        currentGrowthPhase.requiredGasForMoveToNextPhase * areaInBlocks;
  }

  void updatePaintWithColor(Color color) {
    paint = paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  void setRandomPhase() {
    currentGrowthPhase = GrowthPhase.values.random();
    updatePaintWithColor(currentGrowthPhase.getColor());
    updateRemainingGas();
    remainingGasForMoveToNextPhase *= randomFallback.nextDouble();
  }
}
