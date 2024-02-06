import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/extensions/sprite_component_extension.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/pages/game/components/tree_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game_mode.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class BulldozerComponent extends SpriteComponent
    with TapCallbacks, CollisionCallbacks, HasGameRef<SimulationGameMode> {
  BulldozerComponent({
    required this.base,
  });

  static const maxSpeed = 50.0;
  static const rotationSpeed = 2.0;
  static const radius = 10.0;
  static const damagePerSecond = 5.0;
  static const workingDistance = 7.0;

  final PositionComponent base;

  int hp = 5;
  double _currentSpeed = 0;
  _State _state = _State.stop;
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

    if (isOutOfScreen(game.size)) {
      game.removeBulldozer(this);
    }

    if (isReturningToBase) {
      if (position.distanceTo(base.position) < workingDistance) {
        game.removeBulldozer(this);
      } else {
        _goToPosition(base.position, dt);
      }
      return;
    }

    _updateTargetTree();

    final target = targetTree;
    if (target != null) {
      if (position.distanceTo(target.position) < workingDistance) {
        target.doDamage(damagePerSecond * dt);
      } else {
        _goToPosition(target.position, dt);
      }
    } else {
      isReturningToBase = true;
      _state = _State.accelerate;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is TreeComponent) {
      targetTree = other;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    hp -= 1;
    if (hp < 1) {
      game.removeBulldozer(this);
    }
  }

  void _updateTargetTree() {
    if (targetTree == null || targetTree?.isMounted == false) {
      final tree = game.findFreeNearestTree(position);
      targetTree = tree != targetTree && tree?.isMounted == true ? tree : null;
      _state = _State.stop;
    }
  }

  void _goToPosition(Vector2 targetPosition, double dt) {
    final distance = position.distanceTo(targetPosition);
    final direction = Vector2(cos(angle), sin(angle));
    final directionToTarget = targetPosition - position;

    // Determinate state
    if (distance < workingDistance) {
      _state = _State.stop;
    } else {
      if (direction.angleTo(directionToTarget).abs() > 0.15) {
        _state = _State.rotation;
      } else {
        _state = _State.accelerate;
      }
    }

    final deltaSpeed = _state.targetSpeed - _currentSpeed;
    _currentSpeed += deltaSpeed * dt * 0.8;

    if (_state == _State.rotation) {
      final angleToTarget = atan2(directionToTarget.y, directionToTarget.x);
      final crossProduct = sin(angleToTarget - angle);
      final maxRotation = rotationSpeed * dt;
      final rotation = maxRotation * crossProduct.sign;
      angle += rotation;
    }

    final newDirection = Vector2(cos(angle), sin(angle));
    position += newDirection * _currentSpeed * dt;
  }
}

enum _State {
  accelerate(BulldozerComponent.maxSpeed),
  rotation(BulldozerComponent.maxSpeed / 5),
  stop(0);

  const _State(this.targetSpeed);

  final double targetSpeed;
}
