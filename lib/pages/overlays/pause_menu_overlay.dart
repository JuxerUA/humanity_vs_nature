import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/main_menu/main_menu_page.dart';
import 'package:humanity_vs_nature/pages/widgets/pretty_menu_line.dart';

class PauseMenuOverlay extends StatelessWidget {
  const PauseMenuOverlay({
    required this.game,
    super.key,
  });

  static const overlayName = 'pause_menu';

  final SimulationGame game;

  /// OVERLAYS
  ///
  /// Gameplay feature:
  /// - welcome, what to do and how to win/loss
  /// - trees
  /// - cities
  /// - bulldozers
  /// - farms
  /// - fields
  /// - combines
  /// - gases
  /// - win/loss screen + maybe statistics
  ///
  /// Science facts:
  /// - gases (CO2, CH4 and some more) are the only cause of global warming
  /// - cities produce CO2
  /// - trees grows with CO2 (and fields too)
  /// - oceans eat 25-30% of CO2
  /// - farms produce CH4
  /// - farms is the main cause of deforestation
  /// - farms is the main cause of ocean dead zones ??? need to check
  /// - CH4 even more dangerous for global warming then CO2 ??? need to check
  /// - CH4 become CO2 in 12 years
  /// - ratio of land required depending on the diet
  /// - most efficient way to fight global warming is increase mindfulness and be vegan

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
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
