import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/animation.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

class FloatingTextComponent extends RectangleComponent {
  FloatingTextComponent({required this.text});

  final String text;

  double duration = 2;
  late double timer = duration;
  late double initialY = y;
  double floatingDistance = 30;
  late final TextComponent textComponent;

  @override
  FutureOr<void> onLoad() {
    textComponent = TextComponent(
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

  void reSpawn(String text, Color color) {
    y = initialY;
    timer = duration;
    textComponent.text = text;
    size = textComponent.size + Vector2.all(4);
    textComponent.position = Vector2.all(2);
    paint.color = color.withAlpha(150);
  }
}
