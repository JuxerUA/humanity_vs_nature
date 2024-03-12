import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/iterable_extension.dart';
import 'package:humanity_vs_nature/game/experimental/floating_text_component.dart';
import 'package:humanity_vs_nature/game/mixins/animation_on_tap.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/bulldozer/bulldozer_component.dart';
import 'package:humanity_vs_nature/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/game/modules/farm/farm_expand_result.dart';
import 'package:humanity_vs_nature/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

class CityComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<SimulationGame>, AnimationOnTap {
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

  final textPopulation = TextComponent(text: 'Population');
  final textPopulationValue = TextComponent();
  final textAwareness = TextComponent(text: 'Awareness');
  final textAwarenessValue = TextComponent();
  final textPlantFood = TextComponent();
  final textAnimalFood = TextComponent();

  Spot get spot => Spot(position, radius);

  double get ignorance => 1 - awareness;

  double get co2Emission => population * ignorance * 0.005;

  int get requiredPlantFoodAmount =>
      (population * 0.5 + population * 0.5 * awareness).round();

  int get requiredAnimalFoodAmount => population - requiredPlantFoodAmount;

  double get plantFoodProduction => fields.isEmpty
      ? 0
      : fields
          .map((e) => e.productionRatePerSecond)
          .reduce((sum, value) => sum + value);

  double get animalFoodProduction => farms.isEmpty
      ? 0
      : farms
          .map((e) => e.productionRatePerSecond)
          .reduce((sum, value) => sum + value);

  @override
  FutureOr<void> onLoad() async {
    sprite = game.spriteCity;
    anchor = Anchor.center;
    size *= 0.5;

    bulldozersPower = randomFallback.nextDouble() * 10;

    population = randomFallback.nextInt(50) + 50;
    textPopulation
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y / 2 - 3)
      ..textRenderer = TextPaint(style: Styles.white10);
    add(textPopulation);
    textPopulationValue
      ..anchor = Anchor.center
      ..position = textPopulation.position + Vector2(0, 12)
      ..textRenderer = TextPaint(style: Styles.white14);
    add(textPopulationValue);

    awareness = randomFallback.nextDouble() * 0.1;
    textAwareness
      ..anchor = Anchor.center
      ..position = textPopulationValue.position + Vector2(0, 13)
      ..textRenderer = TextPaint(style: Styles.white10);
    add(textAwareness);
    textAwarenessValue
      ..anchor = Anchor.center
      ..position = textAwareness.position + Vector2(0, 12)
      ..textRenderer = TextPaint(style: Styles.white16);
    add(textAwarenessValue);

    plantFoodAmount = population * 10 + randomFallback.nextInt(population * 10);
    textPlantFood
      ..anchor = Anchor.center
      ..position = textAwarenessValue.position + Vector2(0, 22)
      ..textRenderer = TextPaint(style: Styles.black10);
    add(textPlantFood);

    animalFoodAmount =
        population * 10 + randomFallback.nextInt(population * 10);
    textAnimalFood
      ..anchor = Anchor.center
      ..position = textPlantFood.position + Vector2(0, 10)
      ..textRenderer = TextPaint(style: Styles.black10);
    add(textAnimalFood);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if ((bulldozersPower += dt) > 15) {
      _tryToUseBulldozersPower();
    }

    if ((updateTimer += dt) >= 1) {
      updateTimer -= 1;
      _updateCityState();
    }

    _tryToSpawnGas(dt);

    textPopulationValue.text = '$population';
    textAwarenessValue.text = '${(awareness * 100).round()}%';
    textPlantFood.text = 'Plant Food: $plantFoodAmount';
    textAnimalFood.text = 'Animal Food: $animalFoodAmount';

