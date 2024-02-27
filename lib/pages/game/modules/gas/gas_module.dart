import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/gas/gas_type.dart';
import 'package:humanity_vs_nature/pages/game/modules/gas/gas_unit.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

export 'gas_unit.dart';

class GasModule extends Component with HasGameRef<SimulationGame> {
  static const expectedNumberOfCO2units = 100;
  static const expectedNumberOfCH4units = 20;

  final List<GasUnit> unitsCO2 = [];
  final List<GasUnit> unitsCH4 = [];

  double currentBiggestCO2UnitVolume = GasUnit.defaultVolume;
  double currentBiggestCH4UnitVolume = GasUnit.defaultVolume;
  double maxScreenLengthForDistribution = 0; //todo

  double totalCO2created = 0;
  double totalCO2absorbedByTheOcean = 0;
  double totalCH4created = 0;
  double totalCH4convertedToCO2 = 0;

  @override
  FutureOr<void> onLoad() {
    maxScreenLengthForDistribution = sqrt(
      game.worldSize.x * game.worldSize.x + game.worldSize.y * game.worldSize.y,
    );
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    for (final unit in unitsCO2) {
      unit.render(canvas);
    }
    for (final unit in unitsCH4) {
      unit.render(canvas);
    }
  }

  @override
  void update(double dt) {
    if (unitsCO2.isEmpty) {
      return;
    }

    for (final unit in unitsCO2) {
      unit.update(dt, game);
    }

    for (final unit in unitsCH4) {
      unit.update(dt, game);
    }

    gasDistribution(unitsCO2, currentBiggestCO2UnitVolume, dt);
    gasDistribution(unitsCH4, currentBiggestCH4UnitVolume, dt);

    if (totalCO2absorbedByTheOcean < totalCO2created * 0.3) {
      var minClearance = double.infinity;
      var minClearanceUnit = unitsCO2.first;
      for (final unit in unitsCO2) {
        final unitPosition = unit.position;

        final leftClearance = unitPosition.x;
        final topClearance = unitPosition.y;
        final rightClearance = game.worldSize.x - unitPosition.x;
        final bottomClearance = game.worldSize.y - unitPosition.y;

        final myMinXClearance = min(leftClearance, rightClearance);
        final myMinYClearance = min(topClearance, bottomClearance);
        final myMinClearance = min(myMinXClearance, myMinYClearance);
        if (myMinClearance < minClearance) {
          minClearance = myMinClearance;
          minClearanceUnit = unit;
        }
      }

      if (minClearance < 0) {
        totalCO2absorbedByTheOcean += _getSomeGasFromTheUnit(minClearanceUnit);
      }
    }
  }

  void gasDistribution(List<GasUnit> units, double biggestVolume, double dt) {
    for (var i = 0; i < units.length; i++) {
      final unitI = units[i];
      var resultVector = Vector2.zero();
      for (var j = i + 1; j < units.length; j++) {
        final unitJ = units[j];

        final direction = unitJ.position - unitI.position;
        final length = direction.length;
        if (length < 50) {
          final intensity = (maxScreenLengthForDistribution - length) /
              maxScreenLengthForDistribution;
          resultVector += direction * intensity;
        }
      }

      unitI.velocity -= (resultVector..clampLength(0, 15)) *
          (unitI.volume / biggestVolume) *
          dt;
    }
  }

  void addCO2(Vector2 position, [double volume = GasUnit.defaultVolume]) {
    final velocity = Vector2(randomFallback.nextDouble() - 0.5, -10);
    final gasUnit = GasUnit(GasType.co2, position, velocity)..volume = volume;
    unitsCO2.add(gasUnit);
    totalCO2created += gasUnit.volume;
    unitSynthesis(unitsCO2, expectedNumberOfCO2units, GasType.co2);
    updateCO2Text();
  }

  void addCH4(Vector2 position, [double volume = GasUnit.defaultVolume]) {
    final velocity = Vector2(randomFallback.nextDouble() - 0.5, -5);
    final gasUnit = GasUnit(GasType.ch4, position, velocity)..volume = volume;
    unitsCH4.add(gasUnit);
    totalCH4created += gasUnit.volume;
    unitSynthesis(unitsCH4, expectedNumberOfCH4units, GasType.ch4);
    updateCH4Text();
  }

  void removeGasUnit(GasUnit gasUnit) {
    final type = gasUnit.type;
    switch (type) {
      case GasType.co2:
        unitsCO2.remove(gasUnit);
        unitDecomposition(unitsCO2, expectedNumberOfCO2units, type);
        updateCO2Text();
      case GasType.ch4:
        unitsCH4.remove(gasUnit);
        unitDecomposition(unitsCH4, expectedNumberOfCH4units, type);
        updateCH4Text();
    }
  }

