import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class PlayingField extends RectangleComponent
    with HasGameRef<SimulationGame>, TapCallbacks {
  static const double maxTreeSpawnTime = 20;
  static const Color grassColor = Colors.lightGreen;

  var _timeForSpawnTree = 0.0;
  Vector2? _preferredPositionForSpawnTree;

  @override
  FutureOr<void> onLoad() {
    size = game.worldSize;
    paint = Paint()
      ..color = grassColor
      ..style = PaintingStyle.fill;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _trySpawnTree(dt);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    _timeForSpawnTree /= 2;
    _preferredPositionForSpawnTree =
        game.camera.globalToLocal(event.canvasPosition);
  }

  void _trySpawnTree(double dt) {
    _timeForSpawnTree -= dt;
    if (_timeForSpawnTree < 0) {
      _timeForSpawnTree = randomFallback.nextDouble() * maxTreeSpawnTime;
      final targetPosition = _preferredPositionForSpawnTree ??
          Vector2(
            size.x * randomFallback.nextDouble(),
            size.y * randomFallback.nextDouble(),
          );
      final treePosition = game.getNearestFreeSpot(
        targetPosition,
        TreeComponent.radius,
      );
      if (treePosition != null) {
        game.treeModule.addTree(treePosition);
      }
      _preferredPositionForSpawnTree = null;
    }
  }
}
