import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/ch4_tutorial.dart';

class FarmTutorial extends BaseTutorial {
  FarmTutorial(super.game);

  @override
  String? get mainTutorialText =>
      "It's a farm. It raises animals for food.\nSounds wild, doesn't it? I thought so too :)\nWell, it is what it is. In the process of digesting food, the animals produce methane.";

  @override
  String? get doYouKnowText =>
      "The majority of human-produced methane comes from livestock farming.";

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 20 &&
        module.isTutorialShown<CH4Tutorial>();
  }

  @override
  void onShowing() {
    final farms = game.farmModule.farms;
    if (farms.isNotEmpty) {
      focusOn(farms.random());
    }
  }
}
