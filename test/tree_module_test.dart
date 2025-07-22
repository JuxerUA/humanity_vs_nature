import 'package:test/test.dart';
import 'package:flame/components.dart';
import 'package:humanity_vs_nature/game/modules/tree/tree_module.dart';
import 'package:humanity_vs_nature/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';

class _FakeMatrix {
  Spot? lastSpot;
  BlockType? lastType;

  void markBlocksForSpot(Spot spot, BlockType type) {
    lastSpot = spot;
    lastType = type;
  }
}

class _FakeBulldozer {
  TreeComponent? targetTree;
  _FakeBulldozer({this.targetTree});
}

class _FakeBulldozerModule {
  List<_FakeBulldozer> bulldozers = [];
}

class _FakeGame {
  final worldSize = Vector2.all(100);
  final _FakeMatrix matrix = _FakeMatrix();
  final _FakeBulldozerModule bulldozerModule = _FakeBulldozerModule();

  TreeModule treeModule = TreeModule();

  Vector2? Function(Vector2, double, {double? maxDistance, bool ignoreFields})?
      onGetNearestFreeSpot;
  bool Function(Vector2, double, {bool ignoreFields})? onIsSpotFree;

  _FakeGame() {
    treeModule.gameRef = this;
  }

  Vector2? getNearestFreeSpot(Vector2 targetPosition, double objectRadius,
      {double? maxDistance, bool ignoreFields = false}) {
    return onGetNearestFreeSpot?.call(targetPosition, objectRadius,
        maxDistance: maxDistance, ignoreFields: ignoreFields);
  }

  bool isSpotFree(Vector2 position, double radius,
      {bool ignoreFields = false}) {
    return onIsSpotFree?.call(position, radius, ignoreFields: ignoreFields) ??
        true;
  }
}

void main() {
  group('TreeModule', () {
    test('addTree adds a tree and marks matrix', () {
      final game = _FakeGame();
      final module = game.treeModule;
      final position = Vector2(5, 5);

      module.addTree(position);

      expect(module.trees.length, 1);
      expect(module.trees.first.position, position);
      expect(game.matrix.lastSpot?.position, position);
      expect(game.matrix.lastType, BlockType.tree);
    });

    test('removeTree removes tree and updates matrix', () {
      final game = _FakeGame();
      final module = game.treeModule;
      final position = Vector2(10, 10);

      module.addTree(position);
      final tree = module.trees.first;

      module.removeTree(tree);

      expect(module.trees.isEmpty, isTrue);
      expect(game.matrix.lastSpot?.position, position);
      expect(game.matrix.lastType, BlockType.empty);
    });

    test('findNearestTree returns closest tree', () {
      final game = _FakeGame();
      final module = game.treeModule;
      module.trees.addAll([
        TreeComponent(isMature: true)..position = Vector2.zero(),
        TreeComponent(isMature: true)..position = Vector2(4, 0),
      ]);

      final nearest = module.findNearestTree(Vector2(3, 0));

      expect(nearest, module.trees[1]);
    });

    test('findFreeNearestTree ignores reserved trees', () {
      final game = _FakeGame();
      final module = game.treeModule;
      final tree1 = TreeComponent(isMature: true)..position = Vector2(0, 0);
      final tree2 = TreeComponent(isMature: true)..position = Vector2(5, 0);
      module.trees.addAll([tree1, tree2]);
      game.bulldozerModule.bulldozers.add(_FakeBulldozer(targetTree: tree1));

      final nearest = module.findFreeNearestTree(Vector2.zero());

      expect(nearest, tree2);
    });

    test('expandForest adds tree near mature tree', () {
      final game = _FakeGame();
      final module = game.treeModule;
      final mature = TreeComponent(isMature: true)..position = Vector2(2, 2);
      module.trees.add(mature);

      game.onGetNearestFreeSpot = (_, __, {double? maxDistance, bool ignoreFields = false}) => Vector2(4, 4);

      module.expandForest(Vector2(2, 2));

      expect(module.trees.length, 2);
      expect(module.trees.last.position, Vector2(4, 4));
      expect(mature.scale.x > 1, isTrue);
    });
  });
}

