import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class CityTutorial extends BaseTutorial {
  CityTutorial(super.game);

  @override
  String? get mainTutorialText =>
      "In this game, the cities are the only source of carbon dioxide. The larger the population of the city and the lower the average level of awareness of the city dwellers, the more carbon dioxide it creates.\nBy tapping on the town you can hasten the awareness of the townspeople :)\nAs awareness increases, citizens also consume less animal-based foods, which helps reduce the amount of methane.";

  @override
  String? get doYouKnowText => null;

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 10;
  }

  @override
  void onShowing() {
    if (game.cityModule.cities.isNotEmpty) {
      focusOn(game.cityModule.cities.random());
    }
  }
}
