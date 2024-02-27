import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/pages/game/game_page.dart';
import 'package:humanity_vs_nature/pages/widgets/pretty_menu_line.dart';

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
      body: PrettyMenuLine(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            const Center(
              child: SizedBox(
                height: 150,
                width: 230,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'HUMANITY',
                      style: TextStyle(
                        fontFamily: 'ArchivoBlack',
                        fontSize: 24,
                        height: 0.5,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      'VS',
                      style: TextStyle(
                        fontFamily: 'ArchivoBlack',
                        fontSize: 150,
                        height: 0.5,
                        //color: Colors.deepOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'NATURE',
                      style: TextStyle(
                        fontFamily: 'ArchivoBlack',
                        fontSize: 24,
                        height: 0.5,
                        color: Colors.lime,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),

            // Start button
            ElevatedButton(
              onPressed: () =>
                  context.pushNamedAndRemoveAll(GamePage.routeName),
              child: const Text('Start'),
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
