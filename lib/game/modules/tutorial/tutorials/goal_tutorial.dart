import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class GoalTutorial extends BaseTutorial {
  GoalTutorial(super.game);

  @override
  String? get mainTutorialText =>
      "Well, it's pretty simple :)\nIf you can fill in the green bar, you win.\nIf the orange bar fills up before that, you lose.\nYou have to get rid of the excess gas by planting trees while those cheeky people keep taking up space with their fields.\nGood luck!";

  @override
  String? get doYouKnowText => null;

  @override
  bool canBeShown(TutorialModule module) => true;

  @override
  void onShowing() {
    game.paused = true;
  }
}
