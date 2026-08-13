import 'package:flutter/material.dart';
import '../../app/constants/game_constants.dart';
import '../entities/snake.dart';
import '../entities/tunnel.dart';

class TunnelSystem {
  final List<Tunnel> tunnels;

  TunnelSystem({required this.tunnels});

  void update(List<Snake> snakes, double dt) {
    // Atualiza tempos de recarga dos portais
    for (final tunnel in tunnels) {
      tunnel.updateCooldowns(dt);
    }

    // Processa passagem das cobras nos túneis
    for (final snake in snakes) {
      if (!snake.isAlive) continue;

      for (final tunnel in tunnels) {
        if (!tunnel.canTeleport(snake.id)) continue;

        double distance = (snake.head.position - tunnel.position).distance;
        if (distance < tunnel.radius * 0.8) {
          _teleportSnake(snake, tunnel);
          break;
        }
      }
    }
  }

  void _teleportSnake(Snake snake, Tunnel entryTunnel) {
    // Encontra o túnel de saída correspondente
    final exitTunnel = tunnels.firstWhere(
      (t) => t.id == entryTunnel.targetTunnelId,
      orElse: () => entryTunnel,
    );

    if (exitTunnel.id == entryTunnel.id) return;

    // Teletransporta a cabeça colocando-a levemente à frente na direção de saída
    Offset exitPosition = exitTunnel.position + (exitTunnel.exitDirection * (exitTunnel.radius + 20.0));
    snake.head.position = exitPosition;

    // Aplica o tempo de recarga nos dois túneis para essa cobra
    entryTunnel.triggerCooldown(snake.id, GameConstants.tunnelCooldownSeconds);
    exitTunnel.triggerCooldown(snake.id, GameConstants.tunnelCooldownSeconds);
  }
}
