import 'package:flame/math.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class DisastersTutorial extends BaseTutorial {
  DisastersTutorial(super.game);

  @override
  String? get mainTutorialText =>
      'Weather disasters like fires or tornadoes were also planned for this game. But not this time :) Well, uh.';

  @override
  String? get doYouKnowText =>
      'Global warming is also destroying climate stability and increasing the frequency and severity of natural disasters.';

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 20 &&
        randomFallback.nextInt(10) == 10;
  }

  @override
  void onShowing() {}
}
