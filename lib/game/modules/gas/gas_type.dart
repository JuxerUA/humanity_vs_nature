import 'package:flutter/material.dart';

enum GasType {
  co2(Colors.indigo),
  ch4(Colors.white);

  const GasType(this.color);

  final Color color;
}
