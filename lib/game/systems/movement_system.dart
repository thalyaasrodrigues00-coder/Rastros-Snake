import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/constants/game_constants.dart';
import '../entities/boundary.dart';
import '../entities/snake.dart';

class MovementSystem {
  final Boundary boundary;

  MovementSystem({required this.boundary});

  void updateSnake(Snake snake, double targetAngle, double dt) {
    if (!snake.isAlive) return;

    // 1. Cálculo de Velocidade e Consumo de Boost
    double speed = GameConstants.baseSpeed;
    if (snake.isBoosting && snake.score > 5.0) {
      speed *= GameConstants.boostSpeedMultiplier;
      snake.shrink(dt * 2.0); // Custo do Boost em massa
    }

    // 2. Atualiza Posição da Cabeça
    double currentAngle = snake.head.angle;
    double newX = snake.head.position.dx + cos(currentAngle) * speed * dt;
    double newY = snake.head.position.dy + sin(currentAngle) * speed * dt;

    // Garante deslize na borda do mapa
    Offset newPosition = boundary.clampPosition(Offset(newX, newY), snake.head.radius);
    snake.head.updatePosition(newPosition, targetAngle, dt, GameConstants.rotationSpeed);

    // 3. Atualiza o Rastro da Cauda
    snake.updateTail();
  }
}
