import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/mixins/blink_mixin.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class FieldComponent extends RectangleComponent
    with HasGameRef<SimulationGame>, TapCallbacks, BlinkEffect {
  FieldComponent({
    required this.owner,
    this.canBeDestroyedByTap = true,
  }) {
    paint = Paint()
      ..color = randomColor
      ..style = PaintingStyle.fill;
  }

  static const int harvestValuePerBlock = 200;

  final PositionComponent owner;
  final bool canBeDestroyedByTap;

  late double productionRatePerSecond;
  double timer = 0;

  double get area => size.x * size.y;

  int get areaInBlocks =>
      (area / (SimulationGame.blockSize * SimulationGame.blockSize)).round();

  int get totalFieldHarvest => areaInBlocks * harvestValuePerBlock;

  double totalFieldGrowthTime = 20 + randomFallback.nextDouble() * 20;

  Color get randomColor => [
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
      ].random();

  @override
  FutureOr<void> onLoad() {
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
  }

  void setRandomPhase() {
    paint.color = randomColor;
    timer = totalFieldGrowthTime * randomFallback.nextDouble();
  }
}