  void unitSynthesis(List<GasUnit> units, int expectedNumber, GasType type) {
    if (units.length > expectedNumber) {
      var minValue = double.infinity;
      var particle1 = units[0];
      var particle2 = units[1];

      for (var i = 0; i < units.length; i++) {
        for (var j = i + 1; j < units.length; j++) {
          final particleI = units[i];
          final particleJ = units[j];

          final direction = particleJ.position - particleI.position;
          final value =
              direction.length * (particleI.volume + particleJ.volume);
          if (value < minValue) {
            minValue = value;
            particle1 = particleI;
            particle2 = particleJ;
          }
        }
      }

      if (particle1.volume > particle2.volume) {
        particle1.addVolume(particle2.volume);
        units.remove(particle2);
        updateBiggestGasVolume(type, particle1.volume);
      } else {
        particle2.addVolume(particle1.volume);
        units.remove(particle1);
        updateBiggestGasVolume(type, particle2.volume);
      }
    }
  }

  void unitDecomposition(
      List<GasUnit> units, int expectedNumber, GasType type) {
    if (units.length < expectedNumber) {
      var biggestUnit = units[0];
      var firstBiggestGasVolume = 0.0;
      var secondBiggestGasVolume = 0.0;
      for (var i = 0; i < units.length; i++) {
        final unit = units[i];
        if (unit.volume > firstBiggestGasVolume) {
          secondBiggestGasVolume = firstBiggestGasVolume;
          firstBiggestGasVolume = unit.volume;
          biggestUnit = unit;
        }
      }

      biggestUnit
        ..velocity.clampLength(15, 20)
        ..volume /= 2;

      final newUnit = GasUnit(
        type,
        biggestUnit.position - biggestUnit.velocity,
        -biggestUnit.velocity,
      )..volume = biggestUnit.volume;
      units.add(newUnit);

      updateBiggestGasVolume(
        type,
        max(biggestUnit.volume, secondBiggestGasVolume),
      );
    }
  }

  void updateBiggestGasVolume(GasType type, double volume) {
    switch (type) {
      case GasType.co2:
        if (volume > currentBiggestCO2UnitVolume) {
          currentBiggestCO2UnitVolume = volume;
        }
      case GasType.ch4:
        if (volume > currentBiggestCH4UnitVolume) {
          currentBiggestCH4UnitVolume = volume;
        }
    }
  }

  void updateCO2Text() {
    final volumeCO2 = unitsCO2
        .map((e) => e.volume)
        .reduce((value, element) => value += element);
    game.currentCO2Value.value = volumeCO2;
  }

  void updateCH4Text() {
    final volumeCH4 = unitsCH4
        .map((e) => e.volume)
        .reduce((value, element) => value += element);
    game.currentCH4Value.value = volumeCH4;
  }

  double aTreeWantsSomeCO2(Vector2 position, double dt) {
    const attractionDistance = TreeComponent.radius * 5;
    final leftSide = position.x - attractionDistance;
    final rightSide = position.x + attractionDistance;
    final topSide = position.y - attractionDistance;
    final bottomSide = position.y + attractionDistance;

    for (final unit in unitsCO2) {
      if (unit.position.x > leftSide &&
          unit.position.x < rightSide &&
          unit.position.y > topSide &&
          unit.position.y < bottomSide) {
        final direction = position - unit.position;
        final length = direction.normalize();
        unit.velocity += direction * 5 * dt;
        if (length < TreeComponent.radius) {
          return _getSomeGasFromTheUnit(unit);
        }
      }
    }

    return 0;
  }

  double aFieldWantsSomeCO2(Vector2 position, double dt) {
    const attractionDistance = FieldComponent.gasRadius;
    final leftSide = position.x - attractionDistance;
    final rightSide = position.x + attractionDistance;
    final topSide = position.y - attractionDistance;
    final bottomSide = position.y + attractionDistance;

    for (final unit in unitsCO2) {
      if (unit.position.x > leftSide &&
          unit.position.x < rightSide &&
          unit.position.y > topSide &&
          unit.position.y < bottomSide) {
        return _getSomeGasFromTheUnit(unit, 0.1);
      }
    }

    return 0;
  }

  double _getSomeGasFromTheUnit(GasUnit gasUnit, [double volume = 1]) {
    if (gasUnit.volume > volume) {
      gasUnit.volume -= volume;
      return volume;
    } else {
      final remainingVolume = gasUnit.volume;
      removeGasUnit(gasUnit);
      return remainingVolume;
    }
  }
}
