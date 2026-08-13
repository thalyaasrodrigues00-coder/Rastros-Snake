import 'dart:math';
import 'package:flutter/material.dart';

class TouchFollowController {
  Offset? touchPosition;
  bool isTouching = false;

  void onTouchStart(Offset position) {
    touchPosition = position;
    isTouching = true;
  }

  void onTouchUpdate(Offset position) {
    touchPosition = position;
  }

  void onTouchEnd() {
    isTouching = false;
    touchPosition = null;
  }

  // Calcula o ângulo em direção ao toque baseado na posição da cobra na tela
  double? getAngleToTouch(Offset snakeScreenPosition) {
    if (!isTouching || touchPosition == null) return null;

    Offset delta = touchPosition! - snakeScreenPosition;
    if (delta.distance < 10.0) return null; // Zona morta para evitar giros bruscos

    return atan2(delta.dy, delta.dx);
  }
}
