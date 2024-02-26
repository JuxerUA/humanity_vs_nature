import 'package:flutter/material.dart';

class GameInterfaceOverlay extends StatelessWidget {
  const GameInterfaceOverlay({super.key});

  static const overlayName = 'game_interface';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('CO2'),
            Text('CH4'),
          ],
        ),
        Row(
          children: [
            IconButton(onPressed: _onPauseTap, icon: Icon(Icons.pause)),
          ],
        ),
      ],
    );
  }

  void _onPauseTap() {}
}
