import 'package:flame/extensions.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/utils/audio_manager.dart';

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

  static String rustlingGrass() => _rustlingGrassAssets.random();
  static String bulldozer() => _bulldozerAssets.random();
}
