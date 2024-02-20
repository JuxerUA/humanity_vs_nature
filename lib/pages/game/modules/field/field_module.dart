import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/extensions/iterable_extension.dart';
import 'package:humanity_vs_nature/pages/game/models/dot.dart';
import 'package:humanity_vs_nature/pages/game/models/dot_type.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/farm/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FieldModule extends Component with HasGameRef<SimulationGame> {
  final List<FieldComponent> _fields = [];

  List<FieldComponent> get fields => _fields;

  double get dotSpacing => SimulationGame.dotSpacing;

  int get dotsCountX => game.dotsCountX;

  int get dotsCountY => game.dotsCountY;

  DotType getDotType(Dot dot) => game.getDotType(dot);

  /// Making the first farm's field of random shape
  void addFirstFarmField(Vector2 fieldPosition) {
    const baseRadius = FarmComponent.radius * 1.2;
    const maxRandomLength = FarmComponent.radius * 0.4;
    double extraLength() =>
        baseRadius + maxRandomLength * randomFallback.nextDouble();
    final fieldPositions = <Vector2>[
      Vector2(fieldPosition.x - extraLength(), fieldPosition.y - extraLength()),
      Vector2(fieldPosition.x + extraLength(), fieldPosition.y - extraLength()),
      Vector2(fieldPosition.x + extraLength(), fieldPosition.y + extraLength()),
      Vector2(fieldPosition.x - extraLength(), fieldPosition.y + extraLength()),
    ];

    addField(fieldPositions.map(Dot.fromPosition).toList(), isGroundOnly: true);
  }

  void addField(List<Dot> dots, {bool isGroundOnly = false}) {
    /// Calculate field position
    var minX = game.size.x.ceil();
    var minY = game.size.y.ceil();
    for (final dot in dots) {
      if (dot.x < minX) minX = dot.x;
      if (dot.y < minY) minY = dot.y;
    }
    // todo maybe move to the FieldComponent constructor
    final position = Vector2(minX * dotSpacing, minY * dotSpacing);

    /// Create field
    final field = FieldComponent(
      dots.map((e) => e.position - position).toList(),
      isGroundOnly: isGroundOnly,
    )..position = position;
    _fields.add(field);
    add(field);
    game.markDotsForField(field);
  }

  void expandField(Spot ownerSpot) {

    final randomField = _randomField(ownerSpot);
    if (randomField != null) {
      addField(randomField);
    }

    return;
    ///

    final firstDot = findNearestDotOfType(
      ownerSpot.position,
      DotType.fieldPartial,
    );
    if (firstDot == null) return;

    const fieldRadius = 40.0;
    const offset = fieldRadius * 0.7;

    final firstDotPosition = firstDot.position;
    final directionVector = firstDotPosition - ownerSpot.position
      ..clampLength(offset, offset);
    final centerPosition = firstDotPosition; // + directionVector;

    final partialFieldDotsInTheArea = game
        .getDotsForSpot(Spot(centerPosition, fieldRadius))
        .where((dot) => getDotType(dot) == DotType.fieldPartial)
        .toList()
      ..removeWhere((dot) => dot.x == firstDot.x && dot.y == firstDot.y);

    // if (partialFieldDotsInTheArea.length > 2) {
    //   //TODO remake, we should use 2 dots farthest of firstDot
    //   final fieldDots = findFourFarthestDots(partialFieldDotsInTheArea);
    //   addField(fieldDots);
    // }

    /// TODO how it should work:
    /// we have the first dor, nice

    /// when we have the two dots we should check all rest dots trying to find a
    /// triangle around specific area and it shouldn't cover any other field's dots
    /// (maybe if we can't find right dot we should use random free dot)
    /// then, when we have triangle we need to check the triangle area
    /// if it less then some specific area - we should try to find extra triangle
    /// (part of square)

    /// then we should find another dot in the some specific distance (around it) from the first one
    /// it should be partial field dot
    const specificDotDistance = 4;
    final partialDotsForSecondDot = <Dot>[];
    for (final dot in partialFieldDotsInTheArea) {
      final distance = dot.distanceTo(firstDot);
      if (distance > specificDotDistance - 2 &&
          distance < specificDotDistance + 2) {
        partialDotsForSecondDot.add(dot);
      }
    }

    late Dot secondDot;
    if (partialDotsForSecondDot.isNotEmpty) {
      secondDot = partialDotsForSecondDot.random();
    } else {
      /// if we can't find a partial field dot, we should take a dot in the specific
      /// distance as much close to the owner position as possible
      //todo
    }

    // if (partialFieldDotsInTheArea.length > 1) {
    //   final secondDot = partialFieldDotsInTheArea.random();
    //   partialFieldDotsInTheArea.remove(secondDot);
    //   final thirdDot = partialFieldDotsInTheArea.random();
    //   addField([firstDot, secondDot, thirdDot]);
    // }
  }

  List<Dot>? _randomField(Spot ownerSpot) {
    final dots = game.getDotsForSpot(Spot(
      ownerSpot.position,
      FarmComponent.requiredSpotRadius,
    ));

    final partialDots = dots
        .where((dot) => game.getDotType(dot) == DotType.fieldPartial)
        .toList();

    final emptyDots =
        dots.where((dot) => game.getDotType(dot) == DotType.none).toList();

    if (partialDots.length < 2 || emptyDots.isEmpty) return null;

    for (final firstDot in partialDots.randomize()) {

      final dotsForSecondDot = partialDots.where((dot) {
        final distance = dot.distanceTo(firstDot);
        return distance >= 3 && distance <= 5;
      }).toList();

      if (dotsForSecondDot.isEmpty) continue;

      for (final secondDot in dotsForSecondDot.randomize()) {
        final dotsForThirdDot = emptyDots.where((dot) {
          final distance1 = dot.distanceTo(firstDot);
          if (distance1 >= 3 && distance1 <= 5) {
            final distance2 = dot.distanceTo(secondDot);
            if (distance2 >= 3 && distance2 <= 5) {
              return true;
            }
          }
          return false;
        }).toList();

        for (final thirdDot in dotsForThirdDot.randomize()) {
          final vertexDots = [firstDot, secondDot, thirdDot];
          if (_validateTriangle(vertexDots)) {
            return vertexDots;
          }
        }
      }
    }

    return null;
  }

  bool _validateTriangle(List<Dot> vertexDots) {
    final triangleDots = game.getDotsForField(vertexDots);
    for (final dot in triangleDots) {
      if (game.getDotType(dot) != DotType.none) {
        return false;
      }
    }
    return true;
  }

  List<Dot> findFourFarthestDots(List<Dot> dots) {
    double calculateAverageDistance(List<Dot> dots) {
      var totalDistance = 0.0;

      for (var i = 0; i < dots.length; i++) {
        for (var j = i + 1; j < dots.length; j++) {
          totalDistance += dots[i].squaredDistanceTo(dots[j]);
        }
      }

      return totalDistance / (dots.length * (dots.length - 1) / 2);
    }

    var farthestDots = <Dot>[];
    var maxAverageDistance = 0.0;

    for (var i = 0; i < dots.length; i++) {
      for (var j = i + 1; j < dots.length; j++) {
        for (var k = j + 1; k < dots.length; k++) {
          for (var l = k + 1; l < dots.length; l++) {
            final combination = <Dot>[dots[i], dots[j], dots[k], dots[l]];
            final averageDistance = calculateAverageDistance(combination);

            if (averageDistance > maxAverageDistance) {
              maxAverageDistance = averageDistance;
              farthestDots = combination;
            }
          }
        }
      }
    }

    return farthestDots;
  }

  Dot? findNearestDotOfType(Vector2 position, DotType type) {
    bool checkDot(Dot dot) {
      if (dot.x >= 0 &&
          dot.x < dotsCountX &&
          dot.y >= 0 &&
          dot.y < dotsCountY) {
        return getDotType(dot) == type;
      }
      return false;
    }

    var leftX = position.x ~/ dotSpacing;
    var rightX = leftX + 1;
    var topY = position.y ~/ dotSpacing;
    var bottomY = topY + 1;

    for (var level = 0; level < 30; level++) {
      final dotsOnTheLevel = <Dot>[];

      for (var x = leftX; x < rightX; x++) {
        final dot = Dot(x, topY);
        if (checkDot(dot)) {
          dotsOnTheLevel.add(dot);
        }
      }

      for (var y = topY; y < bottomY; y++) {
        final dot = Dot(rightX, y);
        if (checkDot(dot)) {
          dotsOnTheLevel.add(dot);
        }
      }

      for (var x = rightX; x > leftX; x--) {
        final dot = Dot(x, bottomY);
        if (checkDot(dot)) {
          dotsOnTheLevel.add(dot);
        }
      }

      for (var y = bottomY; y > topY; y--) {
        final dot = Dot(leftX, y);
        if (checkDot(dot)) {
          dotsOnTheLevel.add(dot);
        }
      }

      if (dotsOnTheLevel.isNotEmpty) {
        return dotsOnTheLevel.random();
      } else {
        leftX -= 1;
        rightX += 1;
        topY -= 1;
        bottomY += 1;
      }
    }

    return null;
  }
}
