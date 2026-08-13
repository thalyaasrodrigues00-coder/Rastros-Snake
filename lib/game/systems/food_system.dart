import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/game_constants.dart';
import '../entities/boundary.dart';
import '../entities/food.dart';
import '../entities/snake.dart';

class FoodSystem {
  final Boundary boundary;
  final Random _random = Random();

  FoodSystem({required this.boundary});

  void updateFoodInteractions(List<Snake> snakes, List<Food> foodPool, double dt) {
    for (final snake in snakes) {
      if (!snake.isAlive) continue;

      for (final food in foodPool) {
        if (!food.isActive) continue;

        final distance = (snake.head.position - food.position).distance;
        final maxInteractionRange =
            GameConstants.foodMagnetRadius + snake.head.radius + food.radius;
        if (distance > maxInteractionRange) continue;

        // 1. Atração Magnética (Ímã)
        if (distance < GameConstants.foodMagnetRadius) {
          food.isBeingEaten = true;
          final dir = snake.head.position - food.position;
          food.position += (dir / distance) * 350.0 * dt;
        }

        // 2. Absorção, crescimento e respawn instantâneo
        if (distance < (snake.head.radius + food.radius)) {
          snake.grow(food.value);
          respawnFood(food);
        }
      }
    }

    // Garante que esferas inativas sejam recriadas imediatamente
    for (final food in foodPool) {
      if (!food.isActive) {
        respawnFood(food);
      }
    }
  }

  void initializeFoodPool(List<Food> foodPool) {
    for (final food in foodPool) {
      respawnFood(food);
    }
  }

  void respawnFood(Food food) {
    food.reset(
      newPosition: _randomValidPosition(),
      newColor: AppColors.foodColors[_random.nextInt(AppColors.foodColors.length)],
      newValue: 1.0,
      newRadius: 6.0,
    );
  }

  Offset _randomValidPosition() {
    const margin = 40.0;
    return Offset(
      margin + _random.nextDouble() * (boundary.width - margin * 2),
      margin + _random.nextDouble() * (boundary.height - margin * 2),
    );
  }
}
