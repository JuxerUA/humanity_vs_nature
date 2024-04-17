import 'package:flame/components.dart';
import 'package:flutter/material.dart';

mixin BlinkEffect on HasPaint {
  final double _blinkDuration = 0.5;
  bool _isBlinking = false;
  double _blinkTimer = 0;

  void startBlinking() {
    _blinkTimer = 0;
    _isBlinking = true;
  }

  void stopBlinking() {
    _isBlinking = false;
    tint(Colors.transparent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isBlinking) {
      _blinkTimer += dt;
      final value = _blinkTimer % (_blinkDuration * 2);
      final opacity =
          value < _blinkDuration ? value : _blinkDuration * 2 - value;
      tint(Colors.white.withOpacity(opacity));
    }
  }
}