    super.update(dt);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    awareness += 0.001;
    if (awareness > 100) awareness = 100;
    textAwarenessValue.text = '${(awareness * 100).round()}';
    showPositiveText('Awareness +0.1%');
    game.cityModule.updateAwarenessProgress();
    animateOnTap();
  }

  void _updateCityState() {
    /// Update awareness
    awareness += ignorance * 0.001 - randomFallback.nextDouble() * 0.0005;
    if (awareness > 100) awareness = 100;

    /// Update food amount
    plantFoodAmount -= requiredPlantFoodAmount;
    animalFoodAmount -= requiredAnimalFoodAmount;

    /// Update population growth
    var populationGrowth = 1;
    if (animalFoodAmount > population) populationGrowth += 1;
    if (plantFoodAmount > population) populationGrowth += 1;
    populationGrowth += (3 * ignorance).round();
    population += populationGrowth;

    /// Update plant food production
    final requiredPlantFoodFor60Seconds = requiredPlantFoodAmount * 60 * 1.1;
    final existingPlantFoodFor60Seconds =
        plantFoodProduction * 60 + plantFoodAmount;
    if (existingPlantFoodFor60Seconds < requiredPlantFoodFor60Seconds) {
      /// Not enough plant food production
      final field = _tryToExpandFields();
      if (field == null) {
        if (game.treeModule.isThereAnyTreesAtTheSpot(
          Spot(position, radiusForFields),
        )) {
          _tryToUseBulldozersPower();
        }
      }
    } else if (existingPlantFoodFor60Seconds >
        requiredPlantFoodFor60Seconds * 3) {
      /// Too much plant food production
      if (_tryToRemoveField()) {
        showPositiveText('There are unused fields');
      }
    }

    /// Update animal food production
    final requiredAnimalFoodFor60Seconds = requiredAnimalFoodAmount * 60 * 1.1;
    final existingAnimalFoodFor60Seconds =
        animalFoodProduction * 60 + animalFoodAmount;
    if (existingAnimalFoodFor60Seconds < requiredAnimalFoodFor60Seconds) {
      /// Not enough animal food production
      if (farms.isNotEmpty) {
        final farm = farms.random();
        final result = farm.tryToIncreaseProduction();
        switch (result) {
          case FarmIncreaseProductionResult.thereAreTrees:
            _tryToUseBulldozersPower(forFarm: farm);
            break;
          case FarmIncreaseProductionResult.limitHasBeenReached:
            if (game.combineModule.cityWantsToBuildNewFarm(this)) {
              showNegativeText('We need to build a new farm');
            }
            break;
          case FarmIncreaseProductionResult.successfullyIncreased:
        }
      } else {
        if (game.combineModule.cityWantsToBuildNewFarm(this)) {
          showNegativeText('We need to build a new farm');
        }
      }
    } else if (existingAnimalFoodFor60Seconds >
        requiredAnimalFoodFor60Seconds * 3) {
      /// Too much animal food production
      if (farms.isNotEmpty) {
        if (farms.random().reduceProduction()) {
          showPositiveText('We have an unused farm');
        } else {
          showPositiveText('Farm has an unused field');
        }
      }
    }

    game.cityModule.updateAwarenessProgress();
  }

  FieldComponent? _tryToExpandFields() {
    final field = game.fieldModule.expandField(this, radiusForFields);
    if (field != null) {
      fields.add(field);
      return field;
    }
    return null;
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

      fields.remove(furthestField);
      game.fieldModule.abandonField(furthestField);
      return true;
    }
    return false;
  }

  void _tryToUseBulldozersPower({FarmComponent? forFarm}) {
    if (bulldozersPower > 10) {
      bulldozersPower -= 5 + randomFallback.nextDouble() * 20;
      if (bulldozers.length < 10 &&
          game.bulldozerModule.bulldozers.length * 15 <
              game.treeModule.trees.length) {
        final farm = forFarm;
        if (farm != null) {
          final tree = game.treeModule.findFreeMatureNearestTree(farm.position);
          bulldozers.add(game.bulldozerModule.addBulldozer(this, target: tree));
        } else {
          bulldozers.add(game.bulldozerModule.addBulldozer(this));
        }
        showNegativeText('We need more bulldozers!');
      } else {
        bulldozers.firstOrNullWhere((e) => !e.isAngry)?.isAngry = true;
        showNegativeText('Damn trees!');
      }
    }
  }

  void _tryToSpawnGas(double dt) {
    if ((timeForSpawnGas -= dt) < 0) {
      timeForSpawnGas = gasSpawnTime;
      final gasPosition =
          position + (Vector2.random() - Vector2.all(0.5)) * radius;
      game.gasModule.addCO2(gasPosition, volume: co2Emission);
    }
  }

  void showPositiveText(String text) => _createText(text, Colors.green);

  void showNegativeText(String text) => _createText(text, Colors.redAccent);

  void _createText(String text, Color color) {
    final existingFloatingText =
        children.whereType<FloatingTextComponent>().firstOrNull;

    if (existingFloatingText != null) {
      existingFloatingText.reSpawn(text, color);
    } else {
      add(
        FloatingTextComponent(text: text)
          ..position = Vector2(
            size.x / 2,
            size.y / 2 - 20,
          )
          ..paint.color = color,
      );
    }
  }
}
