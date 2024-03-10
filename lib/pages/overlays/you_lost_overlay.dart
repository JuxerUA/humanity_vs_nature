import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/pages/game_page.dart';
import 'package:humanity_vs_nature/pages/main_menu_page.dart';
import 'package:humanity_vs_nature/utils/styles.dart';
import 'package:humanity_vs_nature/widgets/pause_background.dart';
import 'package:humanity_vs_nature/widgets/tutorial_window.dart';

class YouLostOverlay extends StatelessWidget {
  const YouLostOverlay({super.key});

  static const overlayName = 'you_lost';

  @override
  Widget build(BuildContext context) {
    return PauseBackground(
      child: TutorialWindow(
        width: 300,
        height: 400,
        buttons: [
          ElevatedButton(
            onPressed: () =>
                context.pushNamedAndRemoveAll(MainMenuPage.routeName),
            child: const Text('Main Menu'),
          ),
          ElevatedButton(
            onPressed: () => context.pushNamedAndRemoveAll(GamePage.routeName),
            child: const Text('Play Again!'),
          ),
        ],
        children: const [
          Text(
            "You lost! What a shame! Don't lose next time!",
            style: Styles.black16,
          ),
        ],
      ),
    );
  }
}
