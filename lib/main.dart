import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:humanity_vs_nature/generated/l10n.dart';
import 'package:humanity_vs_nature/pages/game_page.dart';
import 'package:humanity_vs_nature/pages/main_menu_page.dart';
import 'package:humanity_vs_nature/utils/prefs.dart';
import 'package:humanity_vs_nature/utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();

  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  final currentLocaleNotifier = ValueNotifier(Prefs.currentLocale);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentLocaleNotifier,
      builder: (context, currentLocale, child) {
        return MaterialApp(
          title: 'Humanity VS Nature',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          routes: {
            MainMenuPage.routeName: (context) =>
                MainMenuPage(currentLocaleNotifier: currentLocaleNotifier),
            GamePage.routeName: (context) => const GamePage(),
          },
          initialRoute: MainMenuPage.routeName,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: currentLocale,
        );
      },
    );
  }
}
