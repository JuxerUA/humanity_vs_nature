import 'package:flame/components.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class GameSprites {
  GameSprites._();

  static late final Sprite cone;
  static late final Sprite youngTree;
  static late final Sprite matureTree;
  static late final Sprite farm;
  static late final Sprite city;
  static late final Sprite bulldozer1;
  static late final Sprite bulldozer2;

  static Future<void> load() async {
    cone = await getSpriteFromAsset(Assets.spritesCone);
    youngTree = await getSpriteFromAsset(Assets.spritesYoungTree);
    matureTree = await getSpriteFromAsset(Assets.spritesMatureTree);
    farm = await getSpriteFromAsset(Assets.spritesFarm);
    city = await getSpriteFromAsset(Assets.spritesCity);
    bulldozer1 = await getSpriteFromAsset(Assets.spritesBulldozer1);
    bulldozer2 = await getSpriteFromAsset(Assets.spritesBulldozer2);
  }
}

