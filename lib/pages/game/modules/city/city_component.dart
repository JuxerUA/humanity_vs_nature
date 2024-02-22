import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class CityComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<SimulationGame> {
  static const double radius = 50;
  static const double maxBulldozerSpawnTime = 50;
  static const double maxCombineSpawnTime = 120;
  static const double gasSpawnTime = 0.1;

  var _timeForSpawnBulldozer = 0.0;
  var _timeForSpawnGas = 0.0;
  var _timeForSpawnCombine = 0.0;

  var _population = 0;
  var _populationWisdom = 0;

  final textPopulation = TextComponent();

  Spot get spot => Spot(position, radius);

  @override
  FutureOr<void> onLoad() async {
    sprite = await getSpriteFromAsset(Assets.spritesCity);
    anchor = Anchor.center;
    add(CircleHitbox(radius: 50));
    _population = randomFallback.nextInt(50) + 50;
    _populationWisdom = 1;
    textPopulation.position = size / 2;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _trySpawnBulldozer(dt);
    _trySpawnGas(dt);
    _trySpawnCombine(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    //game.showPauseMenu();
  }

  void _trySpawnBulldozer(double dt) {
    _timeForSpawnBulldozer -= dt;
    if (_timeForSpawnBulldozer < 0) {
      _timeForSpawnBulldozer =
          randomFallback.nextDouble() * maxBulldozerSpawnTime;

      // The ratio of bulldozers to mature trees is no more than 1 to 5
      if (game.treeModule.trees.where((tree) => tree.isMature).length >
          game.bulldozerModule.bulldozers.length * 5) {
        game.bulldozerModule.addBulldozer(this);
      }
    }
  }

  void _trySpawnGas(double dt) {
    _timeForSpawnGas -= dt;
    if (_timeForSpawnGas < 0) {
      _timeForSpawnGas = gasSpawnTime;
      final gasPosition =
          position + (Vector2.random() - Vector2.all(0.5)) * radius;
      game.gasModule.addGas(gasPosition);
    }
  }

  void _trySpawnCombine(double dt) {
    _timeForSpawnCombine -= dt;
    if (_timeForSpawnCombine < 0) {
      _timeForSpawnCombine = randomFallback.nextDouble() * maxCombineSpawnTime;
      game.combineModule.addCombine(this);
    }
  }
}
