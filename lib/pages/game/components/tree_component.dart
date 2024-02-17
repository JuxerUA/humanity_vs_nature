import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:humanity_vs_nature/generated/assets.dart';
import 'package:humanity_vs_nature/pages/game/models/spot.dart';
import 'package:humanity_vs_nature/pages/game/simulation_game.dart';
import 'package:humanity_vs_nature/utils/sprite_utils.dart';

class TreeComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<SimulationGame> {
  TreeComponent({bool isMature = false}) {
    if (isMature) {
      _phase = _TreePhase.mature;
    }
  }

  static const double radius = 10;

  _TreePhase _phase = _TreePhase.sapling;
  late double hp;
  late double needCO2toNextPhase;

  bool get isAlive => hp > 0;

  bool get isMature => _phase == _TreePhase.mature;

  bool get isSapling => _phase == _TreePhase.sapling;

  Spot get spot => Spot(position, radius);

  @override
  FutureOr<void> onLoad() async {
    await _updateTreeAccordingToCurrentPhase();
    add(CircleHitbox());
    anchor = Anchor.center;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // If the tree is still growing
    if (_phase != _TreePhase.mature) {
      if (needCO2toNextPhase > 0) {
        // Try to get some CO2
        final gasVolume = game.gasSystem.aTreeWantsSomeCO2(position, dt);
        needCO2toNextPhase -= gasVolume;
      } else {
        // Grow up to next phase
        if (_phase == _TreePhase.sapling) {
          _phase = _TreePhase.young;
        } else {
          _phase = _TreePhase.mature;
          final saplingCount = Random().nextInt(3);
          for (var i = 0; i < saplingCount; i++) {
            game.expandForest(position);
          }
        }
        _updateTreeAccordingToCurrentPhase();
      }
    }
  }

  Future<void> _updateTreeAccordingToCurrentPhase() async {
    hp = _phase.hp;
    needCO2toNextPhase = _phase.volumeCO2toNextPhase;
    sprite = await getSpriteFromAsset(_phase.spritePath);
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

enum _TreePhase {
  sapling(2, 10, Assets.spritesTreeSapling),
  young(15, 30, Assets.spritesTreeSmall),
  mature(30, 0, Assets.spritesTree);

  const _TreePhase(this.hp, this.volumeCO2toNextPhase, this.spritePath);

  final double hp;
  final double volumeCO2toNextPhase;
  final String spritePath;
}
