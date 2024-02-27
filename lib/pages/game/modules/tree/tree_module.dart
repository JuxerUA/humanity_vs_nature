import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/pages/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class TreeModule extends Component with HasGameRef<SimulationGame> {
  final List<TreeComponent> trees = [];

  TreeComponent? topmostTreeAddedDuringThisUpdate;

  Iterable<Spot> get spots => trees.map((e) => e.spot);

  @override
  void update(double dt) {
    final topmostTree = topmostTreeAddedDuringThisUpdate;
    if (topmostTree != null) {
      sortTreesByY(topmostTree);
      topmostTreeAddedDuringThisUpdate = null;
    }
    super.update(dt);
  }

  /// Spawn initial mature trees
  Future<void> spawnInitialTrees() async {
    for (var i = 0; i < 10; i++) {
      late Vector2 position;
      do {
        position = Vector2(
          game.worldSize.x * randomFallback.nextDouble(),
          game.worldSize.y * randomFallback.nextDouble(),
        );
      } while (!game.isSpotFree(position, TreeComponent.radius));

      /// Add forest
      final numberOfTreesInTheForest = 5 + randomFallback.nextInt(20);
      trees.add(TreeComponent(isMature: true)..position = position);
      for (var j = 1; j < numberOfTreesInTheForest; j++) {
        final spawnPosition = game.getNearestFreeSpot(
          position,
          TreeComponent.radius,
          maxDistance: 35,
        );
        if (spawnPosition != null) {
          trees.add(TreeComponent(isMature: true)..position = position);
          if (randomFallback.nextBool()) {
            position = spawnPosition;
          }
        }
      }
    }
    trees.sort((a, b) => a.position.y.compareTo(b.position.y));
    await addAll(trees);
    for (final tree in trees) {
      game.matrix.markBlocksForSpot(tree.spot, BlockType.tree);
    }
  }

  void addTree(Vector2 position, {bool isMature = false}) {
    final tree = TreeComponent(isMature: isMature)..position = position;
    trees.add(tree);
    add(tree);
    game.matrix.markBlocksForSpot(tree.spot, BlockType.tree);
    updateTopmostTree(tree);
  }

  void removeTree(TreeComponent tree) {
    remove(tree);
    trees.remove(tree);
    game.matrix.markBlocksForSpot(tree.spot, BlockType.empty);
  }

  void updateTopmostTree(TreeComponent tree) {
    final topmostTree = topmostTreeAddedDuringThisUpdate;
    if (topmostTree != null) {
      if (tree.position.y > topmostTree.position.y) {
        topmostTreeAddedDuringThisUpdate = tree;
      }
    } else {
      topmostTreeAddedDuringThisUpdate = tree;
    }
  }

  void sortTreesByY(TreeComponent tree) {
    trees.sort((a, b) => a.position.y.compareTo(b.position.y));
    final allTreesBelow = trees.where((e) => e.position.y > tree.position.y);
    removeWhere((e) => e is TreeComponent && e.position.y > tree.position.y);
    addAll(allTreesBelow);
  }

  void expandForest(Vector2 position) {
    final tree = findNearestMatureTree(position);
    if (tree != null) {
      final spawnPosition = game.getNearestFreeSpot(
        tree.position,
        TreeComponent.radius,
        maxDistance: 35,
      );
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

  TreeComponent? findFreeMatureNearestTree(Vector2 targetPosition) {
    final reservedTrees = <TreeComponent>[];
    for (final bulldozer in game.bulldozerModule.bulldozers) {
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
}
