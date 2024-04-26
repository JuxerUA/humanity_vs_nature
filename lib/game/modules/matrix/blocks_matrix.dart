import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

class BlocksMatrix extends Component with HasGameRef<SimulationGame> {
  BlocksMatrix(Vector2 gameSize) {
    lengthX = gameSize.x ~/ blockSize + 1;
    lengthY = gameSize.y ~/ blockSize + 1;
    matrix = List.generate(
      lengthX,
      (_) => List<BlockType>.filled(lengthY, BlockType.empty),
    );
  }

  late List<List<BlockType>> matrix;

  final List<Block> postFieldBlocks = [];
  double postFieldTimer = 0;

  late int lengthX;
  late int lengthY;

  double get blockSize => SimulationGame.blockSize;

  double get bs2 => blockSize / 2;

  @override
  void update(double dt) {
    if ((postFieldTimer -= dt) < 0) {
      postFieldTimer = 0.1;
      if (postFieldBlocks.isNotEmpty) {
        final block = postFieldBlocks.random();
        if (getBlockType(block) == BlockType.postField) {
          setBlockType(block, BlockType.empty);
        }
      }
    }
    super.update(dt);
  }

  Block getBlock(Vector2 position) {
    return Block(
      ((position.x + bs2) / blockSize).round(),
      ((position.y + bs2) / blockSize).round(),
    );
  }

  void setBlockType(Block block, BlockType type) {
    matrix[block.x][block.y] = type;
    if (type == BlockType.postField) {
      postFieldBlocks.add(block);
    }
  }

  BlockType getBlockType(Block block) {
    return matrix[block.x][block.y];
  }

  Vector2 getPosition(Block block) {
    return ((block.toVector2() * blockSize)..round()) - Vector2.all(bs2);
  }

  BlockType getBlockTypeAtPosition(Vector2 position) {
    return getBlockType(getBlock(position));
  }

  void markBlocksForSpot(Spot spot, BlockType type) {
    final blocks = getBlocksForSpot(spot);
    for (final block in blocks) {
      setBlockType(block, type);
    }
  }

  void removeBlocksOfTypeForSpot(Spot spot, BlockType type) {
    final blocks = getBlocksForSpot(spot);
    for (final block in blocks) {
      if (getBlockType(block) == type) {
        setBlockType(block, BlockType.empty);
      }
    }
  }

  List<Block> getBlocksForSpot(Spot spot) {
    final radius2 = spot.radius * spot.radius;

    final firstBlockX =
        max(0, ((spot.position.x - spot.radius) / blockSize).ceil());
    final lastBlockX =
        min(lengthX - 1, ((spot.position.x + spot.radius) / blockSize).floor());
    final firstBlockY =
        max(0, ((spot.position.y - spot.radius) / blockSize).ceil());
    final lastBlockY =
        min(lengthY - 1, ((spot.position.y + spot.radius) / blockSize).floor());

    final spotBlocks = <Block>[];
    for (var x = firstBlockX; x <= lastBlockX; x++) {
      for (var y = firstBlockY; y <= lastBlockY; y++) {
        final blockPosition = Vector2(x.toDouble(), y.toDouble()) * blockSize;
        final distance2 = blockPosition.distanceToSquared(spot.position);
        if (distance2 <= radius2) {
          spotBlocks.add(Block(x, y));
        }
      }
    }

    return spotBlocks;
  }

  void markBlocksForField(FieldComponent field) {
    final fieldBlocks = getBlocksForField(field);
    for (final block in fieldBlocks) {
      final blockType = getBlockType(block);
      if (blockType != BlockType.city && blockType != BlockType.farm) {
        setBlockType(block, BlockType.field);
      }
    }
  }

  void removeBlocksForField(FieldComponent field) {
    final fieldBlocks = getBlocksForField(field);
    for (final block in fieldBlocks) {
      final blockType = getBlockType(block);
      if (blockType == BlockType.field) {
        setBlockType(block, BlockType.postField);
      }
    }
  }

  List<Block> getBlocksForField(FieldComponent field) {
    final leftTopBlock = getBlock(field.position);
    final rightBottomBlock = getBlock(field.position + field.size);

    var firstBlockX = leftTopBlock.x;
    var lastBlockX = rightBottomBlock.x;
    var firstBlockY = leftTopBlock.y;
    var lastBlockY = rightBottomBlock.y;

    firstBlockX = max(0, firstBlockX);
    lastBlockX = min(lengthX - 1, lastBlockX);
    firstBlockY = max(0, firstBlockY);
    lastBlockY = min(lengthY - 1, lastBlockY);

    /// Finding all the field's blocks
    final fieldBlocks = <Block>[];
    for (var x = firstBlockX; x < lastBlockX; x++) {
      for (var y = firstBlockY; y < lastBlockY; y++) {
        fieldBlocks.add(Block(x, y));
      }
    }

    return fieldBlocks;
  }

  Vector2 correctPositionForMatrix(Vector2 position) {
    return getPosition(getBlock(position));
  }

  Vector2? tryToPlaceFieldInBlock(Point<int> fieldConfiguration, Block block) {
    var firstBlockX = block.x - fieldConfiguration.x + 1;
    var lastBlockX = block.x;
    var firstBlockY = block.y - fieldConfiguration.y + 1;
    var lastBlockY = block.y;

    firstBlockX = max(0, firstBlockX);
    lastBlockX = min(lengthX - fieldConfiguration.x, lastBlockX);
    firstBlockY = max(0, firstBlockY);
    lastBlockY = min(lengthY - fieldConfiguration.y, lastBlockY);

    bool canPlaceField(int startX, int startY, Point<int> size) {
      var treeBlocksCount = 0;
      var postFieldBlocksCount = 0;
      for (var x = startX; x < startX + size.x; x++) {
        for (var y = startY; y < startY + size.y; y++) {
          final blockType = matrix[x][y];
          if (blockType == BlockType.tree) {
            treeBlocksCount++;
          } else if (blockType == BlockType.postField) {
            postFieldBlocksCount++;
          } else if (blockType != BlockType.empty) {
            return false;
          }
        }
      }

      /// Field can cover up to 20% of the trees and the post field blocks
      final fieldBlocksCount = size.x * size.y;
      return treeBlocksCount / fieldBlocksCount <= 0.2 &&
          postFieldBlocksCount / fieldBlocksCount <= 0.2;
    }

    final validPositions = <Vector2>[];
    for (var x = firstBlockX; x <= lastBlockX; x++) {
      for (var y = firstBlockY; y <= lastBlockY; y++) {
        if (canPlaceField(x, y, fieldConfiguration)) {
          validPositions.add(getPosition(Block(x, y)));
        }
      }
    }

    return validPositions.isEmpty ? null : validPositions.random();
  }
}
