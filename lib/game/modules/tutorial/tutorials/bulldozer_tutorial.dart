import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class BulldozerTutorial extends BaseTutorial {
  BulldozerTutorial(super.game);

  @override
  String? get mainTutorialText =>
      'Cities sometimes release bulldozers to clear land for fields and farms, especially when they start having food problems. You can break a bulldozer by tapping on it.';

  @override
  String? get doYouKnowText =>
      'Agriculture is the leading cause of deforestation on the planet.';

  @override
  bool canBeShown(TutorialModule module) {
    return game.bulldozerModule.bulldozers
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
