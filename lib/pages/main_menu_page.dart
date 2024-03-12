import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/pages/game_page.dart';
import 'package:humanity_vs_nature/utils/prefs.dart';
import 'package:humanity_vs_nature/utils/styles.dart';
import 'package:humanity_vs_nature/widgets/pretty_menu_line.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  static const routeName = '/mainMenu';

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    final tutorialEnabled = Prefs.tutorialEnabled;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          color: Colors.brown,
          child: PrettyMenuLine(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //TODO for future updates
                // const SizedBox(height: 6),
                // const LanguageSelector(),
                const Expanded(child: SizedBox()),

                /// Logo
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
                const SizedBox(height: 50),

                /// Start button
                ElevatedButton(
                  onPressed: () =>
                      context.pushNamedAndRemoveAll(GamePage.routeName),
                  child: const Text('Start'),
                ),
                const SizedBox(height: 22),

                Text(
                  tutorialEnabled ? 'Tutorial enabled' : 'Tutorial disabled',
                  style: Styles.white20,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),

                ElevatedButton(
                  onPressed: () => setState(
                    () => Prefs.tutorialEnabled = !Prefs.tutorialEnabled,
                  ),
                  child: Text(tutorialEnabled ? 'Disable' : 'Enable'),
                ),

                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
