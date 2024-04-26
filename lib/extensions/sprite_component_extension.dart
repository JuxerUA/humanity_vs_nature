import 'package:flame/components.dart';

extension ContextExt on PositionComponent {
  bool isOutOfScreen(Vector2 screenSize) =>
      position.x - width / 2 > screenSize.x ||
      position.x + width / 2 < 0 ||
      position.y - height / 2 > screenSize.y ||
      position.y + height / 2 < 0;
}
