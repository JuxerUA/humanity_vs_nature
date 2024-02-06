import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/pages/game/game_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  static const routeName = '/mainMenu';

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Play simulation mode button
            ElevatedButton(
              onPressed: () => context.pushNamed(GamePage.routeName),
              child: const Text('Play Simulation'),
            ),
            const SizedBox(height: 20),

            // Play arcade mode button
            ElevatedButton(
              onPressed: () => context.pushNamed(GamePage.routeName),
              child: const Text('Play Arcade'),
            ),
            const SizedBox(height: 20),

            // Exit button
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }
}
