import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/extensions/sprite_component_extension.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/pages/game/mixins/vehicle.dart';
import 'package:humanity_vs_nature/pages/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class CombineComponent extends SpriteComponent
    with Vehicle, TapCallbacks, HasGameRef<SimulationGame> {
  CombineComponent({
    required this.owner,
    required this.targetPlace,
  });

  static const radius = 10.0;
  static const workingDistance = 7.0;

  final CityComponent owner;
  Vector2? targetPlace;

  int hp = 5;

  bool get isReturningToBase => targetPlace == null;

  @override
  FutureOr<void> onLoad() async {
    sprite = await getSpriteFromAsset(Assets.spritesCombine);
    anchor = Anchor.center;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isOutOfScreen(game.size)) {
      game.combineModule.removeCombine(this);
    }

    if (isReturningToBase) {
      if (position.distanceTo(owner.position) < workingDistance) {
        game.combineModule.removeCombine(this);
      } else {
        goToPosition(owner.position, workingDistance, dt);
      }
      return;
    }

    final target = targetPlace;
    if (target != null) {
      if (position.distanceTo(target) < workingDistance) {
        game.farmModule.addFarm(target, owner);
        targetPlace = null;
        game.combineModule.removeCombine(this);
      } else {
        goToPosition(target, workingDistance, dt);
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    hp -= 1;
    if (hp < 1) {
      game.combineModule.removeCombine(this);
    }
  }
}
