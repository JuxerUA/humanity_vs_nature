import 'dart:async';

import 'package:flame/components.dart';
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
import 'package:humanity_vs_nature/pages/overlays/tutorials_list_overlay.dart';
import 'package:humanity_vs_nature/utils/prefs.dart';

class TutorialModule extends Component with HasGameRef<SimulationGame> {
  late final unShownTutorials = <BaseTutorial>[
    WelcomeTutorial(game),
    InterfaceTutorial(game),
    GoalTutorial(game),
    TreesTutorial(game),
    CityTutorial(game),
    CO2Tutorial(game),
    BulldozerTutorial(game),
    CH4Tutorial(game),
    FarmTutorial(game),
    FieldTutorial(game),
    DisastersTutorial(game),
  ];

  late final int totalTutorialsCount;

  BaseTutorial? showingTutorial;
  BaseTutorial? showingTutorialFromTutorials;
  double timeElapsedSinceLastTutorialWasShown = 0;
  double timer = -1;

  late final bool tutorialEnabled;

  @override
  FutureOr<void> onLoad() {
    tutorialEnabled = Prefs.tutorialEnabled;
    totalTutorialsCount = unShownTutorials.length;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!tutorialEnabled || unShownTutorials.isEmpty) return;

    timeElapsedSinceLastTutorialWasShown += dt;
    timer += dt;
    if (timer > 1) {
      timer = 0;
      if (showingTutorial == null) {
        for (final unShownTutorial in unShownTutorials) {
          if (unShownTutorial.canBeShown(this)) {
            showTutorial(unShownTutorial);
            return;
          }
        }
      }
    }
    super.update(dt);
  }

  void showTutorial(BaseTutorial tutorial) {
    showingTutorial = tutorial;
    game
      ..overlays.add(TutorialOverlay.overlayName)
      ..setCameraBounds(tutorialBounds: true);
    tutorial.onShowing();
  }

  void closeTutorial() {
    game
      ..camera.stop()
      ..overlays.remove(TutorialOverlay.overlayName)
      ..setCameraBounds();

    if (showingTutorial != null) {
      timeElapsedSinceLastTutorialWasShown = 0;
      timer = 0;
      unShownTutorials.remove(showingTutorial);
      showingTutorial?.target?.stopBlinking();
      showingTutorial = null;
      game.paused = false;
    }

    if (showingTutorialFromTutorials != null) {
      game.paused = true;
      showingTutorialFromTutorials?.target?.stopBlinking();
      showingTutorialFromTutorials = null;
      game.overlays.add(TutorialsListOverlay.overlayName);
    }
  }

  bool isTutorialShown<T>() {
    return unShownTutorials.whereType<T>().isEmpty;
  }
}
