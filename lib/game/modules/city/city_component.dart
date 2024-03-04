import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/extensions/iterable_extension.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/bulldozer/bulldozer_component.dart';
import 'package:humanity_vs_nature/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

class CityComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<SimulationGame> {
  static const double radius = 50;
  static const double radiusForFields = 150;
  static const double maxBulldozerSpawnTime = 50;
  static const double maxCombineSpawnTime = 120;
  static const double gasSpawnTime = 0.1;

  final List<BulldozerComponent> bulldozers = [];
  final List<FieldComponent> fields = [];
  final List<FarmComponent> farms = [];

  double timeForSpawnGas = 0;
  double updateTimer = 0;

  int population = 0;
  double awareness = 0; //% 0..1
  int plantFoodAmount = 0;
  int animalFoodAmount = 0;
  double bulldozersPower = 0;

  final textPopulation = TextComponent();
  final textAwareness = TextComponent();

  Spot get spot => Spot(position, radius);

  double get co2Emission => population * (1 - awareness) * 0.005;

  @override
  FutureOr<void> onLoad() async {
    sprite = await getSpriteFromAsset(Assets.spritesCity);
    anchor = Anchor.center;
    add(CircleHitbox(radius: 50));

    population = randomFallback.nextInt(50) + 50;
    textPopulation
      ..anchor = Anchor.center
      ..position = size / 2
      ..textRenderer = TextPaint(style: Styles.white12);
    add(textPopulation);

    awareness = randomFallback.nextDouble() * 0.1;
    textAwareness
      ..anchor = Anchor.center
      ..position = textPopulation.position + Vector2(0, 10)
      ..textRenderer = TextPaint(style: Styles.white12);
    add(textAwareness);

    plantFoodAmount = 1000 + randomFallback.nextInt(1000);
    animalFoodAmount = 1000 + randomFallback.nextInt(1000);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    bulldozersPower += dt;
    updateTimer += dt;
    if (updateTimer >= 1) {
      updateTimer -= 1;
      _updateCityState();
    }

    _tryToSpawnGas(dt);

    textPopulation.text = 'Population: $population';
    textAwareness.text = 'Awareness: ${(awareness * 100).round()}';

    super.update(dt);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    awareness += 0.001;
    textAwareness.text = 'Awareness: ${(awareness * 100).round()}';
  }

  void _updateCityState() {
    awareness += (1 - awareness) * 0.001 - randomFallback.nextDouble() * 0.0005;

    final requiredPlantFoodAmount = (population * awareness).round();
    final requiredAnimalFoodAmount = population - requiredPlantFoodAmount;

    plantFoodAmount -= requiredAnimalFoodAmount;
    animalFoodAmount -= requiredAnimalFoodAmount;

    final foodSummary = plantFoodAmount + animalFoodAmount;
    final maxPopulationGrowth = max(population * 0.01, 0);
    final maxPopulationDecline = max(population * 0.001, 0);
    final maxPopulationGrowthByFood = max(
      min(plantFoodAmount / awareness, animalFoodAmount / (1 - awareness)),
      0,
    );

    var populationGrowth = 0.0;
    if (foodSummary > 0) {
      populationGrowth = min(maxPopulationGrowth, maxPopulationGrowthByFood) +
          50 * randomFallback.nextDouble();
      populationGrowth *= 1 - awareness;
    } else {
      populationGrowth =
          -maxPopulationDecline + 10 * randomFallback.nextDouble();
      populationGrowth *= awareness;
    }
    population += populationGrowth.round();

    if (plantFoodAmount < 0) {
      if (!_tryToExpandFields() &&
          plantFoodAmount < requiredPlantFoodAmount * -0.5) {
        plantFoodAmount = (plantFoodAmount / 2).round();
        _tryToUseBulldozersPower();
      }
    }

    if (animalFoodAmount < 0) {
      if (plantFoodAmount > requiredPlantFoodAmount * 2) {
        if (!_tryToRemoveField() &&
            animalFoodAmount < requiredAnimalFoodAmount * -0.5) {
          animalFoodAmount = (animalFoodAmount / 2).round();
          _tryToUseBulldozersPower();
        }
      }
    }
  }

  bool _tryToExpandFields() {
    final field = game.fieldModule.expandField(this, radiusForFields);
    if (field != null) {
      fields.add(field);
      return true;
    }
    return false;
  }

  bool _tryToRemoveField() {
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

      game.fieldModule.removeField(furthestField);
      return true;
    }
    return false;
  }

  void _tryToUseBulldozersPower() {
    if (bulldozersPower > 10) {
      bulldozersPower = 0;
      if (bulldozers.length < 10 &&
          game.bulldozerModule.bulldozers.length * 5 <
              game.treeModule.trees.length) {
        final bulldozer = game.bulldozerModule.addBulldozer(this);
        bulldozers.add(bulldozer);
      } else {
        bulldozers.firstOrNullWhere((e) => !e.isAngry)?.isAngry = true;
      }
    }
  }

  void _tryToSpawnGas(double dt) {
    timeForSpawnGas -= dt;
    if (timeForSpawnGas < 0) {
      timeForSpawnGas = gasSpawnTime;
      final gasPosition =
          position + (Vector2.random() - Vector2.all(0.5)) * radius;
      game.gasModule.addCO2(gasPosition, co2Emission);
    }
  }
}
