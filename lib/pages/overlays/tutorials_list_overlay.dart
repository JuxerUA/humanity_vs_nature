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
    return PauseBackground(
      child: PrettyMenuLine(
        color: Colors.black45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Center(child: Text('Tutorials', style: Styles.white20)),
            const SizedBox(height: 10),
            const Divider(color: Colors.white, thickness: 2),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Welcome', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(WelcomeTutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Interface', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(InterfaceTutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Game goal', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(GoalTutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Trees', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(TreesTutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bulldozers', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(BulldozerTutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Cities', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(CityTutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Farms', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(FarmTutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fields', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(FieldTutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Carbon dioxide (CO2)',
                        style: Styles.white16),
                    onTap: () => _popAndShowTutorial(CO2Tutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Methane (CH4)', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(CH4Tutorial(game)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Disasters', style: Styles.white16),
                    onTap: () => _popAndShowTutorial(DisastersTutorial(game)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onResumeTap,
              child: const Text('Resume'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _popAndShowTutorial(BaseTutorial tutorial) {
    game.overlays.remove(overlayName);
    game.paused = false;

    game.tutorial.showingTutorialFromTutorials = tutorial;
    game
      ..overlays.add(TutorialOverlay.overlayName)
      ..setCameraBounds(tutorialBounds: true);
    tutorial.onShowing();
  }

  void _onResumeTap() {
    game.paused = false;
    game.overlays.remove(overlayName);
  }
}
