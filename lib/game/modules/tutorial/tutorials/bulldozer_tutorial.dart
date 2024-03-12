import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class BulldozerTutorial extends BaseTutorial {
  BulldozerTutorial(super.game);

  @override
  String? get mainTutorialText =>
      'Cities like to let out bulldozers to clear some more space for fields and farms. Actually bulldozers can be useful for you :)';

  @override
  String? get doYouKnowText =>
      'Agriculture is the leading cause of deforestation on the planet.';

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
      focusOn(bulldozers.random());
    }
  }
}
