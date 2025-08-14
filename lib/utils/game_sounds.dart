import 'package:flame/extensions.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'audio_manager.dart';

export 'audio_manager.dart';

class GameSounds {
  GameSounds._();

  static const List<String> _rustlingGrassAssets = [
    Assets.soundsRustlingGrass1,
    Assets.soundsRustlingGrass2,
    Assets.soundsRustlingGrass3,
  ];

  static const List<String> _bulldozerAssets = [
    Assets.soundsBulldozer,
  ];

  static Future<void> preload() async {
    await AudioManager.preload([
      ..._rustlingGrassAssets,
      ..._bulldozerAssets,
    ]);
  }

  static String buttonTapped() => _rustlingGrassAssets.random();
  static String tutorialShown() => _rustlingGrassAssets.random();
  static String grassTapped() => _rustlingGrassAssets.random();
  static String coneSpawned() => _rustlingGrassAssets.random();
  static String treeTapped() => _rustlingGrassAssets.random();
  static String treeSpawned() => _rustlingGrassAssets.random();
  static String treeGrown() => _rustlingGrassAssets.random();
  static String treeDestroyed() => _rustlingGrassAssets.random();
  static String fieldSpawned() => _rustlingGrassAssets.random();
  static String cityTapped() => _rustlingGrassAssets.random();
  static String farmSpawned() => _rustlingGrassAssets.random();
  static String farmTapped() => _rustlingGrassAssets.random();
  static String farmDestroyed() => _rustlingGrassAssets.random();
  static String bulldozerSpawned() => _bulldozerAssets.random();
  static String bulldozerMoving() => _bulldozerAssets.random();
  static String bulldozerTapped() => _bulldozerAssets.random();
  static String bulldozerDestroyed() => _bulldozerAssets.random();
}
