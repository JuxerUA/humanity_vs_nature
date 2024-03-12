import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class FieldTutorial extends BaseTutorial {
  FieldTutorial(super.game);

  @override
  String? get mainTutorialText =>
      "The fields provide cities and farms with plant food. Of course fields also absorb carbon dioxide, but that ruins the gameplay, so not in this game :)";

  @override
  String? get doYouKnowText =>
      "Most of the food grown in the fields is used to feed farm animals.\nIf all people switched to a plant-based diet, we could reduce the number of fields by many times and return these areas to the wild.";

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 25 &&
        game.fieldModule.fields.isNotEmpty;
  }

  @override
  void onShowing() {
    final farms = game.farmModule.farms;
    if (farms.isNotEmpty) {
      focusOn(farms.random());
    }
  }
}
