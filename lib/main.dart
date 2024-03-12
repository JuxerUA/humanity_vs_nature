import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/pages/game_page.dart';
import 'package:humanity_vs_nature/pages/main_menu_page.dart';
import 'package:humanity_vs_nature/utils/prefs.dart';
import 'package:humanity_vs_nature/utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Humanity VS Nature',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routes: {
        MainMenuPage.routeName: (context) => const MainMenuPage(),
        GamePage.routeName: (context) => const GamePage(),
      },
      initialRoute: MainMenuPage.routeName,
    );
  }
}
