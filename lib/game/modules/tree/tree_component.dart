import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/math.dart';
import 'package:humanity_vs_nature/game/mixins/blink_mixin.dart';
import 'package:humanity_vs_nature/game/models/spot.dart';
import 'package:humanity_vs_nature/game/simulation_game.dart';
import 'package:humanity_vs_nature/generated/assets.dart';

class TreeComponent extends SpriteComponent
    with TapCallbacks, HasGameRef<SimulationGame>, BlinkEffect {
  TreeComponent({bool isMature = false}) {
    if (isMature) {
      _phase = _TreePhase.mature;
    }
  }

  static const double radius = 10;

  _TreePhase _phase = _TreePhase.cone;
  late double hp;
  late double needCO2toNextPhase;

  bool get isAlive => hp > 0;

  bool get isMature => _phase == _TreePhase.mature;

  bool get isCone => _phase == _TreePhase.cone;

  bool get isYoung => _phase == _TreePhase.young;

  Spot get spot => Spot(position, radius);

  @override
  FutureOr<void> onLoad() async {
    await _updateTreeAccordingToCurrentPhase();
    add(CircleHitbox());
    anchor = Anchor.bottomCenter;
    // size = game.matureTreeSprite.originalSize * 0.5;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateShake();

    // If the tree is still growing
    if (_phase != _TreePhase.mature) {
      if (needCO2toNextPhase > 0) {
        // Try to get some CO2
        final gasVolume = game.gasModule.aTreeWantsSomeCO2(position, dt);
        needCO2toNextPhase -= gasVolume;
      } else {
        // Grow up to next phase
        if (_phase == _TreePhase.cone) {
          _phase = _TreePhase.young;
        } else {
          _phase = _TreePhase.mature;
          final saplingCount = randomFallback.nextInt(3);
          for (var i = 0; i < saplingCount; i++) {
            game.treeModule.expandForest(position);
          }
        }
        _updateTreeAccordingToCurrentPhase();
      }
    }
  }

  Future<void> _updateTreeAccordingToCurrentPhase() async {
    hp = _phase.hp;
    needCO2toNextPhase = _phase.volumeCO2toNextPhase;
    switch (_phase) {
      case _TreePhase.cone:
        sprite = game.spriteCone;
        size = game.spriteCone.originalSize * 0.2;
      case _TreePhase.young:
        sprite = game.spriteYoungTree;
        size = game.spriteYoungTree.originalSize * 0.5;
      case _TreePhase.mature:
        sprite = game.spriteMatureTree;
        size = game.spriteMatureTree.originalSize * 0.5;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.treeModule.expandForest(position);
  }

  bool doDamage(double damageValue) {
    hp -= damageValue;
    if (hp <= 0 && isMounted) {
      game.treeModule.removeTree(this);
      return true;
    }
    return false;
  }

  void shakeTheTree() {
    scale = Vector2(1.3, 1);
  }

  void _updateShake() {
    var sc = scale.x;
    if (sc > 1) {
      sc *= 0.99;
      if (sc < 1) {
        sc = 1;
      }
      scale = Vector2(sc, 1);
    }
  }
}

enum _TreePhase {
  cone(1, 10, Assets.spritesCone),
  young(15, 30, Assets.spritesYoungTree),
  mature(10, 0, Assets.spritesMatureTree);

  const _TreePhase(this.hp, this.volumeCO2toNextPhase, this.spritePath);

  final double hp;
  final double volumeCO2toNextPhase;
  final String spritePath;
}
