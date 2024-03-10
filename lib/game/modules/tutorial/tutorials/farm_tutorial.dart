import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/ch4_tutorial.dart';

class FarmTutorial extends BaseTutorial {
  FarmTutorial(super.game);

  @override
  String? get mainTutorialText => 'This is a farm!';

  @override
  String? get doYouKnowText => '';

  @override
  bool canBeShown(TutorialModule module) {
    return module.isTutorialShown<CH4Tutorial>();
  }

  @override
  void onShowing() {
    final farms = game.farmModule.farms;
    if (farms.isNotEmpty) {
      focusOn(farms.random());
    }
  }
}
