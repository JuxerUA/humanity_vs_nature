import 'dart:math';

import 'package:flame/components.dart';

extension ContextExt on PositionComponent {
  void setRandomPosition(Vector2 screenSize) {
    final random = Random();
    final randomX = random.nextDouble() * (screenSize.x - size.x);
    final randomY = random.nextDouble() * (screenSize.y - size.y);
    position = Vector2(randomX, randomY);
  }

  bool isOutOfScreen(Vector2 screenSize) =>
      position.x - width / 2 > screenSize.x ||
      position.x + width / 2 < 0 ||
      position.y - height / 2 > screenSize.y ||
      position.y + height / 2 < 0;
}
