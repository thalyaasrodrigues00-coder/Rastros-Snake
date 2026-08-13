import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/constants/game_constants.dart';

class GameRenderer {
  final math.Random _random = math.Random(42);
  late List<Offset> _starsOutsideMap;

  GameRenderer() {
    _starsOutsideMap = List.generate(400, (index) {
      return Offset(
        _random.nextDouble() * (GameConstants.worldWidth + 4000) - 2000,
        _random.nextDouble() * (GameConstants.worldHeight + 4000) - 2000,
      );
    });
  }

  void renderDeepSpace(Canvas canvas, Size viewportSize, Offset cameraOffset) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, viewportSize.width, viewportSize.height),
      Paint()..color = const Color(0xFF05050A),
    );

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    for (final star in _starsOutsideMap) {
      final screenPos = star - cameraOffset;
      if (screenPos.dx >= 0 &&
          screenPos.dx <= viewportSize.width &&
          screenPos.dy >= 0 &&
          screenPos.dy <= viewportSize.height) {
        canvas.drawCircle(screenPos, 1.5, starPaint);
      }
    }
  }

  void renderArena(Canvas canvas, Offset cameraOffset) {
    final arenaRect = Rect.fromLTWH(
      -cameraOffset.dx,
      -cameraOffset.dy,
      GameConstants.worldWidth,
      GameConstants.worldHeight,
    );

    canvas.drawRect(arenaRect, Paint()..color = const Color(0xFF0F172A));

    final borderPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    canvas.drawRect(arenaRect, borderPaint);
  }

  void renderBackground(Canvas canvas, Size viewportSize, Offset cameraOffset) {
    renderDeepSpace(canvas, viewportSize, cameraOffset);
    renderArena(canvas, cameraOffset);
  }
}
