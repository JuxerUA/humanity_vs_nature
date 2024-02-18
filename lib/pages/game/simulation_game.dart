import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/sprite_component_extension.dart';
import 'package:humanity_vs_nature/pages/game/components/bulldozer_component.dart';
import 'package:humanity_vs_nature/pages/game/components/city_component.dart';
import 'package:humanity_vs_nature/pages/game/components/combine_component.dart';
import 'package:humanity_vs_nature/pages/game/components/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/components/field_component.dart';
import 'package:humanity_vs_nature/pages/game/components/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/gas/gas_system.dart';
import 'package:humanity_vs_nature/pages/game/models/dot.dart';
import 'package:humanity_vs_nature/pages/game/models/dot_type.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';

class SimulationGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  static const double maxTreeSpawnTime = 20;
  static const double dotSpacing = 10;

  final List<TreeComponent> trees = [];
  final List<CityComponent> cities = [];
  final List<FarmComponent> farms = [];
  final List<FieldComponent> fields = [];
  final List<BulldozerComponent> bulldozers = [];
  final List<CombineComponent> combines = [];

  late List<List<DotType>> _dots;
  late int dotsCountX;
  late int dotsCountY;

  final gasSystem = GasSystem();
  final textCO2 = TextComponent(text: 'CO2: 0')..position = Vector2(15, 40);
  final textCH4 = TextComponent(text: 'CH4: 0')..position = Vector2(160, 40);
  final fieldsLayer = PositionComponent();

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
    add(fieldsLayer);

    dotsCountX = size.x ~/ dotSpacing;
    dotsCountY = size.y ~/ dotSpacing;
    _dots = List.generate(
      dotsCountX,
      (_) => List<DotType>.filled(dotsCountY, DotType.none),
    );

    // Spawn default mature trees
    final random = Random();
    for (var i = 0; i < 4; i++) {
      late Vector2 position;
      do {
        position = Vector2(
          size.x * random.nextDouble(),
          size.y * random.nextDouble(),
        );
      } while (!isSpotFree(position, TreeComponent.radius));
      trees.add(TreeComponent(isMature: true)..position = position);
    }
    await addAll(trees);
    for (final tree in trees) {
      markDotsForSpot(tree.spot, DotType.tree);
    }

    final city1 = CityComponent()..position = Vector2(size.x / 2, size.y / 4);
    final city2 = CityComponent()
      ..position = Vector2(size.x / 2, size.y / 4 * 3);
    cities.addAll([city1, city2]);
    await addAll(cities);
    markDotsForSpot(city1.spot, DotType.city);
    markDotsForSpot(city2.spot, DotType.city);
    add(gasSystem);
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

  void debugDot(
    Dot dot, [
    double radius = 1,
    Color color = Colors.white,
  ]) {
    debugPoint(
      dot.position,
      radius,
      color,
    );
  }

  void debugPoint(
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
      _timeForSpawnTree = Random().nextDouble() * maxTreeSpawnTime;
      //todo add constraints
      _addTree(_positionForSpawnTree);
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

  void expandForest(Vector2 position) {
    final tree = findNearestMatureTree(position);
    if (tree != null) {
      final spawnPosition =
          findNearestFreeSpot(tree.position, TreeComponent.radius, 35);
      if (spawnPosition != null) {
        _addTree(spawnPosition);
      }
    }
  }

  TreeComponent? findNearestMatureTree(Vector2 position) {
    TreeComponent? nearestMatureTree;
    var nearestDistance = double.infinity;
    for (final tree in trees) {
      if (tree.isMature) {
        final distance = (tree.position - position).length2;
        if (distance < nearestDistance) {
          nearestMatureTree = tree;
          nearestDistance = distance;
        }
      }
    }
    return nearestMatureTree;
  }

  void _addTree(Vector2? position) {
    final tree = TreeComponent();
    final treePosition = position;
    if (treePosition != null) {
      tree.position = treePosition;
    } else {
      tree.setRandomPosition(size);
    }
    trees.add(tree);
    add(tree);
    markDotsForSpot(tree.spot, DotType.tree);
  }

  void addBulldozer(PositionComponent owner) {
    final bulldozer = BulldozerComponent(base: owner)
      ..position = owner.position;
    bulldozers.add(bulldozer);
    add(bulldozer);
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

  void addFarm(Vector2 position, CityComponent owner) {
    final farm = FarmComponent(owner: owner)..position = position;
    farms.add(farm);
    add(farm);
    final points = markDotsForSpot(farm.spot, DotType.farm);

    // Making the first farm's field of random shape
    // - the field must cover all the farm dots, but not to replace them
    final random = Random();
    const baseRadius = FarmComponent.radius * 1.2;
    const maxRandomLength = FarmComponent.radius * 0.4;
    double extraLength() => baseRadius + maxRandomLength * random.nextDouble();
    final fieldPositions = <Vector2>[
      Vector2(position.x - extraLength(), position.y - extraLength()),
      Vector2(position.x + extraLength(), position.y - extraLength()),
      Vector2(position.x + extraLength(), position.y + extraLength()),
      Vector2(position.x - extraLength(), position.y + extraLength()),
    ];
    addField(fieldPositions.map(Dot.fromPosition).toList());

    // if (points.isEmpty) return;
    // final pointsCenter = Vector2(
    //   points.map((e) => e.x).reduce((value, e) => value + e) / points.length,
    //   points.map((e) => e.y).reduce((value, e) => value + e) / points.length,
    // );
    // final pointsWithDistance2 = points
    //     .map((e) => (e, e.toVector2().distanceToSquared(pointsCenter)))
    //     .toList()
    //   ..sort((a, b) => b.$2.compareTo(a.$2));
    // final extremePoints = pointsWithDistance2.map((e) => e.$1).take(6);
    // final fourFarthestExtremePoints =
    //     findFarthestPoints(extremePoints.toList(), 4);
    //
    // final finalFiledPoints = <Dot>[];
    // for (final point in fourFarthestExtremePoints) {
    //   final directionVector = point.toVector2() - pointsCenter
    //     ..clampLength(FarmComponent.radius / dotSpacing,
    //         FarmComponent.radius / dotSpacing);
    //   final endPosition = point.toVector2() + directionVector;
    //   finalFiledPoints
    //       .add(Dot(endPosition.x.round(), endPosition.y.round()));
    // }
    // addField(finalFiledPoints);
  }

  List<Dot> findFarthestPoints(List<Dot> dots, int count) {
    double calculateAverageDistance(List<Dot> points) {
      var totalDistance = 0.0;

      for (var i = 0; i < points.length; i++) {
        for (var j = i + 1; j < points.length; j++) {
          totalDistance += points[i].distanceTo(points[j]);
        }
      }

      return totalDistance / (points.length * (points.length - 1) / 2);
    }

    var farthestPoints = <Dot>[];
    var maxAverageDistance = 0.0;

    for (var i = 0; i < dots.length; i++) {
      for (var j = i + 1; j < dots.length; j++) {
        for (var k = j + 1; k < dots.length; k++) {
          for (var l = k + 1; l < dots.length; l++) {
            final combination = <Dot>[dots[i], dots[j], dots[k], dots[l]];
            final averageDistance = calculateAverageDistance(combination);

            if (averageDistance > maxAverageDistance) {
              maxAverageDistance = averageDistance;
              farthestPoints = combination;
            }
          }
        }
      }
    }

    return farthestPoints;
  }

  void addField(List<Dot> dots) {
    /// Calculate field position
    var minX = size.x.ceil();
    var minY = size.y.ceil();
    for (final dot in dots) {
      if (dot.x < minX) minX = dot.x;
      if (dot.y < minY) minY = dot.y;
    }
    // todo maybe move to the FieldComponent constructor
    final position = Vector2(minX * dotSpacing, minY * dotSpacing);

    /// Create field
    final field = FieldComponent(
      dots.map((e) => e.position - position).toList(),
    )..position = position;
    fields.add(field);
    fieldsLayer.add(field);
    markDotsForField(field);
  }

  void expandField(Spot ownerSpot) {
    final firstDot = findNearestDotForField(ownerSpot.position);
    if (firstDot == null) {
      return;
    }

    final firstDotPos = firstDot.position;
    var directionVector = firstDotPos - ownerSpot.position
      ..clampLength(20, 50);
    directionVector += (Vector2.random() - Vector2.random()) * 10;
    final oppositePos = firstDotPos + directionVector;
    final oppositeDot = findNearestDotForField(oppositePos);
    //todo
  }

  Dot? findNearestDotForField(Vector2 position) {
    bool checkDot(Dot dot) {
      if (dot.x >= 0 &&
          dot.x < dotsCountX &&
          dot.y >= 0 &&
          dot.y < dotsCountY) {
        return getDotType(dot).isGoodDotForField;
      }
      return false;
    }

    var leftX = position.x ~/ dotSpacing;
    var rightX = leftX + 1;
    var topY = position.y ~/ dotSpacing;
    var bottomY = topY + 1;

    for (var level = 0; level < 30; level++) {
      final dotsOnTheLevel = <Dot>[];

      for (var x = leftX; x < rightX; x++) {
        final dot = Dot(x, topY);
        if (checkDot(dot)) {
          dotsOnTheLevel.add(dot);
        }
      }

      for (var y = topY; y < bottomY; y++) {
        final dot = Dot(rightX, y);
        if (checkDot(dot)) {
          dotsOnTheLevel.add(dot);
        }
      }

      for (var x = rightX; x > leftX; x--) {
        final dot = Dot(x, bottomY);
        if (checkDot(dot)) {
          dotsOnTheLevel.add(dot);
        }
      }

      for (var y = bottomY; y > topY; y--) {
        final dot = Dot(leftX, y);
        if (checkDot(dot)) {
          dotsOnTheLevel.add(dot);
        }
      }

      if (dotsOnTheLevel.isNotEmpty) {
        final fieldPartDots = dotsOnTheLevel
            .where((dot) => getDotType(dot) == DotType.fieldPartial)
            .toList();
        return fieldPartDots.isNotEmpty
            ? fieldPartDots.random()
            : dotsOnTheLevel.random();
      } else {
        leftX -= 1;
        rightX += 1;
        topY -= 1;
        bottomY += 1;
      }
    }

    return null;
  }

  void removeBulldozer(BulldozerComponent bulldozer) {
    remove(bulldozer);
    bulldozers.remove(bulldozer);
  }

  void removeCombine(CombineComponent combine) {
    remove(combine);
    combines.remove(combine);
  }

  void removeTree(TreeComponent tree) {
    remove(tree);
    trees.remove(tree);
    markDotsForSpot(tree.spot, DotType.none);
  }

  void removeFarm(FarmComponent farm) {
    remove(farm);
    farms.remove(farm);
    markDotsForSpot(farm.spot, DotType.none);
  }

  TreeComponent? findNearestTree(
    Vector2 targetPosition, [
    List<TreeComponent>? treeList,
  ]) {
    TreeComponent? nearestTree;
    var minDistance = double.infinity;

    final list = treeList ?? trees;
    for (final tree in list) {
      final distance = tree.position.distanceTo(targetPosition);

      if (distance < minDistance) {
        minDistance = distance;
        nearestTree = tree;
      }
    }

    return nearestTree;
  }

  TreeComponent? findFreeMatureNearestTree(Vector2 targetPosition) {
    final reservedTrees = <TreeComponent>[];
    for (final bulldozer in bulldozers) {
      final targetTree = bulldozer.targetTree;
      if (targetTree != null) {
        reservedTrees.add(targetTree);
      }
    }

    final freeMatureTrees = trees
        .where((tree) => tree.isMature && !reservedTrees.contains(tree))
        .toList();
    return findNearestTree(targetPosition, freeMatureTrees) ??
        findNearestTree(targetPosition, reservedTrees);
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
      ...trees.map((e) => e.spot),
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
