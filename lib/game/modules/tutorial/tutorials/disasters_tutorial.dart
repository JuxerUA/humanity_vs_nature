import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class DisastersTutorial extends BaseTutorial {
  DisastersTutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.weatherDisastersLikeFiresOrTornadoesWereAlsoPlannedFor;

  @override
  String? getDoYouKnowText(BuildContext context) => context
      .strings.globalWarmingIsAlsoDestroyingClimateStabilityAndIncreasingThe;

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 20 &&
        randomFallback.nextInt(10) == 10;
  }

  @override
  void onShowing() {}
}
