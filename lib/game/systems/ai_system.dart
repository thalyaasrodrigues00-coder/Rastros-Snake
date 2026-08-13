import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/constants/game_constants.dart';
import '../entities/boundary.dart';
import '../entities/food.dart';
import '../entities/snake.dart';

class AISystem {
  final Boundary boundary;
  final Random _random = Random();
  final Map<int, double> _wanderBias = {};

  AISystem({required this.boundary});

  void updateBots(
    List<Snake> snakes,
    List<Food> foodPool,
    double dt, {
    bool isTeamMode = false,
  }) {
    for (final snake in snakes) {
      if (!snake.isAlive || !snake.isBot) continue;

      final currentAngle = snake.head.angle;
      double targetAngle = currentAngle;

      if (_isNearBoundary(snake.head.position)) {
        targetAngle = _calculateAvoidanceAngleFromCenter(snake.head.position);
        snake.isBoosting = _random.nextDouble() < 0.15;
      } else {
        final dangerPosition = _findNearestObstacle(snake, snakes, isTeamMode: isTeamMode);

        if (dangerPosition != null) {
          final angleToDanger = atan2(
            dangerPosition.dy - snake.head.position.dy,
            dangerPosition.dx - snake.head.position.dx,
          );
          final evadeLeft = angleToDanger + pi / 2;
          final evadeRight = angleToDanger - pi / 2;
          final leftDiff = _angleDiff(evadeLeft, currentAngle).abs();
          final rightDiff = _angleDiff(evadeRight, currentAngle).abs();
          targetAngle = leftDiff <= rightDiff ? evadeLeft : evadeRight;
          snake.isBoosting = _random.nextDouble() < 0.35;
        } else {
          final nearestFood = _findNearestFood(snake.head.position, foodPool);

          if (nearestFood != null) {
            targetAngle = atan2(
              nearestFood.position.dy - snake.head.position.dy,
              nearestFood.position.dx - snake.head.position.dx,
            );
            snake.isBoosting = false;
          } else if (isTeamMode) {
            targetAngle = _teamWanderAngle(snake, snakes, currentAngle);
            snake.isBoosting = false;
          } else {
            targetAngle = _soloWanderAngle(snake.id, currentAngle);
            snake.isBoosting = false;
          }
        }
      }

      targetAngle = _constrainToForwardArc(currentAngle, targetAngle);
      snake.head.angle = targetAngle;

      _wanderBias[snake.id] = (_wanderBias[snake.id] ?? 0) + dt;
    }
  }

  double _soloWanderAngle(int snakeId, double currentAngle) {
    final tick = _wanderBias[snakeId] ?? 0;
    if (_random.nextDouble() < 0.08 || (tick % 2.5) < 0.05) {
      return currentAngle + (_random.nextDouble() - 0.5) * pi / 2;
    }
    return currentAngle + sin(tick * 2.2 + snakeId) * 0.25;
  }

  double _teamWanderAngle(Snake snake, List<Snake> snakes, double currentAngle) {
    final tick = _wanderBias[snake.id] ?? 0;
    Offset? enemyCenter;

    for (final other in snakes) {
      if (!other.isAlive || other.id == snake.id) continue;
      if (other.teamId == snake.teamId) continue;
      enemyCenter = enemyCenter == null
          ? other.head.position
          : Offset(
              (enemyCenter.dx + other.head.position.dx) / 2,
              (enemyCenter.dy + other.head.position.dy) / 2,
            );
    }

    if (enemyCenter != null) {
      final awayFromEnemies = atan2(
        snake.head.position.dy - enemyCenter.dy,
        snake.head.position.dx - enemyCenter.dx,
      );
      return _constrainToForwardArc(
        currentAngle,
        awayFromEnemies + sin(tick + snake.id) * 0.35,
      );
    }

    return currentAngle + sin(tick * 1.8 + snake.id) * 0.3;
  }

  double _constrainToForwardArc(double currentAngle, double targetAngle) {
    final diff = _angleDiff(targetAngle, currentAngle).clamp(-pi / 2, pi / 2);
    return currentAngle + diff;
  }

  double _angleDiff(double a, double b) {
    var diff = a - b;
    while (diff > pi) {
      diff -= 2 * pi;
    }
    while (diff < -pi) {
      diff += 2 * pi;
    }
    return diff;
  }

  bool _isNearBoundary(Offset position) {
    const margin = 100.0;
    return position.dx < margin ||
        position.dx > boundary.width - margin ||
        position.dy < margin ||
        position.dy > boundary.height - margin;
  }

  double _calculateAvoidanceAngleFromCenter(Offset position) {
    final center = Offset(boundary.width / 2, boundary.height / 2);
    return atan2(center.dy - position.dy, center.dx - position.dx);
  }

  Offset? _findNearestObstacle(
    Snake currentSnake,
    List<Snake> allSnakes, {
    required bool isTeamMode,
  }) {
    const scanRadius = 150.0;
    Offset? nearestSegmentPos;
    var minDistance = scanRadius;

    for (final other in allSnakes) {
      if (!other.isAlive || other.id == currentSnake.id) continue;
      if (isTeamMode && other.teamId >= 0 && other.teamId == currentSnake.teamId) {
        continue;
      }

      for (final segment in other.segments) {
        final dist = (currentSnake.head.position - segment.position).distance;
        if (dist < minDistance) {
          minDistance = dist;
          nearestSegmentPos = segment.position;
        }
      }

      final headDist = (currentSnake.head.position - other.head.position).distance;
      if (headDist < minDistance) {
        minDistance = headDist;
        nearestSegmentPos = other.head.position;
      }
    }

    return nearestSegmentPos;
  }

  Food? _findNearestFood(Offset headPosition, List<Food> foodPool) {
    const scanRadius = 300.0;
    Food? closestFood;
    var minDistance = scanRadius;

    for (final food in foodPool) {
      if (!food.isActive) continue;

      final dist = (headPosition - food.position).distance;
      if (dist < minDistance) {
        minDistance = dist;
        closestFood = food;
      }
    }

    return closestFood;
  }
}
