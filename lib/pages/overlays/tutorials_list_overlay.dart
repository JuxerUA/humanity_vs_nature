import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/bulldozer_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/ch4_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/city_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/co2_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/disasters_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/farm_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/fields_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/goal_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/interface_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/trees_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/welcome_tutorial.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/overlays/tutorial_overlay.dart';
import 'package:humanity_vs_nature/utils/game_sounds.dart';
import 'package:humanity_vs_nature/utils/styles.dart';
import 'package:humanity_vs_nature/widgets/pause_background.dart';
import 'package:humanity_vs_nature/widgets/pretty_menu_line.dart';

class TutorialsListOverlay extends StatelessWidget {
  const TutorialsListOverlay({
    required this.game,
    super.key,
  });

  static const overlayName = 'tutorials_list';

  final SimulationGame game;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return PauseBackground(
      child: PrettyMenuLine(
        color: Colors.black54,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Text(
                strings.tutorial,
                style: Styles.white20,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white, thickness: 2),
            Expanded(
              child: ListView(
                children: [
                  _makeListTile(strings.welcome, WelcomeTutorial(game)),
                  _makeListTile(strings.interface, InterfaceTutorial(game)),
                  _makeListTile(strings.gameGoal, GoalTutorial(game)),
                  _makeListTile(strings.trees, TreesTutorial(game)),
                  _makeListTile(strings.bulldozers, BulldozerTutorial(game)),
                  _makeListTile(strings.cities, CityTutorial(game)),
                  _makeListTile(strings.farms, FarmTutorial(game)),
                  _makeListTile(strings.fields, FieldTutorial(game)),
                  _makeListTile(strings.carbonDioxideCo2, CO2Tutorial(game)),
                  _makeListTile(strings.methaneCh4, CH4Tutorial(game)),
                  _makeListTile(strings.disasters, DisastersTutorial(game)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onResumeTap,
              child: Text(strings.resume),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _makeListTile(String title, BaseTutorial tutorial) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Styles.white16),
      onTap: () => _popAndShowTutorial(tutorial),
    );
  }

  void _popAndShowTutorial(BaseTutorial tutorial) {
    AudioManager.play(
      GameSounds.buttonTapped(),
    );
    game.overlays.remove(overlayName);
    game.paused = false;

    game.tutorial.showingTutorialFromTutorials = tutorial;
    game
      ..overlays.add(TutorialOverlay.overlayName)
      ..setCameraBounds(tutorialBounds: true);
    tutorial.onShowing();
  }

  void _onResumeTap() {
    AudioManager.play(
      GameSounds.buttonTapped(),
    );
    game.paused = false;
    game.overlays.remove(overlayName);
  }
}
