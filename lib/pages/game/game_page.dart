import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/loading/loading_page.dart';
import 'package:humanity_vs_nature/pages/overlays/game_interface_overlay.dart';
import 'package:humanity_vs_nature/pages/overlays/pause_menu_overlay.dart';

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
    return PopScope(
      canPop: false,
      onPopInvoked: _onPop,
      child: Scaffold(
        body: SafeArea(
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
            },
          ),
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
