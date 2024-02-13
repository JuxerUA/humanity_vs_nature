import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:humanity_vs_nature/extensions/sprite_component_extension.dart';
import 'package:humanity_vs_nature/pages/game/components/bulldozer_component.dart';
import 'package:humanity_vs_nature/pages/game/components/city_component.dart';
import 'package:humanity_vs_nature/pages/game/components/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/components/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/gas/gas_system.dart';

class SimulationGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  static const double maxTreeSpawnTime = 20;

  final List<TreeComponent> trees = [];
  final List<CityComponent> cities = [];
  final List<FarmComponent> farms = [];
  final List<BulldozerComponent> bulldozers = [];

  final gasSystem = GasSystem();
  final textCO2 = TextComponent(text: 'CO2: 0')..position = Vector2(15, 40);
  final textCH4 = TextComponent(text: 'CH4: 0')..position = Vector2(160, 40);

  var _timeForSpawnTree = 0.0;
  Vector2? _positionForSpawnTree;

  @override
  FutureOr<void> onLoad() {
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

    final city1 = CityComponent()..position = Vector2(size.x / 2, size.y / 4);
    final city2 = CityComponent()
      ..position = Vector2(size.x / 2, size.y / 4 * 3);
    cities.addAll([city1, city2]);
    addAll(trees);
    addAll(cities);
    add(gasSystem);
    add(textCO2);
    add(textCH4);

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

  void _trySpawnTree(double dt) {
    _timeForSpawnTree -= dt;
    if (_timeForSpawnTree < 0) {
      _timeForSpawnTree = Random().nextDouble() * maxTreeSpawnTime;
      //todo add constraints
      _addTree(_positionForSpawnTree);
      _positionForSpawnTree = null;
    }
  }

  void expandForest(Vector2 position) {
    final tree = findNearestMatureTree(position);
    if (tree != null) {
      final spawnPosition =
          findNearestFreeSpot(tree.position, TreeComponent.radius);
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

  void removeTree(TreeComponent tree) {
    remove(tree);
    trees.remove(tree);
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

  Vector2? findNearestFreeSpot(Vector2 targetPosition, double objectRadius) {
    final stepSize = objectRadius / 10;
    final searchRadius = objectRadius * 10;

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
    final smallerRadius = radius * 0.6;
    if (position.x - smallerRadius < 0 ||
        position.x + smallerRadius > size.x ||
        position.y - smallerRadius < 0 ||
        position.y + smallerRadius > size.y) {
      return false;
    }

    final spots = [
      ...cities.map((e) => e.spot),
      ...trees.map((e) => e.spot),
    ];
    for (final spot in spots) {
      if (position.distanceTo(spot.position) < spot.radius + radius) {
        return false;
      }
    }

    return true;
  }
}
