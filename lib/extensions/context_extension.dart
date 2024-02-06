import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T?>(
      routeName,
      arguments: arguments,
    );
  }

  void pop([dynamic result]) => Navigator.of(this).pop(result);
}
