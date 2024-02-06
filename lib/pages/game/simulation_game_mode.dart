import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:humanity_vs_nature/extensions/sprite_component_extension.dart';
import 'package:humanity_vs_nature/pages/game/components/bulldozer_component.dart';
import 'package:humanity_vs_nature/pages/game/components/city_component.dart';
import 'package:humanity_vs_nature/pages/game/components/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/components/tree_component.dart';

class SimulationGameMode extends FlameGame with HasCollisionDetection {
  static const double maxTreeSpawnTime = 20;

  final List<TreeComponent> trees = [];
  final List<CityComponent> cities = [];
  final List<FarmComponent> farms = [];
  final List<BulldozerComponent> bulldozers = [];

  var _timeForSpawnTree = 0.0;

  @override
  FutureOr<void> onLoad() {
    trees.addAll(
      List.generate(5, (index) => TreeComponent()..setRandomPosition(size)),
    );
    cities.addAll(
      List.generate(2, (index) => CityComponent()..setRandomPosition(size)),
    );
    addAll(trees);
    addAll(cities);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _trySpawnTree(dt);
  }

  void _trySpawnTree(double dt) {
    _timeForSpawnTree -= dt;
    if (_timeForSpawnTree < 0) {
      _timeForSpawnTree = Random().nextDouble() * maxTreeSpawnTime;
      _addTree(null);
    }
  }

  void expandForest(Vector2 position) {
    const maxDistance = 10.0;
    final randomVector = Vector2.random() - Vector2.all(0.5);
    final newTreePosition =
        position + (randomVector.normalized() * maxDistance);
    _addTree(newTreePosition);
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

  TreeComponent? findFreeNearestTree(Vector2 targetPosition) {
    final reservedTrees = <TreeComponent>[];
    for (final bulldozer in bulldozers) {
      final targetTree = bulldozer.targetTree;
      if (targetTree != null) {
        reservedTrees.add(targetTree);
      }
    }

    final freeTrees =
        trees.where((tree) => !reservedTrees.contains(tree)).toList();
    return findNearestTree(targetPosition, freeTrees) ??
        findNearestTree(targetPosition, reservedTrees);
  }
}
