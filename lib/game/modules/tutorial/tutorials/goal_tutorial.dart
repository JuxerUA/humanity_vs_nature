import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class GoalTutorial extends BaseTutorial {
  GoalTutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.wellItsPrettySimpleNifYouCanFillInThe;

  @override
  String? getDoYouKnowText(BuildContext context) => null;

  @override
  bool canBeShown(TutorialModule module) => true;

  @override
  void onShowing() {
    game.paused = true;
  }
}
