import 'package:flutter/material.dart';

enum BlockType {
  empty(Colors.white),
  tree(Colors.green),
  field(Colors.orangeAccent),
  postField(Colors.brown),
  farm(Colors.red),
  city(Colors.black);

  const BlockType(this.color);

  final Color color;
}
