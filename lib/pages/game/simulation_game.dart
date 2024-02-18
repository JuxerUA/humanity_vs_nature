import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/components/bulldozer_component.dart';
import 'package:humanity_vs_nature/pages/game/components/city_component.dart';
import 'package:humanity_vs_nature/pages/game/components/combine_component.dart';
import 'package:humanity_vs_nature/pages/game/components/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/models/dot.dart';
import 'package:humanity_vs_nature/pages/game/models/dot_type.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/field_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/gas/gas_module.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_module.dart';

class SimulationGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  static const double maxTreeSpawnTime = 20;
  static const double dotSpacing = 10;

  final List<CityComponent> cities = [];
  final List<FarmComponent> farms = [];
  final List<BulldozerComponent> bulldozers = [];
  final List<CombineComponent> combines = [];

  late List<List<DotType>> _dots;
  late int dotsCountX;
  late int dotsCountY;

  final fieldModule = FieldModule();
  final treeModule = TreeModule();
  final gasModule = GasModule();

  final textCO2 = TextComponent(text: 'CO2: 0')..position = Vector2(15, 40);
  final textCH4 = TextComponent(text: 'CH4: 0')..position = Vector2(160, 40);

  var _timeForSpawnTree = 0.0;
  Vector2? _positionForSpawnTree;

  DotType getDotType(Dot dot) => _dots[dot.x][dot.y];

  void setDotType(Dot dot, DotType type) => _dots[dot.x][dot.y] = type;

  void setDotTypeByXY(int x, int y, DotType type) => _dots[x][y] = type;

  bool fieldCanReplaceDot(Dot dot) {
    final type = getDotType(dot);
    return type == DotType.none ||
        type == DotType.tree ||
        type == DotType.fieldPartial ||
        type == DotType.fieldFull;
  }

  @override
  FutureOr<void> onLoad() async {
    dotsCountX = size.x ~/ dotSpacing;
    dotsCountY = size.y ~/ dotSpacing;
    _dots = List.generate(
      dotsCountX,
          (_) => List<DotType>.filled(dotsCountY, DotType.none),
    );

    add(fieldModule);
    final city1 = CityComponent()..position = Vector2(size.x / 2, size.y / 4);
    final city2 = CityComponent()
      ..position = Vector2(size.x / 2, size.y / 4 * 3);
    cities.addAll([city1, city2]);
    await addAll(cities);
    markDotsForSpot(city1.spot, DotType.city);
    markDotsForSpot(city2.spot, DotType.city);
    add(treeModule);

    await treeModule.spawnInitialTrees();
    add(gasModule);
    add(textCO2);
    add(textCH4);

    // final skillsArtboard = await loadArtboard(RiveFile.asset(Assets.riveTest));
    // add(TestRiveComponent(skillsArtboard)..position = size / 2);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _trySpawnTree(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _timeForSpawnTree /= 2;
    _positionForSpawnTree = event.canvasPosition;
  }

  void addDebugDot(
    Dot dot, [
    double radius = 1,
    Color color = Colors.white,
  ]) {
    addDebugPoint(
      dot.position,
      radius,
      color,
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

  bool isEmptyDot(Dot dot) {
    return !(dot.x < 0 ||
        dot.x >= dotsCountX ||
        dot.y < 0 ||
        dot.y >= dotsCountY ||
        getDotType(dot) != DotType.none);
  }

  void _trySpawnTree(double dt) {
    _timeForSpawnTree -= dt;
    if (_timeForSpawnTree < 0) {
      _timeForSpawnTree = randomFallback.nextDouble() * maxTreeSpawnTime;
      //todo add constraints
      treeModule.addTree(_positionForSpawnTree);
      _positionForSpawnTree = null;
    }
  }

  List<Dot> markDotsForSpot(Spot spot, DotType type) {
    final dots = getDotsForSpot(spot);
    for (final dot in dots) {
      setDotType(dot, type);
    }
    return dots;
  }

  List<Dot> getDotsForSpot(Spot spot) {
    final radius2 = spot.radius * spot.radius;

    final firstDotX = max(
      0,
      ((spot.position.x - spot.radius) / dotSpacing).ceil(),
    );
    final lastDotX = min(
      dotsCountX - 1,
      ((spot.position.x + spot.radius) / dotSpacing).floor(),
    );
    final firstDotY = max(
      0,
      ((spot.position.y - spot.radius) / dotSpacing).ceil(),
    );
    final lastDotY = min(
      dotsCountY - 1,
      ((spot.position.y + spot.radius) / dotSpacing).floor(),
    );

    final spotDots = <Dot>[];
    for (var x = firstDotX; x <= lastDotX; x++) {
      for (var y = firstDotY; y <= lastDotY; y++) {
        final dotPosition = Vector2(x.toDouble(), y.toDouble()) * dotSpacing;
        final distance2 = dotPosition.distanceToSquared(spot.position);
        if (distance2 <= radius2) {
          spotDots.add(Dot(x, y));
        }
      }
    }

    return spotDots;
  }

  List<Dot> markDotsForField(FieldComponent field) {
    var firstDotX = dotsCountX;
    var lastDotX = 0;
    var firstDotY = dotsCountY;
    var lastDotY = 0;

    for (final dot in field.vertexDots) {
      if (dot.x < firstDotX) firstDotX = dot.x;
      if (dot.x > lastDotX) lastDotX = dot.x;
      if (dot.y < firstDotY) firstDotY = dot.y;
      if (dot.y > lastDotY) lastDotY = dot.y;
    }

    firstDotX = max(0, firstDotX);
    lastDotX = min(dotsCountX - 1, lastDotX);
    firstDotY = max(0, firstDotY);
    lastDotY = min(dotsCountY - 1, lastDotY);

    /// Finding all the field's dots
    final markedDots = <Dot>[];
    for (var x = firstDotX; x <= lastDotX; x++) {
      for (var y = firstDotY; y <= lastDotY; y++) {
        final dot = Dot(x, y);
        if (field.containsDot(dot)) {
          markedDots.add(dot);
          if (fieldCanReplaceDot(dot)) {
            setDotType(dot, DotType.fieldFull);
          }
        }
      }
    }

    /// Setting fieldPartial dots
    for (final dot in markedDots) {
      if (field.isEdgeDot(dot) &&
          (isEmptyDot(dot.leftDot) ||
              isEmptyDot(dot.rightDot) ||
              isEmptyDot(dot.topDot) ||
              isEmptyDot(dot.bottomDot))) {
        setDotType(dot, DotType.fieldPartial);
      }
    }

    return markedDots;
  }

  void addBulldozer(PositionComponent owner) {
    final bulldozer = BulldozerComponent(base: owner)
      ..position = owner.position;
    bulldozers.add(bulldozer);
    add(bulldozer);
  }

  void removeBulldozer(BulldozerComponent bulldozer) {
    remove(bulldozer);
    bulldozers.remove(bulldozer);
  }

  void addCombine(CityComponent owner) {
    final targetPlace =
        findNearestFreeSpot(owner.position, FarmComponent.requiredSpotRadius);
    if (targetPlace != null) {
      final combine = CombineComponent(owner: owner, targetPlace: targetPlace)
        ..position = owner.position;
      combines.add(combine);
      add(combine);
    }
  }

  void removeCombine(CombineComponent combine) {
    remove(combine);
    combines.remove(combine);
  }

  void addFarm(Vector2 position, CityComponent owner) {
    final farm = FarmComponent(owner: owner)..position = position;
    farms.add(farm);
    add(farm);
    fieldModule.addFirstFarmField(position);
  }

  void removeFarm(FarmComponent farm) {
    remove(farm);
    farms.remove(farm);
    markDotsForSpot(farm.spot, DotType.none);
  }

  Vector2? findNearestFreeSpot(
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

    /// Check other spots
    final spots = [
      ...cities.map((e) => e.spot),
      ...farms.map((e) => e.spot),
      ...treeModule.spots,
    ];
    for (final spot in spots) {
      //todo maybe should use distanceToSquared for additional optimisation
      if (position.distanceTo(spot.position) < spot.radius + radius) {
        return false;
      }
    }

    /// Check fields by dots
    final dots = getDotsForSpot(Spot(position, radius));
    for (final dot in dots) {
      if (getDotType(dot).isField) return false;
    }

    return true;
  }
}
