import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/tutorial/base_tutorial.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/loading_page.dart';
import 'package:humanity_vs_nature/pages/overlays/game_interface_overlay.dart';
import 'package:humanity_vs_nature/pages/overlays/pause_menu_overlay.dart';
import 'package:humanity_vs_nature/pages/overlays/tutorial_overlay.dart';
import 'package:humanity_vs_nature/pages/overlays/tutorials_list_overlay.dart';
import 'package:humanity_vs_nature/pages/overlays/you_lost_overlay.dart';
import 'package:humanity_vs_nature/pages/overlays/you_win_overlay.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  static const routeName = '/game';

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _game = SimulationGame();

  @override
  Widget build(BuildContext context) {
    _game.strings = context.strings;

    return PopScope(
      canPop: false,
      onPopInvoked: _onPop,
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: GameWidget(
                game: _game,
                backgroundBuilder: (context) =>
                    Container(color: SimulationGame.gameBackgroundColor),
                loadingBuilder: (context) => const LoadingPage(),
                overlayBuilderMap: {
                  PauseMenuOverlay.overlayName: (context, game) =>
                      PauseMenuOverlay(game: _game),
                  GameInterfaceOverlay.overlayName: (context, game) =>
                      GameInterfaceOverlay(game: _game),
                  TutorialOverlay.overlayName: (context, game) =>
                      TutorialOverlay(game: _game),
                  TutorialsListOverlay.overlayName: (context, game) =>
                      TutorialsListOverlay(game: _game),
                  YouWinOverlay.overlayName: (context, game) =>
                      const YouWinOverlay(),
                  YouLostOverlay.overlayName: (context, game) =>
                      const YouLostOverlay(),
                },
              ),
            ),

            /// Status bar
            Container(
              height: MediaQuery.of(context).padding.top,
              width: double.infinity,
              color: Colors.black,
            )
          ],
        ),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _onPop(bool didPop) {
    _game.paused = true;
    _game.overlays.add(PauseMenuOverlay.overlayName);
  }
}
