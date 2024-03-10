import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    return Navigator.of(this).pushNamed<T?>(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> pushNamedAndRemoveAll<T extends Object?>(
    String newRouteName, {
    Object? arguments,
  }) async {
    return Navigator.of(this).pushNamedAndRemoveUntil<T?>(
      newRouteName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  void pop([dynamic result]) => Navigator.of(this).pop(result);
}
