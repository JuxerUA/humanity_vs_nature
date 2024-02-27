import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/bulldozer/bulldozer_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/city/city_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/combine/combine_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/farm/farm_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/field_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/gas/gas_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/blocks_matrix.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_module.dart';
import 'package:humanity_vs_nature/pages/game/playing_field.dart';
import 'package:humanity_vs_nature/pages/overlays/game_interface_overlay.dart';

class SimulationGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks {
  static const gameBackgroundColor = Colors.lightBlueAccent;
  static const double blockSize = 10;

  late BlocksMatrix matrix;

  Vector2 worldSize = Vector2(600, 600);

  static late final Artboard waterArtboard;

  final playingField = PlayingField();
  final cityModule = CityModule();
  final fieldModule = FieldModule();
  final treeModule = TreeModule();
  final farmModule = FarmModule();
  final bulldozerModule = BulldozerModule();
  final combineModule = CombineModule();
  final gasModule = GasModule();

  final ValueNotifier<double> currentCO2Value = ValueNotifier(0);
  final ValueNotifier<double> currentCH4Value = ValueNotifier(0);

  @override
  FutureOr<void> onLoad() async {
    matrix = BlocksMatrix(worldSize);

    world
      ..add(playingField)
      ..add(fieldModule)
      ..add(treeModule)
      ..add(bulldozerModule)
      ..add(combineModule)
      ..add(farmModule)
      ..add(cityModule)
      ..add(gasModule);

    await treeModule.spawnInitialTrees();

    overlays.add(GameInterfaceOverlay.overlayName);

    final cameraBoundsOffset = worldSize.x * 0.1;
    camera
      ..moveTo(worldSize / 2)
      ..setBounds(
        Rectangle.fromLTRB(
          cameraBoundsOffset,
          cameraBoundsOffset,
          worldSize.x - cameraBoundsOffset,
          worldSize.y - cameraBoundsOffset,
        ),
      );

    // waterArtboard = await loadArtboard(RiveFile.asset(Assets.riveWater));
    //
    // add(TestRiveComponent()
    //   ..position = Vector2.zero()
    //   ..size = Vector2(worldSize.x, worldSize.y / 2));
    //
    // add(TestRiveComponent()
    //   ..position = Vector2(0, worldSize.y / 2)
    //   ..size = Vector2(worldSize.x, worldSize.y / 2));

    await Future.delayed(const Duration(seconds: 2));

    return super.onLoad();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    camera.moveBy(event.localDelta.inverted());
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

  Vector2? getNearestFreeSpot(
    Vector2 targetPosition,
    double objectRadius, {
    double? maxDistance,
    bool ignoreBlocks = false,
  }) {
    final stepSize = objectRadius / 10;
    final searchRadius = maxDistance ?? objectRadius * 10;

    for (var distance = 0.0; distance <= searchRadius; distance += stepSize) {
      final freeSpotsOnTheLevel = <Vector2>[];
      for (var angle = 0.0; angle < 2 * pi; angle += 0.1) {
        final x = targetPosition.x + distance * cos(angle);
        final y = targetPosition.y + distance * sin(angle);

        final potentialSpot = Vector2(x, y);
        if (isSpotFree(
          potentialSpot,
          objectRadius,
          ignoreBlocks: ignoreBlocks,
        )) {
          freeSpotsOnTheLevel.add(potentialSpot);
        }
      }

      if (freeSpotsOnTheLevel.isNotEmpty) {
        return freeSpotsOnTheLevel.random();
      }
    }

    return null;
  }

  bool isSpotFree(
    Vector2 position,
    double radius, {
    bool ignoreBlocks = false,
  }) {
    /// Check playing field boards
    final smallerRadius = radius * 0.6;
    if (position.x - smallerRadius < 0 ||
        position.x + smallerRadius > worldSize.x ||
        position.y - smallerRadius < 0 ||
        position.y + smallerRadius > worldSize.y) {
      return false;
    }

    /// Check fields by blocks
    if (!ignoreBlocks) {
      final blocks = matrix.getBlocksForSpot(Spot(position, radius));
      for (final block in blocks) {
        if (matrix.getBlockType(block) == BlockType.field) return false;
      }
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
