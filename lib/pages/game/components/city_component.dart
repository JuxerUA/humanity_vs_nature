import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game_mode.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class CityComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<SimulationGameMode> {
  static const double radius = 50;
  static const double maxBulldozerSpawnTime = 50;

  var _timeForSpawnBulldozer = 0.0;

  @override
  FutureOr<void> onLoad() async {
    sprite = await getSpriteFromAsset(Assets.spritesCity);
    anchor = Anchor.center;
    add(CircleHitbox(radius: 50));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _trySpawnBulldozer(dt);
  }

  void _trySpawnBulldozer(double dt) {
    _timeForSpawnBulldozer -= dt;
    if (_timeForSpawnBulldozer < 0) {
      _timeForSpawnBulldozer = Random().nextDouble() * maxBulldozerSpawnTime;
      if (game.trees.length > 4) {
        game.addBulldozer(this);
      }
    }
  }
}
