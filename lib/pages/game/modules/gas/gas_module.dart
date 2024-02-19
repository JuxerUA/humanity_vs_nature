import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/modules/gas/gas_unit.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

export 'gas_unit.dart';

class GasModule extends Component with HasGameRef<SimulationGame> {
  final List<GasUnit> _units = [];
  int updateIndex = 0;
  double currentBiggestGasVolume = GasUnit.defaultVolume;
  double totalCO2created = 0;
  double totalCO2absorbedByTheOcean = 0;

  @override
  void render(Canvas canvas) {
    for (final particle in _units) {
      particle.render(canvas);
    }
  }

  @override
  void update(double dt) {
    if (_units.isEmpty) {
      return;
    }

    for (final unit in _units) {
      unit.update(dt, game);
    }

    final maxLength =
        sqrt(game.size.x * game.size.x + game.size.y * game.size.y);
    for (var i = 0; i < _units.length; i++) {
      final particleI = _units[i];
      var resultVector = Vector2.zero();
      for (var j = i + 1; j < _units.length; j++) {
        final particleJ = _units[j];

        final direction = particleJ.position - particleI.position;
        // todo try to optimize the calculations with length2
        final length = direction.length;
        if (length < 50) {
          final intensity = (maxLength - length) / maxLength;
          resultVector += direction * intensity;
        }
      }

      particleI.velocity -= (resultVector..clampLength(0, 10)) *
          (particleI.volume / currentBiggestGasVolume) *
          dt;
    }

    if (totalCO2absorbedByTheOcean < totalCO2created * 0.3) {
      var minClearance = double.infinity;
      var minClearanceUnit = _units.first;
      for (final unit in _units) {
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
        totalCO2absorbedByTheOcean += getAUnitOfGasVolume(minClearanceUnit);
        game.textCH4.text =
            '${totalCO2absorbedByTheOcean.round()}/${totalCO2created.round()}';
      }
    }
  }

  void addGas(Vector2 position) {
    final velocity = Vector2(randomFallback.nextDouble() - 0.5, -10);
    final gasUnit = GasUnit(position, velocity);
    totalCO2created += gasUnit.volume;
    _units.add(gasUnit);
    unitSynthesis();
    updateTexts();
  }

  void removeGasUnit(GasUnit gasUnit) {
    _units.remove(gasUnit);
    unitDecomposition();
    updateTexts();
  }

  void unitSynthesis() {
    if (_units.length > 100) {
      var minValue = double.infinity;
      var particle1 = _units[0];
      var particle2 = _units[1];

      for (var i = 0; i < _units.length; i++) {
        for (var j = i + 1; j < _units.length; j++) {
          final particleI = _units[i];
          final particleJ = _units[j];

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
        _units.remove(particle2);
        if (particle1.volume > currentBiggestGasVolume) {
          currentBiggestGasVolume = particle1.volume;
        }
      } else {
        particle2.addVolume(particle1.volume);
        _units.remove(particle1);
        if (particle2.volume > currentBiggestGasVolume) {
          currentBiggestGasVolume = particle2.volume;
        }
      }
    }
  }

  void unitDecomposition() {
    if (_units.length < 100) {
      var biggestUnit = _units[0];
      var firstBiggestGasVolume = 0.0;
      var secondBiggestGasVolume = 0.0;
      for (var i = 0; i < _units.length; i++) {
        final unit = _units[i];
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
        biggestUnit.position - biggestUnit.velocity,
        -biggestUnit.velocity,
      )..volume = biggestUnit.volume;
      _units.add(newUnit);

      currentBiggestGasVolume = biggestUnit.volume > secondBiggestGasVolume
          ? biggestUnit.volume
          : secondBiggestGasVolume;
    }
  }

  void updateTexts() {
    final volumeCO2 = _units
        .map((e) => e.volume)
        .reduce((value, element) => value += element)
        .round();
    game.textCO2.text = 'CO2: $volumeCO2';
  }

  double aTreeWantsSomeCO2(Vector2 position, double dt) {
    const attractionDistance = 50;
    final leftSide = position.x - attractionDistance;
    final rightSide = position.x + attractionDistance;
    final topSide = position.y - attractionDistance;
    final bottomSide = position.y + attractionDistance;

    for (var i = 0; i < _units.length; i++) {
      final unit = _units[i];
      if (unit.position.x > leftSide &&
          unit.position.x < rightSide &&
          unit.position.y > topSide &&
          unit.position.y < bottomSide) {
        final direction = position - unit.position;
        final length = direction.normalize();
        unit.velocity += direction * 5 * dt;
        if (length < TreeComponent.radius) {
          return getAUnitOfGasVolume(unit);
        }
      }
    }

    return 0;
  }

  double getAUnitOfGasVolume(GasUnit gasUnit) {
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
