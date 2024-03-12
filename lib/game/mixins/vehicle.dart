import 'dart:math';

import 'package:flame/components.dart';

mixin Vehicle on SpriteComponent {
  static const maxSpeed = 50.0;
  static const rotationSpeed = 2.0;

  double currentSpeed = 0;
  VehicleState state = VehicleState.stop;

  void goToPosition(Vector2 targetPosition, double minDistanceToTarget, double dt) {
    final distance = position.distanceTo(targetPosition);
    final direction = Vector2(cos(angle), sin(angle));
    final directionToTarget = targetPosition - position;

    // Determinate state
    if (distance < minDistanceToTarget) {
      state = VehicleState.stop;
    } else {
      if (direction.angleTo(directionToTarget).abs() > 0.15) {
        state = VehicleState.rotation;
      } else {
        state = VehicleState.accelerate;
      }
    }

    final deltaSpeed = state.targetSpeed - currentSpeed;
    currentSpeed += deltaSpeed * dt * 0.8;

    if (state == VehicleState.rotation) {
      final angleToTarget = atan2(directionToTarget.y, directionToTarget.x);
      final crossProduct = sin(angleToTarget - angle);
      final maxRotation = rotationSpeed * dt;
      final rotation = maxRotation * crossProduct.sign;
      angle += rotation;
    }

    final newDirection = Vector2(cos(angle), sin(angle));
    position += newDirection * currentSpeed * dt;
  }
}

enum VehicleState {
  accelerate(Vehicle.maxSpeed),
  rotation(Vehicle.maxSpeed / 5),
  stop(0);

  const VehicleState(this.targetSpeed);

  final double targetSpeed;
}
