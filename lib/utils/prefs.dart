import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;

  static Future<void> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static bool get tutorialEnabled => _prefs.getBool('tutorial_enabled') ?? true;

  static set tutorialEnabled(bool enabled) =>
      _prefs.setBool('tutorial_enabled', enabled);
}
