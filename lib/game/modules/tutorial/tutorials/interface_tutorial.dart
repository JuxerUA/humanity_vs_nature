import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class InterfaceTutorial extends BaseTutorial {
  InterfaceTutorial(super.game);

  @override
  String? get mainTutorialText =>
      "At the top of the screen, you can see the interface. Yep, it's pretty snaggy :)\nThere you can see the current number of units of gases on the playing field.\nThe green Awareness bar shows the average level of awareness of the townspeople. To win you need to bring this indicator up to 75%.\nThe orange Pollution bar depends on the number of gas units in the game. If it fills up, the consequences of global warming will be irreversible and you will lose.";

  @override
  String? get doYouKnowText => null;

  @override
  bool canBeShown(TutorialModule module) => true;

  @override
  void onShowing() {
    game.paused = true;
  }
}
