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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: SimulationGame(),
        backgroundBuilder: (context) => Container(color: Colors.lightGreen),
      ),
    );
  }
}
