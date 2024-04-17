import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class CityTutorial extends BaseTutorial {
  CityTutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.inThisGameTheCitiesAreTheOnlySourceOf;

  @override
  String? getDoYouKnowText(BuildContext context) => null;

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 10;
  }

  @override
  void onShowing() {
    final cities = game.cityModule.cities;
    if (cities.isNotEmpty) {
      final city = cities.random();
      target = city;
      city.startBlinking();
      focusOn(city);
    }
  }
}
