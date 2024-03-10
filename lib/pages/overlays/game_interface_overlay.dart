import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/game/modules/gas/gas_module.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
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
        /// Top gaming bar
        Column(
          children: [
            SizedBox(
              height: 46,
              child: Row(
                children: [
                  /// Gas counters
                  Container(
                    width: 132,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.blueAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// CO2 counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: game.currentCO2Value,
                              builder: (context, co2Volume, child) => Text(
                                'CO2: $co2Volume',
                                style: Styles.black16,
                              ),
                            ),
                            const Text(
                              'x${GasModule.multiplierCO2}',
                              style: Styles.white12,
                            ),
                          ],
                        ),

                        /// CH4 counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: game.currentCH4Value,
                              builder: (context, ch4Volume, child) => Text(
                                'CH4: $ch4Volume',
                                style: Styles.black16,
                              ),
                            ),
                            const Text(
                              'x${GasModule.multiplierCH4}',
                              style: Styles.white12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// Win/Lose progress lines
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            /// Win progress line (awareness)
                            Expanded(
                              child: Stack(
                                children: [
                                  /// Line
                                  Container(
                                    color: Colors.green.shade300,
                                    width: constraints.maxWidth,
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: ValueListenableBuilder(
                                        valueListenable:
                                            game.awarenessPercentage,
                                        builder: (context, awarenessPercentage,
                                            child) {
                                          return Container(
                                            color: Colors.green.shade800,
                                            width: constraints.maxWidth *
                                                awarenessPercentage /
                                                100,
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  /// Text
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: ValueListenableBuilder(
                                        valueListenable:
                                            game.awarenessPercentage,
                                        builder: (context, awarenessPercentage,
                                            child) {
                                          return Text(
                                            'Awareness: $awarenessPercentage/75%',
                                            style: Styles.black14,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Lose progress line (pollution)
                            Expanded(
                              child: Stack(
                                children: [
                                  /// Line
                                  Container(
                                    color: Colors.orange.shade300,
                                    width: constraints.maxWidth,
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: ValueListenableBuilder(
                                        valueListenable:
                                            game.pollutionPercentage,
                                        builder: (context, pollutionPercentage,
                                            child) {
                                          return Container(
                                            color: Colors.orange.shade900,
                                            width: constraints.maxWidth *
                                                pollutionPercentage /
                                                100,
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  /// Text
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: ValueListenableBuilder(
                                        valueListenable:
                                            game.pollutionPercentage,
                                        builder: (context, pollutionPercentage,
                                            child) {
                                          return Text(
                                            'Pollution: $pollutionPercentage/100%',
                                            style: Styles.black14,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// Countdown to loss
            ValueListenableBuilder(
              valueListenable: game.countdownToLoss,
              builder: (context, count, child) {
                return count <= SimulationGame.timeToStopCountdown && count > 0
                    ? Text('$count', style: Styles.black16)
                    : const SizedBox();
              },
            ),
          ],
        ),

        const Expanded(child: SizedBox()),

        /// Pause button
        IconButton(
          onPressed: _onPauseTap,
          icon: const Icon(Icons.pause),
        ),
      ],
    );
  }

  void _onPauseTap() {
    game.paused = true;
    game.overlays.add(PauseMenuOverlay.overlayName);
  }
}
