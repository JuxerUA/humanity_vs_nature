import 'package:flame/components.dart';

mixin AnimationOnTap on PositionComponent {
  void animateOnTap() {
    scale = Vector2.all(1.2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    var sc = scale.x;
    if (sc > 1) {
      sc *= 0.99;
      if (sc < 1) {
        sc = 1;
      }
      scale = Vector2.all(sc);
    }
  }
}
