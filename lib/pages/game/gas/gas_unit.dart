import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class GasUnit {
  GasUnit(this.position, this.velocity) {
    _updateRadius();
  }

  static const defaultVolume = 1.0;

  Vector2 position;
  Vector2 velocity;
  double _volume = defaultVolume;
  double radius = 1;

  double get volume => _volume;

  set volume(double value) {
    _volume = value > 0 ? value : 0;
    _updateRadius();
  }

  void render(Canvas canvas) {
    canvas.drawCircle(
      position.toOffset(),
      radius,
      Paint()..color = Colors.indigo,
    );
  }

  void update(double dt, SimulationGame game) {
    position += velocity * dt;
    velocity *= pow(0.9, dt).toDouble();

    // TODO no need to calculate it every time
    final minHalfScreen =
        game.size.x < game.size.y ? game.size.x / 2 : game.size.y / 2;
    final leftSide = minHalfScreen;
    final rightSide = game.size.x - minHalfScreen;
    final topSide = minHalfScreen;
    final bottomSide = game.size.y - minHalfScreen;

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

  void _updateRadius() => radius = sqrt(_volume / pi);
}
