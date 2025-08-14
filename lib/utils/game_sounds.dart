import 'dart:math';

import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/utils/audio_manager.dart';

class GameSounds {
  GameSounds._();

  static const String bulldozer = Assets.soundsBulldozer;

  static const List<String> _rustlingGrassOptions = [
    Assets.soundsRustlingGrass1,
    Assets.soundsRustlingGrass2,
    Assets.soundsRustlingGrass3,
  ];

  static final Random _random = Random();

  static Future<void> load() async {
    await AudioManager.preload([
      bulldozer,
      ..._rustlingGrassOptions,
    ]);
  }

  static String rustlingGrass() {
    return _rustlingGrassOptions[_random.nextInt(_rustlingGrassOptions.length)];
  }
}
