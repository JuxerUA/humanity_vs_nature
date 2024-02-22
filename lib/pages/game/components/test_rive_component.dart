import 'package:flame/game.dart';
import 'package:flame_rive/flame_rive.dart';

class TestRiveComponent extends RiveComponent {
  TestRiveComponent(Artboard artboard) : super(artboard: artboard);

  late final StateMachineController? ctrlRedToGreen;
  SMINumber? progressInputRTG;
  double _counter = 0;

  @override
  void onLoad() {
    // size = Vector2(100, 100);
    // final controller = OneShotAnimation('Timeline 1');
    // final controller = StateMachineController(StateMachine());
    // artboard.addController(controller);

    ctrlRedToGreen = StateMachineController.fromArtboard(
        artboard, 'State Machine 1');
    if (ctrlRedToGreen != null) {
      progressInputRTG = ctrlRedToGreen!.inputs.first as SMINumber;
      artboard.addController(ctrlRedToGreen!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _counter += 10 * dt;
    if (_counter >= 100) {
      _counter -= 100;
    }

    progressInputRTG?.value = _counter;
  }
}