import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

//ignore: avoid_classes_with_only_static_members
class Prefs {
  static late SharedPreferences _prefs;

  static Future<void> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static bool get tutorialEnabled => _prefs.getBool('tutorial_enabled') ?? true;

  static set tutorialEnabled(bool enabled) =>
      _prefs.setBool('tutorial_enabled', enabled);

  static Locale get currentLocale => Locale.fromSubtags(
      languageCode: _prefs.getString('language_code') ?? 'en');

  static set currentLocale(Locale locale) =>
      _prefs.setString('language_code', locale.languageCode);
}
