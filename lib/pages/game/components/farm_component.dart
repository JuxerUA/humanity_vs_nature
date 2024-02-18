import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/pages/game/components/city_component.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class FarmComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<SimulationGame> {
  FarmComponent({required this.owner});

  static const double radius = 25;
  static const double requiredSpotRadius = 100;

  int hp = 20;

  final CityComponent owner;

  Spot get spot => Spot(position, radius);

  @override
  FutureOr<void> onLoad() async {
    sprite = await getSpriteFromAsset(Assets.spritesFarm);
    anchor = Anchor.bottomCenter;
    size *= 0.7;
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    hp -= 1;
    if (hp < 1) {
      game.removeFarm(this);
    }
  }
}
