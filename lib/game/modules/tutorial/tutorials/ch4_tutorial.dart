import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/co2_tutorial.dart';

class CH4Tutorial extends BaseTutorial {
  CH4Tutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.thereIsAnotherImportantGasMethaneOrCh4YouCan;

  @override
  String? getDoYouKnowText(BuildContext context) =>
      context.strings.althoughThereIsMuchLessMethaneInTheAtmosphereThan;

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 5 &&
        game.gasModule.currentTotalCH4Volume > 40 &&
        module.isTutorialShown<CO2Tutorial>();
  }

  @override
  void onShowing() {}
}
