import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/bulldozer/bulldozer_module.dart';
import 'package:humanity_vs_nature/game/modules/city/city_module.dart';
import 'package:humanity_vs_nature/game/modules/combine/combine_module.dart';
import 'package:humanity_vs_nature/game/modules/farm/farm_module.dart';
import 'package:humanity_vs_nature/game/modules/field/field_module.dart';
import 'package:humanity_vs_nature/game/modules/gas/gas_module.dart';
import 'package:humanity_vs_nature/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/game/modules/matrix/blocks_matrix.dart';
import 'package:humanity_vs_nature/game/modules/tree/tree_module.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorial_module.dart';
import 'package:humanity_vs_nature/game/playing_field.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/generated/l10n.dart';
import 'package:humanity_vs_nature/pages/overlays/game_interface_overlay.dart';
import 'package:humanity_vs_nature/pages/overlays/you_lost_overlay.dart';
import 'package:humanity_vs_nature/pages/overlays/you_win_overlay.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class SimulationGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks, ScaleDetector {
  static const gameBackgroundColor = Colors.lightBlueAccent;
  static const double blockSize = 10;
  static const double timeToStopCountdown = 30.1;

  late BlocksMatrix matrix;

  Vector2 worldSize = Vector2(600, 600);

  late final S strings;

  late final Sprite spriteCone;
  late final Sprite spriteYoungTree;
  late final Sprite spriteMatureTree;
  late final Sprite spriteFarm;
  late final Sprite spriteCity;
  late final Sprite spriteBulldozer1;
  late final Sprite spriteBulldozer2;

  final playingField = PlayingField();
  final tutorial = TutorialModule();

  final cityModule = CityModule();
  final fieldModule = FieldModule();
  final treeModule = TreeModule();
  final farmModule = FarmModule();
  final bulldozerModule = BulldozerModule();
  final combineModule = CombineModule();
  final gasModule = GasModule();

  final ValueNotifier<int> currentCO2Value = ValueNotifier(0);
  final ValueNotifier<int> currentCH4Value = ValueNotifier(0);
  final ValueNotifier<int> pollutionPercentage = ValueNotifier(0);
  final ValueNotifier<int> awarenessPercentage = ValueNotifier(0);
  final ValueNotifier<int> countdownToLoss = ValueNotifier(0);

  double timerToLoss = timeToStopCountdown;

  @override
  FutureOr<void> onLoad() async {
    await Future.delayed(const Duration(seconds: 1));

    spriteCone = await getSpriteFromAsset(Assets.spritesCone);
    spriteMatureTree = await getSpriteFromAsset(Assets.spritesMatureTree);
    spriteYoungTree = await getSpriteFromAsset(Assets.spritesYoungTree);
    spriteFarm = await getSpriteFromAsset(Assets.spritesFarm);
    spriteCity = await getSpriteFromAsset(Assets.spritesCity);
    spriteBulldozer1 = await getSpriteFromAsset(Assets.spritesBulldozer1);
    spriteBulldozer2 = await getSpriteFromAsset(Assets.spritesBulldozer2);

    matrix = BlocksMatrix(worldSize);

    await world.addAll([
      matrix,
      playingField,
      fieldModule,
      treeModule,
      bulldozerModule,
      combineModule,
      farmModule,
      cityModule,
      gasModule,
    ]);

    await cityModule.spawnInitialCities();
    await farmModule.spawnInitialFarms();
    await fieldModule.spawnInitialFields();
    await treeModule.spawnInitialTrees();
    gasModule.spawnInitialGas();

    overlays.add(GameInterfaceOverlay.overlayName);
    add(tutorial);

    camera.moveTo(worldSize / 2);
    setCameraBounds();

    return super.onLoad();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (tutorial.showingTutorial == null) {
      camera.moveBy(event.localDelta.inverted());
    }
    super.onDragUpdate(event);
  }

  @override
  void update(double dt) {
    super.update(dt);

    /// Check win/lose conditions
    if (awarenessPercentage.value >= 100) {
      paused = true;
      overlays.add(YouWinOverlay.overlayName);
    } else {
      if (pollutionPercentage.value >= 100) {
        timerToLoss -= dt;
        if (timerToLoss <= 0) {
          paused = true;
          overlays.add(YouLostOverlay.overlayName);
        }
      } else {
        timerToLoss = timeToStopCountdown;
      }
      countdownToLoss.value = timerToLoss.ceil();
    }
  }

  void addDebugBlock(
    Block block, [
    BlockType? type,
    Color color = Colors.white,
  ]) {
    playingField.add(
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
    playingField.add(
      CircleComponent()
        ..position = (position - Vector2(radius / 2, radius / 2))
        ..radius = radius
        ..paint = (Paint()..color = color),
    );
  }

  void setCameraBounds({bool tutorialBounds = false}) {
    final cameraBoundsOffset =
        tutorialBounds ? worldSize.x * 2 : worldSize.x * 0.1;
    camera.setBounds(
      Rectangle.fromLTRB(
        cameraBoundsOffset,
        cameraBoundsOffset,
        worldSize.x - cameraBoundsOffset,
        worldSize.y - cameraBoundsOffset,
      ),
    );
  }

  Vector2? getNearestFreeSpot(
    Vector2 targetPosition,
    double objectRadius, {
    double? maxDistance,
    bool ignoreFields = false,
  }) {
    final stepSize = objectRadius / 4;
    final searchRadius = maxDistance ?? objectRadius * 10;

    final angleOffset = randomFallback.nextDouble();
    final maxAngle = 2 * pi + angleOffset;
    const angleStep = pi / 3;
    for (var distance = 0.0; distance <= searchRadius; distance += stepSize) {
      final freeSpotsOnTheLevel = <Vector2>[];
      for (var angle = angleOffset; angle < maxAngle; angle += angleStep) {
        final x = targetPosition.x + distance * cos(angle);
        final y = targetPosition.y + distance * sin(angle);

        final potentialSpot = Vector2(x, y);
        if (isSpotFree(
          potentialSpot,
          objectRadius,
          ignoreFields: ignoreFields,
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
    bool ignoreFields = false,
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
    if (!ignoreFields) {
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
