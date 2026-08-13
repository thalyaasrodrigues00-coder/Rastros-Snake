import 'dart:math';
import 'package:flutter/material.dart';

class SnakeHead {
  Offset position;
  double angle; // Radianos
  double radius;

  SnakeHead({
    required this.position,
    this.angle = 0.0,
    required this.radius,
  });

  // Atualiza a posição e ajusta suavemente a rotação da cabeça
  void updatePosition(Offset newPosition, double targetAngle, double dt, double rotationSpeed) {
    position = newPosition;

    // Interpolação do ângulo para rotação suave
    double diff = (targetAngle - angle) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;

    angle += diff * min(1.0, dt * rotationSpeed);
  }
}
