import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Sprite> getSpriteFromAsset(String asset) async {
  final data = await rootBundle.load(asset);
  final bytes = data.buffer.asUint8List();
  final image = await decodeImageFromList(Uint8List.fromList(bytes));
  return Sprite(image);
}