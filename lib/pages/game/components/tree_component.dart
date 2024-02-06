import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/extensions/sprite_component_extension.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/pages/game/components/city_component.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game_mode.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class TreeComponent extends SpriteComponent
    with TapCallbacks, CollisionCallbacks, HasGameRef<SimulationGameMode> {
  static const double radius = 10;

  Vector2 velocity = Vector2.zero();
  double hp = 30;

  bool get isAlive => hp > 0;

  @override
  FutureOr<void> onLoad() async {
    sprite = await getSpriteFromAsset(Assets.spritesTree);
    anchor = Anchor.center;
    add(CircleHitbox(radius: radius));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity;
    velocity *= 0.5;
    if (velocity.length < 1) {
      velocity = Vector2.zero();
    } else if (isOutOfScreen(game.size)) {
      game.removeTree(this);
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    final collisionVector = position - other.position;

    if (other is TreeComponent) {
      other.velocity += collisionVector * -0.1;
      velocity = collisionVector * 0.2;
    } else if (other is CityComponent) {
      velocity = collisionVector * 0.5;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.expandForest(position);
  }

  void doDamage(double damageValue) {
    hp -= damageValue;
    if (hp <= 0 && isMounted) {
      game.removeTree(this);
    }
  }
}
