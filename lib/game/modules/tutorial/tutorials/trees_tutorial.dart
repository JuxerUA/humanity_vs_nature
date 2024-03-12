import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class TreesTutorial extends BaseTutorial {
  TreesTutorial(super.game);

  @override
  String? get mainTutorialText =>
      "Trees use CO2 (blue particles) to grow. The largest tree no longer absorbs the gas, but you can tap on it to make it drop cones.\nNew trees grow from the cones :)";

  @override
  String? get doYouKnowText =>
      "Plants gain mass mainly by converting carbon dioxide into carbohydrate. Thus, the more active a plant grows, the more carbon dioxide it absorbs.";

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 5 &&
        game.treeModule.trees.where((tree) => tree.isYoung).isNotEmpty;
  }

  @override
  void onShowing() {
    final youngTrees = game.treeModule.trees.where((tree) => tree.isYoung);
    if (youngTrees.isNotEmpty) {
      focusOn(youngTrees.toList().random());
    }
  }
}
