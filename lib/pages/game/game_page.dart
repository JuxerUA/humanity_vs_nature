import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';

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
      body: GameWidget(
        game: _simulationGame,
        backgroundBuilder: (context) => Container(color: _grassColor),
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
