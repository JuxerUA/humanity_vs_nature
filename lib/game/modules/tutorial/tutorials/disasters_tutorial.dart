import 'package:flame/math.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class DisastersTutorial extends BaseTutorial {
  DisastersTutorial(super.game);

  @override
  String? get mainTutorialText =>
      'Weather disasters like fires or tornadoes were also planned for this game. But not this time :)';

  @override
  String? get doYouKnowText =>
      'Global warming is also destroying climate stability and increasing the frequency and severity of natural disasters.';

  @override
  bool canBeShown(TutorialModule module) {
    return randomFallback.nextDouble() < 0.1;
  }

  @override
  void onShowing() {}
}
