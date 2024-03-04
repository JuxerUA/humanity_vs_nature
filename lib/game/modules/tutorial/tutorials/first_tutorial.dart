import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class FirstTutorial extends BaseTutorial {
  FirstTutorial(super.game);

  @override
  String? get mainTutorialText => 'Hello!';

  @override
  String? get doYouKnowText => null;

  @override
  bool canBeShown(TutorialModule module) => true;

  @override
  void onShowing() {
    focusOn(game.cityModule.cities.random());
  }
}
