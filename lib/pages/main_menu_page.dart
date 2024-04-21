import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/extensions/context_extension.dart';
import 'package:humanity_vs_nature/generated/l10n.dart';
import 'package:humanity_vs_nature/pages/game_page.dart';
import 'package:humanity_vs_nature/utils/prefs.dart';
import 'package:humanity_vs_nature/utils/styles.dart';
import 'package:humanity_vs_nature/widgets/language_selector.dart';
import 'package:humanity_vs_nature/widgets/pretty_menu_line.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({
    required this.currentLocaleNotifier,
    super.key,
  });

  static const routeName = '/mainMenu';

  final ValueNotifier<Locale> currentLocaleNotifier;

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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Colors.brown.shade800,
                Colors.brown.shade500,
              ],
            ),
          ),
          child: PrettyMenuLine(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                LanguageSelector(
                  onLocaleChanged: (locale) =>
                      widget.currentLocaleNotifier.value = locale,
                ),
                const Expanded(child: SizedBox()),

                /// Logo
                const Center(
                  child: SizedBox(
                    height: 160,
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
                            shadows: [Shadow(blurRadius: 10)],
                          ),
                          textAlign: TextAlign.left,
                          textScaler: TextScaler.noScaling,
                        ),
                        Text(
                          'VS',
                          style: TextStyle(
                            fontFamily: 'ArchivoBlack',
                            fontSize: 150,
                            height: 0.5,
                            color: Colors.lightBlueAccent,
                            shadows: [Shadow(blurRadius: 10)],
                          ),
                          textAlign: TextAlign.center,
                          textScaler: TextScaler.noScaling,
                        ),
                        Text(
                          'NATURE',
                          style: TextStyle(
                            fontFamily: 'ArchivoBlack',
                            fontSize: 24,
                            height: 0.5,
                            color: Colors.lime,
                            shadows: [Shadow(blurRadius: 10)],
                          ),
                          textAlign: TextAlign.right,
                          textScaler: TextScaler.noScaling,
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
                  child: Text(S.current.start),
                ),
                const SizedBox(height: 22),

                Text(
                  tutorialEnabled
                      ? context.strings.tutorialEnabled
                      : context.strings.tutorialDisabled,
                  style: Styles.white20,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),

                ElevatedButton(
                  onPressed: () => setState(
                    () => Prefs.tutorialEnabled = !Prefs.tutorialEnabled,
                  ),
                  child: Text(
                    tutorialEnabled
                        ? context.strings.disable
                        : context.strings.enable,
                  ),
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
