import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/modules/gas/gas_type.dart';
import 'package:humanity_vs_nature/pages/game/modules/gas/gas_unit.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

export 'gas_unit.dart';

class GasModule extends Component with HasGameRef<SimulationGame> {
  static const expectedNumberOfCO2units = 100;
  static const expectedNumberOfCH4units = 20;

  final List<GasUnit> _unitsCO2 = [];
  final List<GasUnit> _unitsCH4 = [];

  double currentBiggestCO2Volume = GasUnit.defaultVolume;
  double currentBiggestCH4Volume = GasUnit.defaultVolume;
  double maxScreenLengthSquartedForDistribution = 0; //todo

  double totalCO2created = 0;
  double totalCO2absorbedByTheOcean = 0;
  double totalCH4created = 0;
  double totalCH4convertedToCO2 = 0;

  @override
  void render(Canvas canvas) {
    for (final unit in _unitsCO2) {
      unit.render(canvas);
    }
    for (final unit in _unitsCH4) {
      unit.render(canvas);
    }
  }

  @override
  void update(double dt) {
    if (_unitsCO2.isEmpty) {
      return;
    }

    for (final unit in _unitsCO2) {
      unit.update(dt, game);
    }

    for (final unit in _unitsCH4) {
      unit.update(dt, game);
    }

    gasDistribution(_unitsCO2, currentBiggestCO2Volume, dt);
    gasDistribution(_unitsCH4, currentBiggestCH4Volume, dt);

    if (totalCO2absorbedByTheOcean < totalCO2created * 0.3) {
      var minClearance = double.infinity;
      var minClearanceUnit = _unitsCO2.first;
      for (final unit in _unitsCO2) {
        final unitPosition = unit.position;

        final leftClearance = unitPosition.x;
        final topClearance = unitPosition.y;
        final rightClearance = game.size.x - unitPosition.x;
        final bottomClearance = game.size.y - unitPosition.y;

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
    //todo
    final maxLength =
        sqrt(game.size.x * game.size.x + game.size.y * game.size.y);
    for (var i = 0; i < units.length; i++) {
      final unitI = units[i];
      var resultVector = Vector2.zero();
      for (var j = i + 1; j < units.length; j++) {
        final unitJ = units[j];

        final direction = unitJ.position - unitI.position;
        final length = direction.length;
        if (length < 50) {
          final intensity = (maxLength - length) / maxLength;
          resultVector += direction * intensity;
        }
      }

      unitI.velocity -= (resultVector..clampLength(0, 10)) *
          (unitI.volume / biggestVolume) *
          dt;
    }
  }

  void addCO2(Vector2 position, [double volume = GasUnit.defaultVolume]) {
    final velocity = Vector2(randomFallback.nextDouble() - 0.5, -10);
    final gasUnit = GasUnit(GasType.co2, position, velocity)..volume = volume;
    _unitsCO2.add(gasUnit);
    totalCO2created += gasUnit.volume;
    unitSynthesis(_unitsCO2, expectedNumberOfCO2units, GasType.co2);
    updateCO2Text();
  }

  void addCH4(Vector2 position, [double volume = GasUnit.defaultVolume]) {
    final velocity = Vector2(randomFallback.nextDouble() - 0.5, -5);
    final gasUnit = GasUnit(GasType.ch4, position, velocity)..volume = volume;
    _unitsCH4.add(gasUnit);
    totalCH4created += gasUnit.volume;
    unitSynthesis(_unitsCH4, expectedNumberOfCH4units, GasType.ch4);
    updateCH4Text();
  }

  void removeGasUnit(GasUnit gasUnit) {
    final type = gasUnit.type;
    switch (type) {
      case GasType.co2:
        _unitsCO2.remove(gasUnit);
        unitDecomposition(_unitsCO2, expectedNumberOfCO2units, type);
        updateCO2Text();
      case GasType.ch4:
        _unitsCH4.remove(gasUnit);
        unitDecomposition(_unitsCH4, expectedNumberOfCH4units, type);
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
        if (volume > currentBiggestCO2Volume) {
          currentBiggestCO2Volume = volume;
        }
      case GasType.ch4:
        if (volume > currentBiggestCH4Volume) {
          currentBiggestCH4Volume = volume;
        }
    }
  }

  void updateCO2Text() {
    final volumeCO2 = _unitsCO2
        .map((e) => e.volume)
        .reduce((value, element) => value += element)
        .round();
    game.textCO2.text = 'CO2: $volumeCO2';
  }

  void updateCH4Text() {
    final volumeCH4 = _unitsCH4
        .map((e) => e.volume)
        .reduce((value, element) => value += element)
        .round();
    game.textCH4.text = 'CH4: $volumeCH4';
  }

  double aTreeWantsSomeCO2(Vector2 position, double dt) {
    const attractionDistance = 50;
    final leftSide = position.x - attractionDistance;
    final rightSide = position.x + attractionDistance;
    final topSide = position.y - attractionDistance;
    final bottomSide = position.y + attractionDistance;

    for (var i = 0; i < _unitsCO2.length; i++) {
      final unit = _unitsCO2[i];
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

  double _getSomeGasFromTheUnit(GasUnit gasUnit) {
    if (gasUnit.volume > 1) {
      gasUnit.volume -= 1;
      return 1;
    } else {
      final volume = gasUnit.volume;
      removeGasUnit(gasUnit);
      return volume;
    }
  }
}
