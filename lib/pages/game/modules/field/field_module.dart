import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/pages/game/components/farm_component.dart';
import 'package:humanity_vs_nature/pages/game/models/dot.dart';
import 'package:humanity_vs_nature/pages/game/models/dot_type.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/modules/field/field_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FieldModule extends Component with HasGameRef<SimulationGame> {
  final List<FieldComponent> _fields = [];

  List<FieldComponent> get fields => _fields;

  double get dotSpacing => SimulationGame.dotSpacing;

  int get dotsCountX => game.dotsCountX;

  int get dotsCountY => game.dotsCountY;

  DotType getDotType(Dot dot) => game.getDotType(dot);

  void addFirstFarmField(Vector2 fieldPosition) {
    // Making the first farm's field of random shape
    // - the field must cover all the farm dots, but not to replace them
    final random = randomFallback;
    const baseRadius = FarmComponent.radius * 1.2;
    const maxRandomLength = FarmComponent.radius * 0.4;
    double extraLength() => baseRadius + maxRandomLength * random.nextDouble();
    final fieldPositions = <Vector2>[
      Vector2(fieldPosition.x - extraLength(), fieldPosition.y - extraLength()),
      Vector2(fieldPosition.x + extraLength(), fieldPosition.y - extraLength()),
      Vector2(fieldPosition.x + extraLength(), fieldPosition.y + extraLength()),
      Vector2(fieldPosition.x - extraLength(), fieldPosition.y + extraLength()),
    ];
    addField(fieldPositions.map(Dot.fromPosition).toList());

    // if (points.isEmpty) return;
    // final pointsCenter = Vector2(
    //   points.map((e) => e.x).reduce((value, e) => value + e) / points.length,
    //   points.map((e) => e.y).reduce((value, e) => value + e) / points.length,
    // );
    // final pointsWithDistance2 = points
    //     .map((e) => (e, e.toVector2().distanceToSquared(pointsCenter)))
    //     .toList()
    //   ..sort((a, b) => b.$2.compareTo(a.$2));
    // final extremePoints = pointsWithDistance2.map((e) => e.$1).take(6);
    // final fourFarthestExtremePoints =
    //     findFarthestPoints(extremePoints.toList(), 4);
    //
    // final finalFiledPoints = <Dot>[];
    // for (final point in fourFarthestExtremePoints) {
    //   final directionVector = point.toVector2() - pointsCenter
    //     ..clampLength(FarmComponent.radius / dotSpacing,
    //         FarmComponent.radius / dotSpacing);
    //   final endPosition = point.toVector2() + directionVector;
    //   finalFiledPoints
    //       .add(Dot(endPosition.x.round(), endPosition.y.round()));
    // }
    // addField(finalFiledPoints);
  }

  List<Dot> findFarthestPoints(List<Dot> dots, int count) {
    double calculateAverageDistance(List<Dot> points) {
      var totalDistance = 0.0;

      for (var i = 0; i < points.length; i++) {
        for (var j = i + 1; j < points.length; j++) {
          totalDistance += points[i].distanceTo(points[j]);
        }
      }

      return totalDistance / (points.length * (points.length - 1) / 2);
    }

    var farthestPoints = <Dot>[];
    var maxAverageDistance = 0.0;

    for (var i = 0; i < dots.length; i++) {
      for (var j = i + 1; j < dots.length; j++) {
        for (var k = j + 1; k < dots.length; k++) {
          for (var l = k + 1; l < dots.length; l++) {
            final combination = <Dot>[dots[i], dots[j], dots[k], dots[l]];
            final averageDistance = calculateAverageDistance(combination);

            if (averageDistance > maxAverageDistance) {
              maxAverageDistance = averageDistance;
              farthestPoints = combination;
            }
          }
        }
      }
    }

    return farthestPoints;
  }

  void addField(List<Dot> dots) {
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
    )..position = position;
    fields.add(field);
    add(field);
    game.markDotsForField(field);
  }

  void expandField(Spot ownerSpot) {
    final firstDot = findNearestDotForField(ownerSpot.position);
    if (firstDot == null) {
      return;
    }

    final firstDotPos = firstDot.position;
    var directionVector = firstDotPos - ownerSpot.position
      ..clampLength(20, 50);
    directionVector += (Vector2.random() - Vector2.random()) * 10;
    final oppositePos = firstDotPos + directionVector;
    final oppositeDot = findNearestDotForField(oppositePos);
    //todo
  }

  Dot? findNearestDotForField(Vector2 position) {
    bool checkDot(Dot dot) {
      if (dot.x >= 0 &&
          dot.x < dotsCountX &&
          dot.y >= 0 &&
          dot.y < dotsCountY) {
        return getDotType(dot).isGoodDotForField;
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
        final fieldPartDots = dotsOnTheLevel
            .where((dot) => getDotType(dot) == DotType.fieldPartial)
            .toList();
        return fieldPartDots.isNotEmpty
            ? fieldPartDots.random()
            : dotsOnTheLevel.random();
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
