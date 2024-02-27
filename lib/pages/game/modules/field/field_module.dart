import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/extensions/point_extension.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FieldModule extends Component with HasGameRef<SimulationGame> {
  static const double maxFieldClearanceTime = 5;

  final List<FieldComponent> fields = [];
  List<FieldComponent> abandonedFields = [];

  var _timeForRemoveAbandonedField = maxFieldClearanceTime;

  double get blockSize => SimulationGame.blockSize;

  double get bs2 => SimulationGame.blockSize / 2;

  int get blocksCountX => game.matrix.lengthX;

  int get blocksCountY => game.matrix.lengthY;

  @override
  void update(double dt) {
    _tryRemoveAbandonedField(dt);
    super.update(dt);
  }

  void _tryRemoveAbandonedField(double dt) {
    _timeForRemoveAbandonedField -= dt;
    if (_timeForRemoveAbandonedField < 0) {
      _timeForRemoveAbandonedField =
          randomFallback.nextDouble() * maxFieldClearanceTime;
      if (abandonedFields.isNotEmpty) {
        final fieldForRemove = abandonedFields.random();
        removeField(fieldForRemove);
      }
    }
  }

  FieldComponent addField(
    Vector2 position,
    Vector2 size, {
    bool canBeDestroyedByTap = true,
  }) {
    final field = FieldComponent(canBeDestroyedByTap: canBeDestroyedByTap)
      ..position = game.matrix.correctPositionForMatrix(position)
      ..size = size;
    fields.add(field);
    add(field);
    game.matrix.markBlocksForField(field, BlockType.field);
    return field;
  }

  void removeField(FieldComponent field) {
    fields.remove(field);
    abandonedFields.remove(field);
    remove(field);
    game.matrix.removeBlocksForField(field);
  }

  /// Making the first farm's field of random shape
  FieldComponent addFirstFarmField(Vector2 farmPosition) {
    final fieldWidthK = 2.4 + 0.4 * randomFallback.nextDouble();
    final fieldHeightK = 1.2 + 0.8 * randomFallback.nextDouble();

    var fieldWidth = FarmComponent.radius * fieldWidthK;
    fieldWidth = (fieldWidth / blockSize).round() * blockSize;
    var fieldHeight = FarmComponent.radius * fieldHeightK;
    fieldHeight = (fieldHeight / blockSize).round() * blockSize;

    return addField(
      farmPosition - Vector2(fieldWidth / 2, fieldHeight / 2),
      Vector2(fieldWidth, fieldHeight),
      canBeDestroyedByTap: false,
    );
  }

  FieldComponent? expandField(Spot ownerSpot, double maxRadius) {
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
          return addField(position, fieldConfiguration.toVector2() * blockSize);
        }
      }
    }

    return null;
  }

  void onFarmRemoved(FarmComponent farm) {
    removeField(farm.baseField);
    abandonedFields.addAll(farm.fields);
  }
}
