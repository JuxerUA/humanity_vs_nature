import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
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

  var _timeForExpandFields = 5.0;
  var _timeForSpawnGas = 0.0;

  int hp = 20;

  final CityComponent owner;
  late final FieldComponent baseField;
  final List<FieldComponent> fields = [];

  double plantFoodAmount = 0;
  int animalFoodAmount = 0;
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
    const foodConversionRate = 6;
    final animalFoodGrowthAmount =
        (plantFoodAmount / foodConversionRate).floor();
    plantFoodAmount -= animalFoodGrowthAmount * foodConversionRate;
    animalFoodAmount += animalFoodGrowthAmount;
    owner.animalFoodAmount += animalFoodAmount;
    animalFoodAmount = 0;

    storedGas += animalFoodGrowthAmount / 10;

    _trySpawnGas(dt);
  }

  void _tryToExpandFields(double dt) {
    _timeForExpandFields -= dt;
    if (_timeForExpandFields < 0) {
      _timeForExpandFields = randomFallback.nextDouble() * maxExpandFieldsTime;
      final field = game.fieldModule.expandField(this, radiusForFields);
      if (field != null) {
        fields.add(field);
      }
    }
  }

  void _trySpawnGas(double dt) {
    _timeForSpawnGas -= dt;
    if (_timeForSpawnGas < 0) {
      _timeForSpawnGas = gasSpawnTime;
      final gasPosition =
          position + (Vector2.random() - Vector2.all(0.5)) * radius;
      final gasVolume = storedGas * 0.1;
      storedGas = gasVolume;
      game.gasModule.addCH4(gasPosition, gasVolume);
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
