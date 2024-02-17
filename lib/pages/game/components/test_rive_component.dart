import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';

class TestRiveComponent extends RiveComponent {
  TestRiveComponent(Artboard artboard) : super(artboard: artboard);

  @override
  void onLoad() {
    size = Vector2(100, 100);
    final controller = OneShotAnimation('Timeline 1');
    artboard.addController(controller);
  }
}
