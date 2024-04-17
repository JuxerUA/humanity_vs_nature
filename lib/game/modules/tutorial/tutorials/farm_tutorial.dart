import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/ch4_tutorial.dart';

class FarmTutorial extends BaseTutorial {
  FarmTutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.itsAFarmItRaisesAnimalsForFoodnsoundsWildDoesnt;

  @override
  String? getDoYouKnowText(BuildContext context) => context
      .strings.theMajorityOfHumanproducedMethaneComesFromLivestockFarming;

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 20 &&
        module.isTutorialShown<CH4Tutorial>();
  }

  @override
  void onShowing() {
    final farms = game.farmModule.farms;
    if (farms.isNotEmpty) {
      final farm = farms.random();
      target = farm;
      farm.startBlinking();
      focusOn(farm);
    }
  }
}
