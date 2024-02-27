import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game/game_page.dart';
import 'package:humanity_vs_nature/pages/main_menu/main_menu_page.dart';
import 'package:humanity_vs_nature/utils/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HumanityVsNature',
      theme: appTheme,
      routes: {
        MainMenuPage.routeName: (context) => const MainMenuPage(),
        GamePage.routeName: (context) => const GamePage(),
      },
      initialRoute: MainMenuPage.routeName,
    );
  }
}
