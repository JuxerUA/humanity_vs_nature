import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/widgets/pretty_menu_line.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SimulationGame.gameBackgroundColor,
      child: const PrettyMenuLine(
        child: Center(
          child: Text(
            'Loading',
            style: Styles.black20,
          ),
        ),
      ),
    );
  }
}
