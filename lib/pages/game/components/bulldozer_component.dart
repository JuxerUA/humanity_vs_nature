import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/extensions/sprite_component_extension.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/pages/game/mixins/vehicle.dart';
import 'package:humanity_vs_nature/pages/game/modules/trees/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class BulldozerComponent extends SpriteComponent
    with Vehicle, TapCallbacks, CollisionCallbacks, HasGameRef<SimulationGame> {
  BulldozerComponent({required this.base});

  static const radius = 10.0;
  static const damagePerSecond = 5.0;
  static const workingDistance = 7.0;

  final PositionComponent base;

  int hp = 5;
  TreeComponent? targetTree;
  bool isReturningToBase = false;

  @override
  FutureOr<void> onLoad() async {
    sprite = await getSpriteFromAsset(Assets.spritesBulldozer);
    anchor = Anchor.center;
    add(CircleHitbox(radius: radius));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isOutOfScreen(game.size)) game.removeBulldozer(this);

    if (isReturningToBase) {
      if (position.distanceTo(base.position) < workingDistance) {
        game.removeBulldozer(this);
      } else {
        goToPosition(base.position, workingDistance, dt);
      }
      return;
    }

    _updateTargetTree();

    final target = targetTree;
    if (target != null) {
      if (position.distanceTo(target.position) < workingDistance) {
        target.doDamage(damagePerSecond * dt);
      } else {
        goToPosition(target.position, workingDistance, dt);
      }
    } else {
      isReturningToBase = true;
      state = VehicleState.accelerate;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is TreeComponent) {
      if (other.isSapling) {
        other.doDamage(1);
      } else {
        targetTree = other;
        currentSpeed = VehicleState.rotation.targetSpeed;
      }
    } else if (other is BulldozerComponent) {
      final collisionVector = position - other.position;
      position += collisionVector * 0.1;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    hp -= 1;
    if (hp < 1) game.removeBulldozer(this);
  }

  void _updateTargetTree() {
    if (targetTree == null || targetTree?.isMounted == false) {
      final tree = game.treesModule.findFreeMatureNearestTree(position);
      targetTree = tree != targetTree && tree?.isMounted == true ? tree : null;
      state = VehicleState.stop;
    }
  }
}
