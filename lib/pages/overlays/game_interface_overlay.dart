import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/pages/overlays/pause_menu_overlay.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

class GameInterfaceOverlay extends StatelessWidget {
  const GameInterfaceOverlay({
    required this.game,
    super.key,
  });

  static const overlayName = 'game_interface';

  final SimulationGame game;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: Colors.black26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: game.currentCO2Value,
                      builder: (context, value, child) => Text(
                        'CO2: ${value.round()}',
                        style: Styles.black16,
                      ),
                    ),
                    const Text('x1', style: Styles.white12),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: game.currentCH4Value,
                      builder: (context, value, child) => Text(
                        'CH4: ${value.round()}',
                        style: Styles.black16,
                      ),
                    ),
                    const Text('x80', style: Styles.white12),
                  ],
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _onPauseTap,
              icon: const Icon(Icons.pause),
            ),
          ],
        ),
      ],
    );
  }

  void _onPauseTap() {
    game.paused = true;
    game.overlays.add(PauseMenuOverlay.overlayName);
  }
}
