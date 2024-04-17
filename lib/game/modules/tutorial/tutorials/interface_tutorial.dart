import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class InterfaceTutorial extends BaseTutorial {
  InterfaceTutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.atTheTopOfTheScreenYouCanSeeThe;

  @override
  String? getDoYouKnowText(BuildContext context) => null;

  @override
  bool canBeShown(TutorialModule module) => true;

  @override
  void onShowing() {
    game.paused = true;
  }
}
