import 'dart:math';

import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    required this.game,
    super.key,
  });

  static const overlayName = 'first_tutorial';

  final SimulationGame game;

  @override
  Widget build(BuildContext context) {
    final tutorialText = game.tutorial.showingTutorial?.mainTutorialText;
    final doYouKnowText = game.tutorial.showingTutorial?.doYouKnowText;

    return Container(
      color: Colors.black12,
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
          final topMargin = constraints.maxHeight / 2 - padding;

          return Center(
            child: Container(
              width: width,
              height: height,
              margin: EdgeInsets.only(top: topMargin),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child:
                  ListView(children: [
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
                      const Text('Do you know?', style: Styles.black16),
                      Text(doYouKnowText, style: Styles.black14),
                    ],
                  ],)),

                  //const Expanded(child: SizedBox(height: 10)),

                  /// Got It! button
                  ElevatedButton(
                    onPressed: _onGotItTap,
                    child: const Text('Got It!'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onGotItTap() => game.tutorial.closeTutorial();
}
