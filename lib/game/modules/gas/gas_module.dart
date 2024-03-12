import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/gas/gas_type.dart';
import 'package:humanity_vs_nature/game/modules/gas/gas_unit.dart';
import 'package:humanity_vs_nature/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

export 'gas_unit.dart';

class GasModule extends Component with HasGameRef<SimulationGame> {
  static const expectedNumberOfCO2units = 100;
  static const expectedNumberOfCH4units = 20;
  static const maxAllowablePollution = 10000;
  static const multiplierCO2 = 1;
  static const multiplierCH4 = 80;

  final List<GasUnit> unitsCO2 = [];
  final List<GasUnit> unitsCH4 = [];

  double currentBiggestCO2UnitVolume = GasUnit.defaultVolume;
  double currentBiggestCH4UnitVolume = GasUnit.defaultVolume;
  double maxScreenLengthForDistribution = 0; //todo
  double convertCH4toCO2Timer = 0;

  double totalCO2created = 0;
  double totalCO2absorbedByTheOcean = 0;
  double totalCH4created = 0;
  double totalCH4convertedToCO2 = 0;

  double get currentTotalCO2Volume =>
      unitsCO2.map((e) => e.volume).reduce((value, volume) => value += volume);

  double get currentTotalCH4Volume =>
      unitsCH4.map((e) => e.volume).reduce((value, volume) => value += volume);

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

    if ((convertCH4toCO2Timer -= dt) < 0) {
      convertCH4toCO2Timer = randomFallback.nextDouble();
      if (currentTotalCH4Volume * multiplierCH4 > currentTotalCO2Volume) {
        var minCH4Unit = unitsCH4.first;
        var minVolume = double.infinity;
        for (final unit in unitsCH4) {
          if (unit.volume < minVolume) {
            minVolume = unit.volume;
            minCH4Unit = unit;
          }
        }

        addCO2(
          minCH4Unit.position,
          volume: minCH4Unit.volume,
          velocity: minCH4Unit.velocity,
        );
        removeGasUnit(minCH4Unit);
      }
    }
  }

  void spawnInitialGas() {
    for (var i = 0; i < 40; i++) {
      addCO2(
        Vector2.random() * game.worldSize.x,
        velocity: Vector2.zero(),
        updateText: false,
      );
    }
    for (var i = 0; i < 10; i++) {
      addCH4(
        Vector2.random() * game.worldSize.x,
        velocity: Vector2.zero(),
        updateText: false,
      );
    }
    updateCO2Text();
    updateCH4Text();
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

  // void gasDistribution(List<GasUnit> units, double biggestVolume, double dt) {
  //   final unitsLength = units.length;
  //   final unitArea = game.worldSize.x * game.worldSize.y / unitsLength;
  //   final unitSide = sqrt(unitArea);
  //   final maxLength2 = unitSide * unitSide;
  //
  //   for (var i = 0; i < unitsLength; i++) {
  //     final unitI = units[i];
  //     final resultVector = Vector2.zero();
  //     for (var j = i + 1; j < unitsLength; j++) {
  //       final unitJ = units[j];
  //       if ((unitJ.position.x - unitI.position.x).abs() < unitSide &&
  //           (unitJ.position.y - unitI.position.y).abs() < unitSide) {
  //         final direction = unitJ.position - unitI.position;
  //         final length2 = direction.length2;
  //         resultVector.addScaled(direction, maxLength2 / length2);
  //       }
  //     }
  //     // final scaledVector = resultVector.scaled(1 / unitI.volume * dt * 0.0000001);
  //     // print('');
  //     // unitI.velocity += resultVector.scaled(1 / unitI.volume * dt * 0.0000001)
  //     //   ..clampLength(1, 20);
  //   }
  // }

  void addCO2(
    Vector2 position, {
    double volume = GasUnit.defaultVolume,
    Vector2? velocity,
    bool updateText = true,
  }) {
    final gasUnit = GasUnit(
      GasType.co2,
      position,
      velocity ?? Vector2(randomFallback.nextDouble() - 0.5, -10),
    )..volume = volume;
    unitsCO2.add(gasUnit);
    totalCO2created += gasUnit.volume;
    unitSynthesis(unitsCO2, expectedNumberOfCO2units, GasType.co2);
    if (updateText) updateCO2Text();
  }

  void addCH4(
    Vector2 position, {
    double volume = GasUnit.defaultVolume,
    Vector2? velocity,
    bool updateText = true,
  }) {
    final gasUnit = GasUnit(
      GasType.ch4,
      position,
      velocity ?? Vector2(randomFallback.nextDouble() - 0.5, -5),
    )..volume = volume;
    unitsCH4.add(gasUnit);
    totalCH4created += gasUnit.volume;
    unitSynthesis(unitsCH4, expectedNumberOfCH4units, GasType.ch4);
    if (updateText) updateCH4Text();
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
    final co2Volume = currentTotalCO2Volume;
    game.currentCO2Value.value = co2Volume.round();
    final pollution =
        co2Volume * multiplierCO2 + currentTotalCH4Volume * multiplierCH4;
    game.pollutionPercentage.value =
        (pollution / maxAllowablePollution * 100).round();
  }

  void updateCH4Text() {
    final ch4Volume = currentTotalCH4Volume;
    game.currentCH4Value.value = ch4Volume.round();
    final pollution =
        currentTotalCO2Volume * multiplierCO2 + ch4Volume * multiplierCH4;
    game.pollutionPercentage.value =
        (pollution / maxAllowablePollution * 100).round();
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
