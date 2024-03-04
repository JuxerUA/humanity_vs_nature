import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class FarmTutorial extends BaseTutorial {
  FarmTutorial(super.game);

  @override
  String? get mainTutorialText => '';

  @override
  String? get doYouKnowText => '';

  @override
  bool canBeShown(TutorialModule module) {
    return true;
  }

  @override
  void onShowing() {
    final farms = game.farmModule.farms;
    if (farms.isNotEmpty) {
      focusOn(farms.random());
    }
  }
}
