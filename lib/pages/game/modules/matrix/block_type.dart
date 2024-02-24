import 'package:flutter/material.dart';

enum BlockType {
  empty(Colors.white),
  tree(Colors.green),
  field(Colors.orangeAccent),
  farm(Colors.red),
  city(Colors.black);

  const BlockType(this.color);

  final Color color;
}
