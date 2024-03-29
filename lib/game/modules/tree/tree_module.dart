import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

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
      final numberOfTreesInTheForest = 1 + randomFallback.nextInt(10);
      trees.add(TreeComponent(isMature: true)..position = position);
      for (var j = 1; j < numberOfTreesInTheForest; j++) {
        final spawnPosition = game.getNearestFreeSpot(
          position,
          TreeComponent.radius,
          maxDistance: 35,
        );
        if (spawnPosition != null) {
          trees.add(TreeComponent(isMature: true)..position = spawnPosition);
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
    const findMatureTreesRadius2 = 30 * 30;
    final matureTrees = <TreeComponent>[];
    for (final tree in trees) {
      if (tree.isMature &&
          tree.position.distanceToSquared(position) < findMatureTreesRadius2) {
        matureTrees.add(tree);
      }
    }
    matureTrees.sort((a, b) => a.position
        .distanceToSquared(position)
        .compareTo(b.position.distanceToSquared(position)));

    for (final matureTree in matureTrees) {
      final spawnPosition = game.getNearestFreeSpot(
        matureTree.position,
        TreeComponent.radius,
        maxDistance: 35,
      );
      if (spawnPosition != null) {
        matureTree.shakeTheTree();
        addTree(spawnPosition);
        return;
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
      final distance = tree.position.distanceToSquared(targetPosition);

      if (distance < minDistance) {
        minDistance = distance;
        nearestTree = tree;
      }
    }

    return nearestTree;
  }

  TreeComponent? findNearestMatureTree(Vector2 targetPosition) {
    return findNearestTree(
      targetPosition,
      trees.where((tree) => tree.isMature).toList(),
    );
  }

  TreeComponent? findFreeNearestTree(
    Vector2 targetPosition, [
    List<TreeComponent>? treeList,
  ]) {
    final reservedTrees = <TreeComponent>[];
    for (final bulldozer in game.bulldozerModule.bulldozers) {
      final targetTree = bulldozer.targetTree;
      if (targetTree != null) {
        reservedTrees.add(targetTree);
      }
    }

    final freeTrees = (treeList ?? trees)
        .where((tree) => !reservedTrees.contains(tree))
        .toList();
    return findNearestTree(targetPosition, freeTrees);
  }

  TreeComponent? findFreeMatureNearestTree(Vector2 targetPosition) {
    return findFreeNearestTree(
      targetPosition,
      trees.where((tree) => tree.isMature).toList(),
    );
  }

  bool isThereAnyTreesAtTheSpot(Spot spot) {
    final distance = spot.radius - TreeComponent.radius;
    final distance2 = distance * distance;
    for (final tree in trees) {
      if (tree.position.distanceToSquared(spot.position) < distance2) {
        return true;
      }
    }
    return false;
  }
}
