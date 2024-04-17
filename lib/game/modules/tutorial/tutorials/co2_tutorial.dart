import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/city_tutorial.dart';

class CO2Tutorial extends BaseTutorial {
  CO2Tutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.youCanSeeTheseBlueParticlesComingFromTheCities;

  @override
  String? getDoYouKnowText(BuildContext context) =>
      context.strings.theOceansAbsorbUpTo30OfTheCarbonDioxide;

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 10 &&
        module.isTutorialShown<CityTutorial>();
  }

  @override
  void onShowing() {
    final citiesSortedByEmission = game.cityModule.cities.toList()
      ..sort((a, b) => b.co2Emission.compareTo(a.co2Emission));
    focusOn(citiesSortedByEmission.first);
  }
}
