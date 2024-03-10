import 'dart:async';

import 'package:flame/components.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/bulldozer_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/ch4_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/co2_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/disasters_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/farm_tutorial.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/tutorials/first_tutorial.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/overlays/tutorial_overlay.dart';

class TutorialModule extends Component with HasGameRef<SimulationGame> {
  /// Do you know?:
  /// - gases (mostly CO2, CH4) are the only cause of global warming
  /// - cities produce CO2
  /// - trees grows with CO2 (and fields too)
  /// - oceans eat 25-30% of CO2
  /// - farms produce CH4
  /// - fields is the main cause of deforestation
  /// - farms is the main cause of ocean dead zones ??? need to check
  /// - CH4 is almost as dangerous to global warming as CO2
  /// - CH4 become CO2 in 12 years
  /// - ratio of land required depending on the diet
  /// - most efficient way to fight global warming is increase people awareness

  late final unShownTutorials = <BaseTutorial>[
    FirstTutorial(game),
    BulldozerTutorial(game),
    CO2Tutorial(game),
    CH4Tutorial(game),
    FarmTutorial(game),
    DisastersTutorial(game),
  ];

  late final int totalTutorialsCount;

  BaseTutorial? showingTutorial;
  double timeElapsedSinceLastTutorialWasShown = 0;
  double timer = -1;

  @override
  FutureOr<void> onLoad() {
    totalTutorialsCount = unShownTutorials.length;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    timeElapsedSinceLastTutorialWasShown += dt;
    timer += dt;
    if (timer > 0.5) {
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
      ..overlays.remove(TutorialOverlay.overlayName)
      ..setCameraBounds();
    timeElapsedSinceLastTutorialWasShown = 0;
    timer = 0;
    unShownTutorials.remove(showingTutorial);
    showingTutorial = null;
    game.paused = false;

    if (unShownTutorials.isEmpty) {
      game.remove(game.tutorial);
    }
  }

  bool isTutorialShown<T>() {
    return unShownTutorials.whereType<T>().isEmpty;
  }
}
