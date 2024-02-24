import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/overlays/pause_menu_overlay.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  static const routeName = '/game';

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _simulationGame = SimulationGame();
  final _grassColor = Colors.lightGreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GameWidget(
          game: _simulationGame,
          backgroundBuilder: (context) => Container(color: _grassColor),
          loadingBuilder: (context) => Container(
            color: Colors.orange,
            child: const Center(child: Text('Loading...')),
          ),
          overlayBuilderMap: {
            PauseMenuOverlay.overlayName: (context, game) =>
                const PauseMenuOverlay(),
          },
        ),
      ),
      backgroundColor: _grassColor,
      bottomNavigationBar: ElevatedButton(
        onPressed: () =>
            setState(() => _simulationGame.paused = !_simulationGame.paused),
        child: Text(_simulationGame.paused ? 'Resume' : 'Pause'),
      ),
    );
  }
}
