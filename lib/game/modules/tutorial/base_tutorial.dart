import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/mixins/blink_mixin.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorial_module.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';

export 'package:flame/extensions.dart';
export 'package:humanity_vs_nature/extensions/context_extension.dart';
export 'package:humanity_vs_nature/game/modules/tutorial/tutorial_module.dart';

typedef IsTutorialShownCallback = bool Function(BaseTutorial tutorial);

abstract class BaseTutorial {
  BaseTutorial(this.game);

  final SimulationGame game;

  BlinkEffect? target;

  String? getMainTutorialText(BuildContext context);

  String? getDoYouKnowText(BuildContext context);

  bool canBeShown(TutorialModule module);

  void onShowing();

  void focusOn(
    ReadOnlyPositionProvider target, {
    bool immediately = false,
  }) {
    game.camera.follow(
      TutorialPositionProvider(target),
      maxSpeed: immediately ? double.infinity : 400,
    );
  }
}

class TutorialPositionProvider implements ReadOnlyPositionProvider {
  TutorialPositionProvider(this.target);

  final ReadOnlyPositionProvider target;

  @override
  Vector2 get position => target.position + Vector2(0, 100);
}
