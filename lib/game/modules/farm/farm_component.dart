import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/farm/farm_expand_result.dart';
import 'package:humanity_vs_nature/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class FarmComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<SimulationGame> {
  FarmComponent({required this.owner});

  static const double radius = 25;
  static const double requiredSpotRadius = 85;
  static const double radiusForFields = 100;
  static const double maxExpandFieldsTime = 15;
  static const double gasSpawnTime = 0.3;
  static const double foodConversionRate = 6;

  var _timeForSpawnGas = 0.0;

  int hp = 20;

  final CityComponent owner;
  late final FieldComponent baseField;
  final List<FieldComponent> fields = [];

  double productionRatePerSecond = 0;

  double plantFoodAmount = 0;
  double storedGas = 0;

  Spot get spot => Spot(position, radius);

  @override
  FutureOr<void> onLoad() async {
    sprite = await getSpriteFromAsset(Assets.spritesFarm);
    anchor = Anchor.bottomCenter;
    size *= 0.7;
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final animalFoodGrowthAmount =
        (plantFoodAmount / foodConversionRate).floor();
    plantFoodAmount -= animalFoodGrowthAmount * foodConversionRate;
    owner.animalFoodAmount += animalFoodGrowthAmount;

    storedGas += animalFoodGrowthAmount * 0.0000001;

    _trySpawnGas(dt);
  }

  void updateProductionRate() {
    productionRatePerSecond = fields
            .map((e) => e.productionRatePerSecond)
            .reduce((sum, rate) => sum + rate) /
        foodConversionRate;
  }

  FarmIncreaseProductionResult tryToIncreaseProduction() {
    final field = game.fieldModule.expandField(this, radiusForFields);
    if (field != null) {
      fields.add(field);
      updateProductionRate();
      return FarmIncreaseProductionResult.successfullyIncreased;
    }

    return game.treeModule.isThereAnyTreesAtTheSpot(
      Spot(position, radiusForFields),
    )
        ? FarmIncreaseProductionResult.thereAreTrees
        : FarmIncreaseProductionResult.limitHasBeenReached;
  }

  bool reduceProduction() {
    if (fields.isNotEmpty) {
      var furthestField = fields.first;
      var distance2 = 0.0;
      for (final field in fields) {
        final fieldDistance2 = field.position.distanceToSquared(position);
        if (fieldDistance2 > distance2) {
          distance2 = fieldDistance2;
          furthestField = field;
        }
      }

      fields.remove(furthestField);
      game.fieldModule.abandonField(furthestField);
      updateProductionRate();
      return false;
    } else {
      game.farmModule.removeFarm(this);
      return true;
    }
  }

  void _trySpawnGas(double dt) {
    _timeForSpawnGas -= dt;
    if (_timeForSpawnGas < 0) {
      _timeForSpawnGas = gasSpawnTime;
      final gasPosition =
          position + (Vector2.random() - Vector2.all(0.5)) * radius;
      final gasVolume = storedGas * 0.1;
      storedGas -= gasVolume;
      game.gasModule.addCH4(gasPosition, volume: gasVolume);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    hp -= 1;
    if (hp < 1) {
      game.farmModule.removeFarm(this);
    }
  }
}
