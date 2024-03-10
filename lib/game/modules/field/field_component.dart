import 'dart:async';

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
  static const int harvestValuePerBlock = 200;

  final PositionComponent owner;
  final bool canBeDestroyedByTap;

  late final List<double> phasesTime;
  late double productionRatePerSecond;
  double timer = 0;

  GrowthPhase currentGrowthPhase = GrowthPhase.ground;

  double get area => size.x * size.y;

  int get areaInBlocks =>
      (area / (SimulationGame.blockSize * SimulationGame.blockSize)).round();

  int get totalFieldHarvest => areaInBlocks * harvestValuePerBlock;

  double get totalFieldGrowthTime => phasesTime.reduce((sum, e) => sum + e);

  double get growthTimeOfCurrentPhase => phasesTime[currentGrowthPhase.index];

  @override
  FutureOr<void> onLoad() {
    phasesTime = [
      5 + randomFallback.nextDouble(),
      5 + randomFallback.nextDouble(),
      10 + randomFallback.nextDouble(),
      10 + randomFallback.nextDouble(),
    ];
    productionRatePerSecond = totalFieldHarvest / totalFieldGrowthTime;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;
    if (timer >= growthTimeOfCurrentPhase) {
      timer -= growthTimeOfCurrentPhase;

      switch (currentGrowthPhase) {
        case GrowthPhase.ground:
          currentGrowthPhase = GrowthPhase.young;
        case GrowthPhase.young:
          currentGrowthPhase = GrowthPhase.medium;
        case GrowthPhase.medium:
          currentGrowthPhase = GrowthPhase.mature;
        case GrowthPhase.mature:
          _sendHarvestToOwner();
          currentGrowthPhase = GrowthPhase.ground;
      }
      paint.color = currentGrowthPhase.getColor();
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
    final base = owner;
    if (base is FarmComponent) {
      base.plantFoodAmount += totalFieldHarvest;
    } else if (base is CityComponent) {
      base.plantFoodAmount += totalFieldHarvest;
    }

    // game.foodModule.add(FoodComponent(
    //   owner,
    //   paint.color,
    //   vertices,
    // )..position = position);
    // currentGrowthPhase = GrowthPhase.ground;
  }

  void setRandomPhase() {
    currentGrowthPhase = GrowthPhase.values.random();
    paint.color = currentGrowthPhase.getColor();
    timer = growthTimeOfCurrentPhase * randomFallback.nextDouble();
  }
}
