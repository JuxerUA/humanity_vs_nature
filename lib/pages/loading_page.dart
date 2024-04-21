import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/styles.dart';
import 'package:humanity_vs_nature/widgets/pretty_menu_line.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            SimulationGame.gameBackgroundColor.shade700,
            SimulationGame.gameBackgroundColor.shade400,
          ],
        ),
      ),
      child: PrettyMenuLine(
        child: Center(
          child: Text(
            context.strings.loading,
            style: Styles.white20,
          ),
        ),
      ),
    );
  }
}
