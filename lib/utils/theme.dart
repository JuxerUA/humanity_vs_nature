import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/utils/styles.dart';

final ThemeData appTheme = ThemeData(
  colorSchemeSeed: Colors.brown,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: Styles.black16,
      backgroundColor: Colors.orangeAccent.shade100,
    ),
  ),
);