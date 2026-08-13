import 'package:flutter/material.dart';

import '../entities/food.dart';
import '../systems/render_culling.dart';

class FoodPainter {
  void drawFood(
    Canvas canvas,
    List<Food> foods,
    Offset cameraOffset,
    Size screenSize, {
    double zoom = 1.0,
  }) {
    final viewport = RenderCulling.viewportWorldSize(screenSize, zoom);

    for (final food in foods) {
      if (!food.isActive) continue;

      if (!RenderCulling.isVisible(
        position: food.position,
        cameraOffset: cameraOffset,
        screenSize: viewport,
        margin: food.radius + 40,
      )) {
        continue;
      }

      Offset drawPos = food.position - cameraOffset;

      final glowPaint = Paint()
        ..color = food.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(drawPos, food.radius * 1.5, glowPaint);

      final foodPaint = Paint()
        ..color = food.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(drawPos, food.radius, foodPaint);
    }
  }
}
