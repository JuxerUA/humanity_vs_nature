import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class CityComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<SimulationGame> {
  static const double radius = 50;
  static const double maxBulldozerSpawnTime = 50;
  static const double gasSpawnTime = 0.1;

  var _timeForSpawnBulldozer = 0.0;
  var _timeForSpawnGas = 0.0;

  Spot get spot => Spot(position, radius);

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
    _trySpawnGas(dt);
  }

  void _trySpawnBulldozer(double dt) {
    _timeForSpawnBulldozer -= dt;
    if (_timeForSpawnBulldozer < 0) {
      _timeForSpawnBulldozer = Random().nextDouble() * maxBulldozerSpawnTime;

      // The ratio of bulldozers to mature trees is no more than 1 to 5
      if (game.trees.where((tree) => tree.isMature).length >
          game.bulldozers.length * 5) {
        game.addBulldozer(this);
      }
    }
  }

  void _trySpawnGas(double dt) {
    _timeForSpawnGas -= dt;
    if (_timeForSpawnGas < 0) {
      _timeForSpawnGas = gasSpawnTime;
      final gasPosition =
          position + (Vector2.random() - Vector2.all(0.5)) * radius;
      game.gasSystem.addGas(gasPosition);
    }
  }
}
