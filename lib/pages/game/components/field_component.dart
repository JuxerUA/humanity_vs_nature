import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/models/dot.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FieldComponent extends PolygonComponent with HasGameRef<SimulationGame> {
  FieldComponent(super.vertices) {
    paint = Paint()
      ..color = _generateRandomFieldColor()
      ..style = PaintingStyle.fill;

    /// Sorting the points for painting
    // final pointsCenter = Vector2(
    //   points.map((e) => e.x).reduce((value, e) => value + e) / points.length,
    //   points.map((e) => e.y).reduce((value, e) => value + e) / points.length,
    // );
    // points.sort(
    //   (a, b) => atan2(a.y - pointsCenter.x, a.x - pointsCenter.y)
    //       .compareTo(atan2(b.y - pointsCenter.y, b.x - pointsCenter.x)),
    // );

    if (vertices.length < 3 || vertices.length > 4) {
      area = 0;
      return;
    }

    final point1 = vertices[0];
    final point2 = vertices[1];
    final point3 = vertices[2];

    double areaOfTriangle(double a, double b, double c) {
      final s = (a + b + c) / 2;
      return sqrt(s * (s - a) * (s - b) * (s - c));
    }

    final distance12 = point1.distanceTo(point2);
    final distance23 = point2.distanceTo(point3);
    final distance31 = point3.distanceTo(point1);
    final triangleArea = areaOfTriangle(distance12, distance23, distance31);
    if (vertices.length < 4) {
      area = triangleArea;
      return;
    }

    final point4 = vertices[3];
    final distance34 = point3.distanceTo(point4);
    final distance41 = point4.distanceTo(point1);
    final triangleArea2 = areaOfTriangle(distance34, distance41, distance31);
    area = triangleArea + triangleArea2;
  }

  // absolute area (not by dotSpacing)
  late final double area;

  List<Dot> get dots => vertices
      .map((e) => Dot(
            ((e.x + position.x) / SimulationGame.dotSpacing).round(),
            ((e.y + position.y) / SimulationGame.dotSpacing).round(),
          ))
      .toList();

  bool containsDot(Point<int> point) {
    if (vertices.length != 4) return false;

    final p1 = vertices[0] + position;
    final p2 = vertices[1] + position;
    final p3 = vertices[2] + position;
    final p4 = vertices[3] + position;
    final p = Vector2(point.x * SimulationGame.dotSpacing,
        point.y * SimulationGame.dotSpacing);

    print('containsDot');
    print('p1 $p1');
    print('p2 $p2');
    print('p3 $p3');
    print('p4 $p4');
    print('p $p');

    bool isPointInTriangle(Vector2 p, Vector2 a, Vector2 b, Vector2 c) {
      final b1 = ((p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y)) <= 0.0;
      final b2 = ((p.x - c.x) * (b.y - c.y) - (b.x - c.x) * (p.y - c.y)) <= 0.0;
      final b3 = ((p.x - a.x) * (c.y - a.y) - (c.x - a.x) * (p.y - a.y)) <= 0.0;

      return (b1 == b2) && (b2 == b3);
    }

    bool isPointInsideConvexQuadrilateral(
        Vector2 p, Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4) {
      return isPointInTriangle(p, p1, p2, p3) ||
          isPointInTriangle(p, p1, p3, p4);
    }

    return isPointInsideConvexQuadrilateral(p, p1, p2, p3, p4);
  }

  Color _generateRandomFieldColor() {
    final colors = [
      Colors.green,
      Colors.green,
      Colors.green,
      Colors.green,
      // Colors.lightGreen,
      Colors.lightGreenAccent,
      Colors.lightGreenAccent,
      Colors.lightGreenAccent,
      Colors.lime,
      Colors.lime,
      Colors.limeAccent,
      Colors.yellowAccent,
      Colors.yellow,
      Colors.amberAccent,
      Colors.amber,
      Colors.orangeAccent,
      Colors.orange,
      // Colors.deepOrangeAccent,
      // Colors.deepOrange,
    ];

    return colors.random();
  }
}
