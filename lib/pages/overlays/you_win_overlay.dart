import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/pages/game_page.dart';
import 'package:humanity_vs_nature/pages/main_menu_page.dart';
import 'package:humanity_vs_nature/utils/styles.dart';
import 'package:humanity_vs_nature/widgets/pause_background.dart';
import 'package:humanity_vs_nature/widgets/tutorial_window.dart';

class YouWinOverlay extends StatelessWidget {
  const YouWinOverlay({super.key});

  static const overlayName = 'you_win';

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
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.pushNamedAndRemoveAll(GamePage.routeName),
            child: const Text('Play Again!'),
          ),
        ],
        children: const [
          Text(
            'Congratulations!\nThe general level of awareness among citizens has reached a level of no return. Global warming is no longer a threat to us. We can breathe.\nCongratulations again!',
            style: Styles.black16,
          ),
        ],
      ),
    );
  }
}
