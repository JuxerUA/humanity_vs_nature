import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class FirstTutorial extends BaseTutorial {
  FirstTutorial(super.game);

  @override
  String? get mainTutorialText =>
      "Hello! I think you already know that global warming is caused by the greenhouse effect, which is created by gases in the planet's atmosphere, such as carbon dioxide, methane and some others. The aim of the game is to demonstrate how this works on a global level. So it's not going to be about cars or factories. On a global level, only cities, forests, oceans are important.";

  @override
  String? get doYouKnowText => null;

  @override
  bool canBeShown(TutorialModule module) => true;

  @override
  void onShowing() {
    game.paused = true;
  }
}
