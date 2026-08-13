import 'dart:math';

import 'package:flutter/material.dart';

import '../entities/tunnel.dart';
import '../systems/render_culling.dart';

class TunnelPainter {
  double _animationAngle = 0.0;

  void drawTunnels(
    Canvas canvas,
    List<Tunnel> tunnels,
    Offset cameraOffset,
    double dt, {
    Size screenSize = Size.zero,
    double zoom = 1.0,
  }) {
    _animationAngle += dt * 2.0;
    final viewport = RenderCulling.viewportWorldSize(screenSize, zoom);

    for (final tunnel in tunnels) {
      if (screenSize != Size.zero &&
          !RenderCulling.isVisible(
            position: tunnel.position,
            cameraOffset: cameraOffset,
            screenSize: viewport,
            margin: tunnel.radius + 60,
          )) {
        continue;
      }

      Offset drawPos = tunnel.position - cameraOffset;

      final outerRing = Paint()
        ..color = tunnel.color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0;
      canvas.drawCircle(drawPos, tunnel.radius, outerRing);

      final innerRing = Paint()
        ..color = tunnel.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

      canvas.save();
      canvas.translate(drawPos.dx, drawPos.dy);
      canvas.rotate(_animationAngle);

      for (int i = 0; i < 4; i++) {
        double currentAngle = (i * pi / 2);
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: tunnel.radius * 0.7),
          currentAngle,
          pi / 4,
          false,
          innerRing,
        );
      }
      canvas.restore();

      final corePaint = Paint()..color = Colors.black87;
      canvas.drawCircle(drawPos, tunnel.radius * 0.5, corePaint);
    }
  }
}
