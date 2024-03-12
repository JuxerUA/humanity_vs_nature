import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/extensions/sprite_component_extension.dart';
import 'package:humanity_vs_nature/game/mixins/animation_on_tap.dart';
import 'package:humanity_vs_nature/game/mixins/vehicle.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class BulldozerComponent extends SpriteComponent
    with
        Vehicle,
        TapCallbacks,
        CollisionCallbacks,
        HasGameRef<SimulationGame>,
        AnimationOnTap {
  BulldozerComponent({required this.city});

  static const radius = 10.0;

  static const workingDistance = 10.0;
  static const killTarget = 7;

  final CityComponent city;

  double hp = 5;
  int killCount = 0;
  TreeComponent? targetTree;
  bool isReturningToBase = false;
  bool isAngry = false;

  double get damagePerSecond => isAngry ? 10 : 7;

  @override
  FutureOr<void> onLoad() async {
    sprite = await getSpriteFromAsset(Assets.spritesBulldozer);
    anchor = Anchor.center;
    size *= 0.9;
    add(CircleHitbox(radius: radius));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isOutOfScreen(game.worldSize)) {
      game.bulldozerModule.removeBulldozer(this);
    }

    if (isReturningToBase) {
      if (position.distanceTo(city.position) < workingDistance) {
        game.bulldozerModule.removeBulldozer(this);
      } else {
        goToPosition(city.position, workingDistance, dt);
      }
      return;
    }

    _updateTargetTree();

    final target = targetTree;
    if (target != null) {
      if (position.distanceTo(target.position) < workingDistance) {
        if (target.doDamage(damagePerSecond * dt)) {
          if (++killCount >= (isAngry ? killTarget * 2 : killTarget)) goHome();
        }
      } else {
        goToPosition(target.position, workingDistance, dt);
      }
    } else {
      goHome();
    }
  }

  void goHome() {
    isReturningToBase = true;
    state = VehicleState.accelerate;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is TreeComponent) {
      if (other.isSapling && !isAngry) {
        other.doDamage(1);
      } else {
        isReturningToBase = false;
        targetTree = other;
        currentSpeed = VehicleState.rotation.targetSpeed;
      }
    } else if (other is BulldozerComponent) {
      final collisionVector = position - other.position;
      position += collisionVector * 0.1;
      hp -= 0.1;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    hp -= 1;
    if (hp < 1) game.bulldozerModule.removeBulldozer(this);
    animateOnTap();
  }

  void _updateTargetTree() {
    if (targetTree == null || targetTree?.isMounted == false) {
      final tree = isAngry
          ? game.treeModule.findFreeNearestTree(city.position)
          : game.treeModule.findFreeMatureNearestTree(position);
      targetTree = tree != targetTree && tree?.isMounted == true ? tree : null;
      state = VehicleState.stop;
    }
  }
}
