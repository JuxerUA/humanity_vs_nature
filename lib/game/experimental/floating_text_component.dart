import 'dart:async';

import 'package:flame/components.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

class FloatingTextComponent extends RectangleComponent {
  FloatingTextComponent({required this.text});

  final String text;

  double duration = 2;
  late double timer = duration;
  late double initialY = y;
  double floatingDistance = 40;

  @override
  FutureOr<void> onLoad() {
    final textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(style: Styles.black10),
    );
    paint.color = paint.color.withAlpha(150);
    add(textComponent);
    anchor = Anchor.center;
    size = textComponent.size + Vector2.all(4);
    textComponent.position = Vector2.all(2);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if ((timer -= dt) < 0) {
      removeFromParent();
    } else {
      final timeProgress = timer / duration;
      final timeProgressSquared = timeProgress * timeProgress;
      y = initialY + timeProgressSquared * floatingDistance - floatingDistance;
    }
  }
}
