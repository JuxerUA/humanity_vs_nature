import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class WelcomeTutorial extends BaseTutorial {
  WelcomeTutorial(super.game);

  @override
  String? get mainTutorialText =>
      "Hi there!\nWe are facing the problem of global warming. You've probably heard about it by now :)\nWell, we need a hero to clean up the mess.\nCould that be you? Definitely! Let's get to work.";

  @override
  String? get doYouKnowText => null;

  @override
  bool canBeShown(TutorialModule module) => true;

  @override
  void onShowing() {
    game.paused = true;
  }
}
