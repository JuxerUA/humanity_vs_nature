import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/models/dot.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

class FieldComponent extends PolygonComponent with HasGameRef<SimulationGame> {
  FieldComponent(List<Vector2> vertices, {this.isGroundOnly = false})
      : super(vertices) {
    vertexCount = vertices.length;
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

  final bool isGroundOnly;

  late final int vertexCount;

  // absolute area (not by dotSpacing)
  late final double area;

  List<Dot> get vertexDots =>
      vertices.map((e) => Dot.fromPosition(e + position)).toList();

  /// If the dot is placed on the one of the filed edges
  bool isEdgeDot(Dot dot) {
    if (vertexCount < 3) return false;

    bool arePointsCollinear(Vector2 a, Vector2 b, Vector2 p) =>
        ((b.y - a.y) * (p.x - a.x) - (b.x - a.x) * (p.y - a.y)).abs() < 0.0001;

    final p1 = vertices[0] + position;
    final p2 = vertices[1] + position;
    final p3 = vertices[2] + position;
    final p = dot.position;
    if (vertexCount == 3) {
      if (arePointsCollinear(p1, p2, p)) return true;
      if (arePointsCollinear(p2, p3, p)) return true;
      if (arePointsCollinear(p3, p1, p)) return true;
    } else if (vertexCount == 4) {
      final p4 = vertices[3] + position;
      if (arePointsCollinear(p1, p2, p)) return true;
      if (arePointsCollinear(p2, p3, p)) return true;
      if (arePointsCollinear(p3, p4, p)) return true;
      if (arePointsCollinear(p4, p1, p)) return true;
    }

    return false;
  }

  /// If the dot is inside the field area
  bool containsDot(Dot dot) {
    if (vertexCount < 3) return false;

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

    final p1 = vertices[0] + position;
    final p2 = vertices[1] + position;
    final p3 = vertices[2] + position;

    final p = dot.position;

    if (vertexCount == 3) {
      return isPointInTriangle(p, p1, p2, p3);
    } else if (vertexCount == 4) {
      final p4 = vertices[3] + position;
      return isPointInsideConvexQuadrilateral(p, p1, p2, p3, p4);
    }

    return false;
  }

  Color _generateRandomFieldColor() {
    if (isGroundOnly) return Colors.brown;

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
