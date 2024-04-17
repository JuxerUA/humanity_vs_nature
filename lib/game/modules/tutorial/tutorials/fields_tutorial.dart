import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';

class FieldTutorial extends BaseTutorial {
  FieldTutorial(super.game);

  @override
  String? getMainTutorialText(BuildContext context) =>
      context.strings.theFieldsProvideCitiesAndFarmsWithPlantFoodOf;

  @override
  String? getDoYouKnowText(BuildContext context) =>
      context.strings.mostOfTheFoodGrownInTheFieldsIsUsed;

  @override
  bool canBeShown(TutorialModule module) {
    return module.timeElapsedSinceLastTutorialWasShown > 25 &&
        game.fieldModule.fields.isNotEmpty;
  }

  @override
  void onShowing() {
    final fields =
        game.fieldModule.fields.where((field) => field.areaInBlocks > 7);
    if (fields.isNotEmpty) {
      final field = fields.toList().random();
      target = field;
      field.startBlinking();
      focusOn(field);
    }
  }
}
