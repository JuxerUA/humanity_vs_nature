import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/extensions/sprite_component_extension.dart';
import 'package:humanity_vs_nature/game/mixins/animation_on_tap.dart';
import 'package:humanity_vs_nature/game/mixins/blink_mixin.dart';
import 'package:humanity_vs_nature/game/mixins/vehicle.dart';
import 'package:humanity_vs_nature/game/modules/city/city_component.dart';
import 'package:humanity_vs_nature/game/modules/tree/tree_component.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/game_sounds.dart';
import 'package:humanity_vs_nature/utils/game_sprites.dart';

class BulldozerComponent extends SpriteComponent
    with
        Vehicle,
        TapCallbacks,
        CollisionCallbacks,
        HasGameRef<SimulationGame>,
        AnimationOnTap,
        BlinkEffect {
  BulldozerComponent({required this.city});

  static const radius = 10.0;

  static const workingDistance = 10.0;
  static const killTarget = 7;

  final CityComponent city;

  double healthPoints = 7;
  int treesDestroyed = 0;
  TreeComponent? targetTree;
  bool isReturningToBase = false;
  bool isAngry = false;

  double get damagePerSecond => isAngry ? 10 : 7;

  @override
  FutureOr<void> onLoad() async {
    sprite = GameSprites.bulldozer1;
    size *= 0.5;
    anchor = Anchor.center;
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
          if (++treesDestroyed >= (isAngry ? killTarget * 2 : killTarget)) goHome();
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
      if (other.isCone && !isAngry) {
        other.doDamage(1);
      } else {
        isReturningToBase = false;
        targetTree = other;
        currentSpeed = VehicleState.rotation.targetSpeed;
      }
    } else if (other is BulldozerComponent) {
      final collisionVector = position - other.position;
      position += collisionVector * 0.1;
      healthPoints -= 0.1;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    AudioManager.play(
      GameSounds.bulldozerTapped(),
      position: event.canvasPosition,
    );
    healthPoints -= 1;
    if (healthPoints < 1) game.bulldozerModule.removeBulldozer(this);
    animateOnTap();
  }

  void _updateTargetTree() {
    if (targetTree == null || targetTree?.isMounted == false) {
      final tree = isAngry
          ? game.treeModule.findNearestFreeTree(city.position)
          : game.treeModule.findNearestFreeMatureTree(position);
      targetTree = tree != targetTree && tree?.isMounted == true ? tree : null;
      state = VehicleState.stop;
    }
  }
}
