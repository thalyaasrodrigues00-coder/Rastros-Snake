import 'package:flutter/material.dart';

import '../entities/boundary.dart';
import '../entities/food.dart';
import '../entities/snake.dart';
import '../entities/tunnel.dart';
import 'food_painter.dart';
import 'game_renderer.dart';
import 'snake_painter.dart';
import 'tunnel_painter.dart';

class WorldPainter extends CustomPainter {
  final Boundary boundary;
  final List<Snake> snakes;
  final List<Food> foodPool;
  final List<Tunnel> tunnels;
  final Offset cameraOffset;
  final double zoom;
  final double dt;
  final bool isTeamMode;
  final int playerTeamId;

  static final SnakePainter _snakePainter = SnakePainter();
  static final FoodPainter _foodPainter = FoodPainter();
  static final TunnelPainter _tunnelPainter = TunnelPainter();
  static final GameRenderer _gameRenderer = GameRenderer();

  WorldPainter({
    required this.boundary,
    required this.snakes,
    required this.foodPool,
    required this.tunnels,
    required this.cameraOffset,
    required this.zoom,
    this.dt = 0.016,
    this.isTeamMode = false,
    this.playerTeamId = -1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _gameRenderer.renderDeepSpace(canvas, size, cameraOffset);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(zoom);
    canvas.translate(-size.width / 2, -size.height / 2);

    _gameRenderer.renderArena(canvas, cameraOffset);

    _tunnelPainter.drawTunnels(
      canvas,
      tunnels,
      cameraOffset,
      dt,
      screenSize: size,
      zoom: zoom,
    );
    _foodPainter.drawFood(canvas, foodPool, cameraOffset, size, zoom: zoom);

    for (final snake in snakes) {
      _snakePainter.drawSnake(
        canvas,
        snake,
        cameraOffset,
        screenSize: size,
        zoom: zoom,
        isTeamMode: isTeamMode,
        playerTeamId: playerTeamId,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return oldDelegate.cameraOffset != cameraOffset ||
        oldDelegate.zoom != zoom ||
        oldDelegate.snakes != snakes ||
        oldDelegate.foodPool != foodPool;
  }
}
