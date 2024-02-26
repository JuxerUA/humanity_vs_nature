import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/overlays/game_interface_overlay.dart';
import 'package:humanity_vs_nature/pages/overlays/pause_menu_overlay.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  static const routeName = '/game';

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _simulationGame = SimulationGame();
  final backgroundColor = Colors.lightBlueAccent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GameWidget(
          game: _simulationGame,
          backgroundBuilder: (context) => Container(color: backgroundColor),
          loadingBuilder: (context) => Container(
            color: Colors.orange,
            child: const Center(child: Text('Loading...')),
          ),
          overlayBuilderMap: {
            PauseMenuOverlay.overlayName: (context, game) =>
                const PauseMenuOverlay(),
            GameInterfaceOverlay.overlayName: (context, game) =>
                const GameInterfaceOverlay(),
          },
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
