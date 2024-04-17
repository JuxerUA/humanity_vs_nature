import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class TreesTutorial extends BaseTutorial {
  TreesTutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.treesUseCo2BlueParticlesToGrowTheLargestTree;

  @override
  String? getDoYouKnowText(BuildContext context) => context
      .strings.plantsGainMassMainlyByConvertingCarbonDioxideIntoCarbohydrate;

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 5 &&
        game.treeModule.trees.where((tree) => tree.isMature).isNotEmpty;
  }

  @override
  void onShowing() {
    final matureTrees = game.treeModule.trees.where((tree) => tree.isMature);
    if (matureTrees.isNotEmpty) {
      final tree = matureTrees.toList().random();
      target = tree;
      tree.startBlinking();
      focusOn(tree);
    }
  }
}
