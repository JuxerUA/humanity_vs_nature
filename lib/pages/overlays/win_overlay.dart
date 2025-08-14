import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/pages/game_page.dart';
import 'package:humanity_vs_nature/pages/main_menu_page.dart';
import 'package:humanity_vs_nature/utils/game_sounds.dart';
import 'package:humanity_vs_nature/utils/styles.dart';
import 'package:humanity_vs_nature/widgets/pause_background.dart';
import 'package:humanity_vs_nature/widgets/tutorial_window.dart';

class WinOverlay extends StatelessWidget {
  const WinOverlay({super.key});

  static const overlayName = 'you_win';

  @override
  Widget build(BuildContext context) {
    return PauseBackground(
      child: TutorialWindow(
        width: 300,
        height: 400,
        buttons: [
          ElevatedButton(
            onPressed: () {
              AudioManager.play(
                GameSounds.buttonTapped(),
              );
              context.pushNamedAndRemoveAll(MainMenuPage.routeName);
            },
            child: Text(context.strings.mainMenu),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              AudioManager.play(
                GameSounds.buttonTapped(),
              );
              context.pushNamedAndRemoveAll(GamePage.routeName);
            },
            child: Text(context.strings.playAgain),
          ),
        ],
        children: [
          Text(
            context.strings
                .congratulationsntheGeneralLevelOfAwarenessAmongCitizensHasReachedA,
            style: Styles.black16,
          ),
        ],
      ),
    );
  }
}
