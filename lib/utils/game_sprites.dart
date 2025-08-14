import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:humanity_vs_nature/generated/assets.dart';

class GameSprites {
  GameSprites._();

  static late final Sprite cone;
  static late final Sprite youngTree;
  static late final Sprite matureTree;
  static late final Sprite farm;
  static late final Sprite city;
  static late final Sprite bulldozer1;
  static late final Sprite bulldozer2;

  static Future<void> preload() async {
    cone = await _getSpriteFromAsset(Assets.spritesCone);
    youngTree = await _getSpriteFromAsset(Assets.spritesYoungTree);
    matureTree = await _getSpriteFromAsset(Assets.spritesMatureTree);
    farm = await _getSpriteFromAsset(Assets.spritesFarm);
    city = await _getSpriteFromAsset(Assets.spritesCity);
    bulldozer1 = await _getSpriteFromAsset(Assets.spritesBulldozer1);
    bulldozer2 = await _getSpriteFromAsset(Assets.spritesBulldozer2);
  }

  static Future<Sprite> _getSpriteFromAsset(String asset) async {
    final data = await rootBundle.load(asset);
    final bytes = data.buffer.asUint8List();
    final image = await decodeImageFromList(Uint8List.fromList(bytes));
    return Sprite(image);
  }
}
