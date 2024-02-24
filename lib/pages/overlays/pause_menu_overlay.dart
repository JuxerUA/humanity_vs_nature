import 'package:flutter/material.dart';

class PauseMenuOverlay extends StatelessWidget {
  const PauseMenuOverlay({super.key});

  static const overlayName = 'pause_menu';

  /// OVERLAYS
  ///
  /// Gameplay feature:
  /// - welcome, what to do and how to win/loss
  /// - trees
  /// - cities
  /// - bulldozers
  /// - farms
  /// - fields
  /// - combines
  /// - gases
  /// - win/loss screen + maybe statistics
  ///
  /// Science facts:
  /// - gases (CO2, CH4 and some more) are the only cause of global warming
  /// - cities produce CO2
  /// - trees grows with CO2 (and fields too)
  /// - oceans eat 25-30% of CO2
  /// - farms produce CH4
  /// - farms is the main cause of deforestation
  /// - farms is the main cause of ocean dead zones ??? need to check
  /// - CH4 even more dangerous for global warming then CO2 ??? need to check
  /// - CH4 become CO2 in 12 years
  /// - ratio of land required depending on the diet
  /// - most efficient way to fight global warming is increase mindfulness and be vegan

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 200,
          height: 300,
          color: Colors.orange,
          child: const Center(child: Text('PAUSE')),
        ),
      ),
    );
  }
}
