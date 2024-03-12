import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/city_tutorial.dart';

class CO2Tutorial extends BaseTutorial {
  CO2Tutorial(super.game);

  @override
  String? get mainTutorialText =>
      "You can see these blue particles coming from the cities. That's carbon dioxide or CO2. If there's too much CO2, you're going to lose.\nLuckily plants can absorb it :)";

  @override
  String? get doYouKnowText =>
      'The oceans absorb up to 30% of the carbon dioxide released into the atmosphere due to human activity. Phytoplankton - microscopic plants drifting in the water - play a key role in absorbing CO2 by the oceans.';

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
