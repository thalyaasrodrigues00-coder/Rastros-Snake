import 'dart:math';
import 'package:flutter/material.dart';

class JoystickController {
  Offset? basePosition;
  Offset? currentPosition;
  bool isDragging = false;
  double maxRadius = 60.0;

  void onPanStart(Offset position, bool isDynamic) {
    if (isDynamic) {
      basePosition = position;
    }
    currentPosition = position;
    isDragging = true;
  }

  void onPanUpdate(Offset position) {
    if (!isDragging) return;
    currentPosition = position;
  }

  void onPanEnd() {
    isDragging = false;
    currentPosition = null;
    basePosition = null;
  }

  // Retorna a direção normalizada (de -1.0 a 1.0 em X e Y)
  Offset getDirection(Offset fixedCenter) {
    Offset center = basePosition ?? fixedCenter;
    if (!isDragging || currentPosition == null) {
      return Offset.zero;
    }

    Offset delta = currentPosition! - center;
    double distance = delta.distance;

    if (distance == 0) return Offset.zero;

    double clampedDistance = min(distance, maxRadius);
    return Offset((delta.dx / distance) * (clampedDistance / maxRadius), (delta.dy / distance) * (clampedDistance / maxRadius));
  }

  // Retorna o ângulo de rotação em radianos
  double? getAngle(Offset fixedCenter) {
    Offset dir = getDirection(fixedCenter);
    if (dir == Offset.zero) return null;
    return atan2(dir.dy, dir.dx);
  }
}
