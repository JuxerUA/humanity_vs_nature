import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/main_menu_page.dart';
import 'package:humanity_vs_nature/widgets/pause_background.dart';
import 'package:humanity_vs_nature/widgets/pretty_menu_line.dart';

class PauseMenuOverlay extends StatelessWidget {
  const PauseMenuOverlay({
    required this.game,
    super.key,
  });

  static const overlayName = 'pause_menu';

  final SimulationGame game;

  @override
  Widget build(BuildContext context) {
    return PauseBackground(
      child: PrettyMenuLine(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: _onResumeTap,
              child: const Text('Resume'),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: () =>
                  context.pushNamedAndRemoveAll(MainMenuPage.routeName),
              child: const Text('Main Menu'),
            ),
            const SizedBox(height: 20),
            const ElevatedButton(
              onPressed: SystemNavigator.pop,
              child: Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }

  void _onResumeTap() {
    game.paused = false;
    game.overlays.remove(overlayName);
  }
}
