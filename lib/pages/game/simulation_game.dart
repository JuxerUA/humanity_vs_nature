import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/math.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/components/test_rive_component.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/bulldozer/bulldozer_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/city/city_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/combine/combine_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/farm/farm_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/field_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/gas/gas_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/blocks_matrix.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_module.dart';
import 'package:humanity_vs_nature/pages/overlays/pause_menu_overlay.dart';

class SimulationGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  static const double maxTreeSpawnTime = 20;
  static const double blockSize = 10;

  late BlocksMatrix matrix;

  static late final Artboard waterArtboard;

  final cityModule = CityModule();
  final fieldModule = FieldModule();
  final treeModule = TreeModule();
  final farmModule = FarmModule();
  final bulldozerModule = BulldozerModule();
  final combineModule = CombineModule();
  final gasModule = GasModule();

  final textCO2 = TextComponent(text: 'CO2: 0')..position = Vector2(15, 40);
  final textCH4 = TextComponent(text: 'CH4: 0')..position = Vector2(160, 40);

  var _timeForSpawnTree = 0.0;
  Vector2? _preferredPositionForSpawnTree;

  @override
  FutureOr<void> onLoad() async {
    matrix = BlocksMatrix(size);

    add(fieldModule);
    add(treeModule);
    add(bulldozerModule);
    add(combineModule);
    add(farmModule);
    add(cityModule);
    add(gasModule);
    add(textCO2);
    add(textCH4);

    // waterArtboard = await loadArtboard(RiveFile.asset(Assets.riveWater));
    //
    // add(TestRiveComponent()
    //   ..position = Vector2.zero()
    //   ..size = Vector2(size.x, size.y / 2));
    //
    // add(TestRiveComponent()
    //   ..position = Vector2(0, size.y / 2)
    //   ..size = Vector2(size.x, size.y / 2));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _trySpawnTree(dt);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _timeForSpawnTree /= 2;
    _preferredPositionForSpawnTree = event.canvasPosition;

    add(TestRiveComponent()
      ..position = Vector2(0, size.y / 2)
      ..size = Vector2(size.x, size.y / 4));
  }

  void showPauseMenu() {
    overlays.add(PauseMenuOverlay.overlayName);
  }

  void addDebugBlock(
    Block block, [
    BlockType? type,
    Color color = Colors.white,
  ]) {
    add(
      RectangleComponent()
        ..position = matrix.getPosition(block)
        ..size = Vector2.all(matrix.blockSize)
        ..paint = (Paint()
          ..color = (type?.color ?? matrix.getBlockType(block).color)
              .withOpacity(0.5)),
    );
  }

  void addDebugPoint(
    Vector2 position, [
    double radius = 1,
    Color color = Colors.white,
  ]) {
    add(
      CircleComponent()
        ..position = (position - Vector2(radius / 2, radius / 2))
        ..radius = radius
        ..paint = (Paint()..color = color),
    );
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
      final treePosition = getNearestFreeSpot(
        targetPosition,
        TreeComponent.radius,
      );
      if (treePosition != null) {
        treeModule.addTree(treePosition);
      }
      _preferredPositionForSpawnTree = null;
    }
  }

  Vector2? getNearestFreeSpot(
    Vector2 targetPosition,
    double objectRadius, [
    double? maxDistance,
  ]) {
    final stepSize = objectRadius / 10;
    final searchRadius = maxDistance ?? objectRadius * 10;

    for (var distance = 0.0; distance <= searchRadius; distance += stepSize) {
      final freeSpotsOnTheLevel = <Vector2>[];
      for (var angle = 0.0; angle < 2 * pi; angle += 0.1) {
        final x = targetPosition.x + distance * cos(angle);
        final y = targetPosition.y + distance * sin(angle);

        final potentialSpot = Vector2(x, y);
        if (isSpotFree(potentialSpot, objectRadius)) {
          freeSpotsOnTheLevel.add(potentialSpot);
        }
      }

      if (freeSpotsOnTheLevel.isNotEmpty) {
        return freeSpotsOnTheLevel.random();
      }
    }

    return null;
  }

  bool isSpotFree(Vector2 position, double radius) {
    /// Check playing field boards
    final smallerRadius = radius * 0.6;
    if (position.x - smallerRadius < 0 ||
        position.x + smallerRadius > size.x ||
        position.y - smallerRadius < 0 ||
        position.y + smallerRadius > size.y) {
      return false;
    }

    /// Check fields by blocks
    final blocks = matrix.getBlocksForSpot(Spot(position, radius));
    for (final block in blocks) {
      if (matrix.getBlockType(block) == BlockType.field) return false;
    }

    /// Check other spots
    final spots = [
      ...cityModule.spots,
      ...farmModule.spots,
      ...treeModule.spots,
    ];
    for (final spot in spots) {
      final distance = spot.radius + radius;
      if (position.distanceToSquared(spot.position) < distance * distance) {
        return false;
      }
    }

    return true;
  }
}
