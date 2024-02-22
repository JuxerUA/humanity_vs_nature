import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/extensions/point_extension.dart';
import 'package:humanity_vs_nature/pages/game/models/block_type.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FieldModule extends Component with HasGameRef<SimulationGame> {
  final List<FieldComponent> _fields = [];

  List<FieldComponent> get fields => _fields;

  double get blockSize => SimulationGame.blockSize;

  double get bs2 => SimulationGame.blockSize / 2;

  int get blocksCountX => game.matrix.lengthX;

  int get blocksCountY => game.matrix.lengthY;

  void addField(Vector2 position, Vector2 size) {
    final field = FieldComponent()
      ..position = game.matrix.correctPositionForMatrix(position)
      ..size = size;
    _fields.add(field);
    add(field);
    game.matrix.markBlocksForField(field, BlockType.field);
  }

  void removeField(FieldComponent field) {
    _fields.remove(field);
    remove(field);
    game.matrix.removeBlocksForField(field);
  }

  /// Making the first farm's field of random shape
  void addFirstFarmField(Vector2 farmPosition) {
    final fieldWidthK = 2.4 + 0.4 * randomFallback.nextDouble();
    final fieldHeightK = 1.2 + 0.8 * randomFallback.nextDouble();

    var fieldWidth = FarmComponent.radius * fieldWidthK;
    fieldWidth = (fieldWidth / blockSize).round() * blockSize;
    var fieldHeight = FarmComponent.radius * fieldHeightK;
    fieldHeight = (fieldHeight / blockSize).round() * blockSize;

    addField(
      farmPosition - Vector2(fieldWidth / 2, fieldHeight / 2),
      Vector2(fieldWidth, fieldHeight),
    );
  }

  void expandField(Spot ownerSpot, double maxRadius) {
    final availableFieldConfigurations = [
      const Point<int>(2, 2),
      const Point<int>(2, 3),
      const Point<int>(2, 3),
      const Point<int>(2, 4),
      const Point<int>(2, 4),
      const Point<int>(3, 2),
      const Point<int>(3, 2),
      const Point<int>(3, 3),
      const Point<int>(3, 4),
      const Point<int>(4, 2),
      const Point<int>(4, 2),
      const Point<int>(4, 3),
    ];

    final fieldConfiguration = availableFieldConfigurations.random();

    final emptyBlocksAtThisSpot = game.matrix
        .getBlocksForSpot(Spot(ownerSpot.position, maxRadius))
        .where((block) => game.matrix.getBlockType(block) == BlockType.empty);

    if (emptyBlocksAtThisSpot.isNotEmpty) {
      final sortedBlocks = emptyBlocksAtThisSpot.toList()
        ..sort((a, b) {
          final aDistance =
              game.matrix.getPosition(a).distanceToSquared(ownerSpot.position);
          final bDistance =
              game.matrix.getPosition(b).distanceToSquared(ownerSpot.position);
          return aDistance.compareTo(bDistance);
        });

      for (final block in sortedBlocks) {
        final position =
            game.matrix.tryToPlaceFieldInBlock(fieldConfiguration, block);
        if (position != null) {
          addField(position, fieldConfiguration.toVector2() * blockSize);
          return;
        }
      }
    }
  }
}
