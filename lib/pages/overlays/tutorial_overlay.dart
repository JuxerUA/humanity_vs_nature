import 'dart:math';

import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/styles.dart';
import 'package:humanity_vs_nature/widgets/tutorial_background.dart';
import 'package:humanity_vs_nature/widgets/tutorial_window.dart';

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    required this.game,
    super.key,
  });

  static const overlayName = 'tutorial';

  final SimulationGame game;

  @override
  Widget build(BuildContext context) {
    final showingTutorial = game.tutorial.showingTutorial ??
        game.tutorial.showingTutorialFromTutorials;
    final tutorialText = showingTutorial?.getMainTutorialText(context);
    final doYouKnowText = showingTutorial?.getDoYouKnowText(context);

    return TutorialBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const padding = 20;
          const maxTutorialSize = 400;

          final width = min(
            constraints.maxWidth - padding * 2,
            maxTutorialSize,
          ).toDouble();
          final height = min(
            constraints.maxHeight - padding * 2,
            maxTutorialSize,
          ).toDouble();
          final topMargin = constraints.maxHeight / 2 - padding * 2;

          return TutorialWindow(
            width: width,
            height: height,
            margin: EdgeInsets.only(top: topMargin),
            buttons: [
              /// Got It! button
              ElevatedButton(
                onPressed: _onGotItTap,
                child: Text(context.strings.gotIt),
              )
            ],
            children: [
              /// Main tutorial text
              if (tutorialText != null)
                Text(
                  tutorialText,
                  style: Styles.black16,
                ),

              /// Divider
              if (tutorialText != null && doYouKnowText != null) ...[
                const Divider(color: Colors.black, thickness: 2),
                const SizedBox(height: 4),
              ],

              /// "Do you know?" text
              if (doYouKnowText != null) ...[
                Text(context.strings.doYouKnow, style: Styles.black16),
                Text(doYouKnowText, style: Styles.black14),
              ],
            ],
          );
        },
      ),
    );
  }

  void _onGotItTap() => game.tutorial.closeTutorial();
}
