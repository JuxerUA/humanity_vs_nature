import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class TreeModule extends Component with HasGameRef<SimulationGame> {
  final List<TreeComponent> _trees = [];

  List<TreeComponent> get trees => _trees;

  Iterable<Spot> get spots => _trees.map((e) => e.spot);

  @override
  FutureOr<void> onLoad() async {
    spawnInitialTrees();
  }

  /// Spawn initial mature trees
  void spawnInitialTrees() {
    for (var i = 0; i < 4; i++) {
      late Vector2 position;
      do {
        position = Vector2(
          game.worldSize.x * randomFallback.nextDouble(),
          game.worldSize.y * randomFallback.nextDouble(),
        );
      } while (!game.isSpotFree(position, TreeComponent.radius));
      _trees.add(TreeComponent(isMature: true)..position = position);
    }
    addAll(_trees);
    for (final tree in _trees) {
      game.matrix.markBlocksForSpot(tree.spot, BlockType.tree);
    }
  }

  void addTree(Vector2 position) {
    final tree = TreeComponent()..position = position;
    _trees.add(tree);
    add(tree);
    game.matrix.markBlocksForSpot(tree.spot, BlockType.tree);
  }

  void removeTree(TreeComponent tree) {
    remove(tree);
    _trees.remove(tree);
    game.matrix.markBlocksForSpot(tree.spot, BlockType.empty);
  }

  void expandForest(Vector2 position) {
    final tree = findNearestMatureTree(position);
    if (tree != null) {
      final spawnPosition =
          game.getNearestFreeSpot(tree.position, TreeComponent.radius, 35);
      if (spawnPosition != null) {
        addTree(spawnPosition);
      }
    }
  }

  TreeComponent? findNearestTree(
    Vector2 targetPosition, [
    List<TreeComponent>? treeList,
  ]) {
    TreeComponent? nearestTree;
    var minDistance = double.infinity;

    final list = treeList ?? _trees;
    for (final tree in list) {
      final distance = tree.position.distanceTo(targetPosition);

      if (distance < minDistance) {
        minDistance = distance;
        nearestTree = tree;
      }
    }

    return nearestTree;
  }

  TreeComponent? findNearestMatureTree(Vector2 position) {
    TreeComponent? nearestMatureTree;
    var nearestDistance = double.infinity;
    for (final tree in _trees) {
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

  TreeComponent? findFreeMatureNearestTree(Vector2 targetPosition) {
    final reservedTrees = <TreeComponent>[];
    for (final bulldozer in game.bulldozerModule.bulldozers) {
      final targetTree = bulldozer.targetTree;
      if (targetTree != null) {
        reservedTrees.add(targetTree);
      }
    }

    final freeMatureTrees = _trees
        .where((tree) => tree.isMature && !reservedTrees.contains(tree))
        .toList();
    return findNearestTree(targetPosition, freeMatureTrees) ??
        findNearestTree(targetPosition, reservedTrees);
  }
}
