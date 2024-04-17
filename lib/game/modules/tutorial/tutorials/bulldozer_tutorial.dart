import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class BulldozerTutorial extends BaseTutorial {
  BulldozerTutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.citiesLikeToLetOutBulldozersToClearSomeMore;

  @override
  String? getDoYouKnowText(BuildContext context) =>
      context.strings.agricultureIsTheLeadingCauseOfDeforestationOnThePlanet;

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 15 &&
        game.bulldozerModule.bulldozers
            .where((e) => !e.isReturningToBase)
            .isNotEmpty;
  }

  @override
  void onShowing() {
    final bulldozers = game.bulldozerModule.bulldozers
        .where((e) => !e.isReturningToBase)
        .toList();
    if (bulldozers.isNotEmpty) {
      final bulldozer = bulldozers.random();
      target = bulldozer;
      bulldozer.startBlinking();
      focusOn(bulldozer);
    }
  }
}
