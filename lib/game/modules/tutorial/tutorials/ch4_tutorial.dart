import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/co2_tutorial.dart';

class CH4Tutorial extends BaseTutorial {
  CH4Tutorial(super.game);

  @override
  String? get mainTutorialText =>
      "There is another important gas, methane or CH4. You can see some white particles here. That's it! Note that methane, although smaller in volume, affects the Pollution bar 80 times more than carbon dioxide.";

  @override
  String? get doYouKnowText =>
      'Although there is much less methane in the atmosphere than carbon dioxide (about 80 times less), it can cause more than 80 times more powerful greenhouse effect. So the effect of these two gases on the greenhouse effect is almost equal. However, we cannot directly reduce the amount of methane in the atmosphere (trees do not absorb methane). We can only wait for the methane to transform into carbon dioxide after about 12 years.';

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 5 &&
        game.gasModule.currentTotalCH4Volume > 40 &&
        module.isTutorialShown<CO2Tutorial>();
  }

  @override
  void onShowing() {}
}
