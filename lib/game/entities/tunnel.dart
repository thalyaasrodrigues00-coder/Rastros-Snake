import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';

class Tunnel {
  final int id;
  final int targetTunnelId;
  final Offset position;
  final Offset exitDirection; // Vetor para apontar a saída da cobra
  final double radius;
  final Color color;

  // Controle de tempo de recarga individual por ID de cobra
  final Map<int, double> _cooldowns = {};

  Tunnel({
    required this.id,
    required this.targetTunnelId,
    required this.position,
    required this.exitDirection,
    this.radius = 45.0,
    this.color = AppColors.tunnelPortal,
  });

  bool canTeleport(int snakeId) {
    return !(_cooldowns.containsKey(snakeId) && _cooldowns[snakeId]! > 0);
  }

  void triggerCooldown(int snakeId, double durationSeconds) {
    _cooldowns[snakeId] = durationSeconds;
  }

  void updateCooldowns(double dt) {
    _cooldowns.forEach((snakeId, time) {
      if (time > 0) {
        _cooldowns[snakeId] = time - dt;
      }
    });
    _cooldowns.removeWhere((key, value) => value <= 0);
  }
}
