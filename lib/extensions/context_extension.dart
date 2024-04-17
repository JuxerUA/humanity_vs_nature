import 'package:flutter/material.dart';
import 'package:humanity_vs_nature/generated/l10n.dart';

extension ContextExt on BuildContext {
  S get strings => S.of(this);

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
