import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/extensions/iterable_extension.dart';
import 'package:humanity_vs_nature/extensions/point_extension.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/game/modules/matrix/block_type.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

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

  Future<void> spawnInitialFields() async {
    for (final city in game.cityModule.cities) {
      final fieldsCount = (city.population / 10).floor();
      for (var i = 0; i < fieldsCount; i++) {
        final field = expandField(city, CityComponent.radiusForFields);
        if (field != null) {
          fields.add(field);
          city.fields.add(field);
          field.setRandomPhase();
        }
      }
    }

    for (final farm in game.farmModule.farms) {
      final fieldsCount = (farm.owner.population / 7).floor();
      for (var i = 0; i < fieldsCount; i++) {
        final field = expandField(farm, FarmComponent.radiusForFields);
        if (field != null) {
          fields.add(field);
          farm.fields.add(field);
          field.setRandomPhase();
        }
      }
      farm.updateProductionRate();
    }
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
    Vector2 size,
    PositionComponent owner, {
    bool canBeDestroyedByTap = true,
  }) {
    final field =
        FieldComponent(owner: owner, canBeDestroyedByTap: canBeDestroyedByTap)
          ..position = game.matrix.correctPositionForMatrix(position)
          ..size = size;
    fields.add(field);
    add(field);
    game.matrix.markBlocksForField(field);
    return field;
  }

  void removeField(FieldComponent field) {
    fields.remove(field);
    abandonedFields.remove(field);
    final owner = field.owner;
    if (owner is FarmComponent) {
      owner.fields.remove(field);
    } else if (owner is CityComponent) {
      owner.fields.remove(field);
    }
    if (field.isMounted) field.removeFromParent();
    game.matrix.removeBlocksForField(field);
  }

  /// Making the first farm's field of random shape
  FieldComponent addFirstFieldForFarm(FarmComponent farm) {
    final fieldWidthK = 2.4 + 0.4 * randomFallback.nextDouble();
    final fieldHeightK = 1.2 + 0.8 * randomFallback.nextDouble();

    var fieldWidth = FarmComponent.radius * fieldWidthK;
    fieldWidth = (fieldWidth / blockSize).round() * blockSize;
    var fieldHeight = FarmComponent.radius * fieldHeightK;
    fieldHeight = (fieldHeight / blockSize).round() * blockSize;

    return addField(
      farm.position - Vector2(fieldWidth / 2, fieldHeight / 2),
      Vector2(fieldWidth, fieldHeight),
      farm,
      canBeDestroyedByTap: false,
    );
  }

  FieldComponent? expandField(PositionComponent owner, double maxRadius) {
    /// First check the abandoned fields
    final maxRadius2 = maxRadius * maxRadius;
    final abandonedField = abandonedFields.firstOrNullWhere((e) =>
        (e.position.clone()..addScaled(e.size, 0.5))
            .distanceToSquared(owner.position) <
        maxRadius2);
    if (abandonedField != null) {
      abandonedFields.remove(abandonedField);
      return abandonedField;
    }

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
        .getBlocksForSpot(Spot(owner.position, maxRadius))
        .where((block) => game.matrix.getBlockType(block) == BlockType.empty);

    if (emptyBlocksAtThisSpot.isNotEmpty) {
      final sortedBlocks = emptyBlocksAtThisSpot.toList()
        ..sort((a, b) {
          final aDistance =
              game.matrix.getPosition(a).distanceToSquared(owner.position);
          final bDistance =
              game.matrix.getPosition(b).distanceToSquared(owner.position);
          return aDistance.compareTo(bDistance);
        });

      for (final block in sortedBlocks) {
        final position =
            game.matrix.tryToPlaceFieldInBlock(fieldConfiguration, block);
        if (position != null) {
          return addField(
            position,
            fieldConfiguration.toVector2() * blockSize,
            owner,
          );
        }
      }
    }

    return null;
  }

  void onFarmRemoved(FarmComponent farm) {
    removeField(farm.baseField);
    abandonedFields.addAll(farm.fields);
  }

  void abandonField(FieldComponent field) {
    abandonedFields.add(field);
  }

  void removeAllOtherFieldsInTheFieldArea(FieldComponent field) {
    final fieldRect = field.toRect();
    final overlappingFields =
        fields.where((e) => e.toRect().overlaps(fieldRect)).toList();
    for (final overlappingField in overlappingFields) {
      if (overlappingField != field) {
        removeField(overlappingField);
      }
    }
    game.matrix.markBlocksForField(field);
  }
}
