import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/gas/gas_type.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class GasUnit {
  GasUnit(this.type, this.position, this.velocity) {
    _updateRadius();
  }

  static const defaultVolume = 1.0;

  GasType type;
  Vector2 position;
  Vector2 velocity;

  double _volume = defaultVolume;
  double _radius = 1;

  double get volume => _volume;

  set volume(double value) {
    _volume = value > 0 ? value : 0;
    _updateRadius();
  }

  void render(Canvas canvas) {
    canvas.drawCircle(
      position.toOffset(),
      _radius,
      Paint()..color = type.color,
    );
  }

  void update(double dt, SimulationGame game) {
    position += velocity * dt;
    velocity *= pow(0.9, dt).toDouble();

    // TODO no need to calculate it every time
    final minHalfScreen = game.worldSize.x < game.worldSize.y
        ? game.worldSize.x / 2
        : game.worldSize.y / 2;
    final leftSide = minHalfScreen;
    final rightSide = game.worldSize.x - minHalfScreen;
    final topSide = minHalfScreen;
    final bottomSide = game.worldSize.y - minHalfScreen;

    if (position.x < leftSide) {
      velocity.x += (leftSide - position.x) / minHalfScreen * dt;
    } else if (position.x > rightSide) {
      velocity.x += (rightSide - position.x) / minHalfScreen * dt;
    }

    if (position.y < topSide) {
      velocity.y += (topSide - position.y) / minHalfScreen * dt;
    } else if (position.x > bottomSide) {
      velocity.y += (bottomSide - position.y) / minHalfScreen * dt;
    }
  }

  void addVolume(double value) {
    _volume += value;
    _updateRadius();
  }

  void _updateRadius() => _radius = sqrt(_volume / pi);
}
