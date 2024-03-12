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
      ..color = randomColor
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

  double totalFieldGrowthTime = 20 + randomFallback.nextDouble() * 20;

  double get growthTimeOfCurrentPhase => phasesTime[currentGrowthPhase.index];

  Color get randomColor => [
        Colors.green,
        Colors.green,
        Colors.green,
        Colors.green,
        // Colors.lightGreen,
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
        // Colors.deepOrangeAccent,
        // Colors.deepOrange,
      ].random();

  @override
  FutureOr<void> onLoad() {
    // phasesTime = [
    //   5 + randomFallback.nextDouble(),
    //   5 + randomFallback.nextDouble(),
    //   10 + randomFallback.nextDouble(),
    //   10 + randomFallback.nextDouble(),
    // ];
    productionRatePerSecond = totalFieldHarvest / totalFieldGrowthTime;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;
    if (timer >= totalFieldGrowthTime) {
      timer -= totalFieldGrowthTime;
      _sendHarvestToOwner();
      //paint.color = randomColor;
    }
    // if (timer >= growthTimeOfCurrentPhase) {
    //   timer -= growthTimeOfCurrentPhase;
    //
    //   switch (currentGrowthPhase) {
    //     case GrowthPhase.ground:
    //       currentGrowthPhase = GrowthPhase.young;
    //     case GrowthPhase.young:
    //       currentGrowthPhase = GrowthPhase.medium;
    //     case GrowthPhase.medium:
    //       currentGrowthPhase = GrowthPhase.mature;
    //     case GrowthPhase.mature:
    //       _sendHarvestToOwner();
    //       currentGrowthPhase = GrowthPhase.ground;
    //   }
    //   paint.color = currentGrowthPhase.getColor();
    // }
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
    // )..position = position + size / 2);
  }

  void setRandomPhase() {
    // currentGrowthPhase = GrowthPhase.values.random();
    // paint.color = currentGrowthPhase.getColor();
    paint.color = randomColor;
    // timer = growthTimeOfCurrentPhase * randomFallback.nextDouble();
    timer = totalFieldGrowthTime * randomFallback.nextDouble();
  }
}
