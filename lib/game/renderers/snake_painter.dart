import 'dart:math';

import 'package:flutter/material.dart';

import '../entities/snake.dart';
import '../systems/render_culling.dart';

class SnakePainter {
  void drawSnake(
    Canvas canvas,
    Snake snake,
    Offset cameraOffset, {
    Size screenSize = Size.zero,
    double zoom = 1.0,
    bool isTeamMode = false,
    int playerTeamId = -1,
  }) {
    if (!snake.isAlive) return;

    final viewport = RenderCulling.viewportWorldSize(screenSize, zoom);
    final bodyMargin = snake.head.radius + snake.segments.length * Snake.segmentSpacing + 80;

    if (screenSize != Size.zero &&
        !RenderCulling.isVisible(
          position: snake.head.position,
          cameraOffset: cameraOffset,
          screenSize: viewport,
          margin: bodyMargin,
        )) {
      return;
    }

    final bodyPaint = Paint()
      ..color = snake.skinColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = snake.segments.length - 1; i >= 0; i--) {
      final segment = snake.segments[i];
      if (screenSize != Size.zero &&
          !RenderCulling.isVisible(
            position: segment.position,
            cameraOffset: cameraOffset,
            screenSize: viewport,
            margin: segment.radius + 20,
          )) {
        continue;
      }

      Offset drawPos = segment.position - cameraOffset;
      double radius = segment.radius * (1.0 - (i * 0.002));

      bodyPaint.color = snake.colorAt(i);
      canvas.drawCircle(drawPos, radius, bodyPaint);
      canvas.drawCircle(drawPos, radius, borderPaint);
    }

    Offset headDrawPos = snake.head.position - cameraOffset;
    double headRadius = snake.head.radius;

    bodyPaint.color = snake.skinColor;
    canvas.drawCircle(headDrawPos, headRadius, bodyPaint);
    canvas.drawCircle(headDrawPos, headRadius, borderPaint);

    double angle = snake.head.angle;
    double eyeDistance = headRadius * 0.55;
    double eyeRadius = headRadius * 0.35;
    double pupilRadius = eyeRadius * 0.45;

    Offset leftEyePos = headDrawPos + Offset(cos(angle - 0.5) * eyeDistance, sin(angle - 0.5) * eyeDistance);
    Offset rightEyePos = headDrawPos + Offset(cos(angle + 0.5) * eyeDistance, sin(angle + 0.5) * eyeDistance);

    final eyeWhite = Paint()..color = Colors.white;
    canvas.drawCircle(leftEyePos, eyeRadius, eyeWhite);
    canvas.drawCircle(rightEyePos, eyeRadius, eyeWhite);

    final eyeBorder = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(leftEyePos, eyeRadius, eyeBorder);
    canvas.drawCircle(rightEyePos, eyeRadius, eyeBorder);

    Offset pupilOffset = Offset(cos(angle) * (eyeRadius * 0.35), sin(angle) * (eyeRadius * 0.35));
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(leftEyePos + pupilOffset, pupilRadius, pupilPaint);
    canvas.drawCircle(rightEyePos + pupilOffset, pupilRadius, pupilPaint);

    final mouthPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Offset mouthPos = headDrawPos + Offset(cos(angle) * (headRadius * 0.65), sin(angle) * (headRadius * 0.65));
    canvas.drawCircle(mouthPos, headRadius * 0.22, mouthPaint);

    if (isTeamMode && snake.teamId == playerTeamId && snake.teamSlot > 0) {
      _drawTeamSlotBadge(canvas, headDrawPos, headRadius, snake.teamSlot);
    }

    if (snake.hasCrown) {
      _drawCrown(canvas, headDrawPos, headRadius, angle);
    }

    if (snake.isPlayer || snake.isRemoteHuman) {
      _drawNameTag(canvas, headDrawPos, headRadius, snake.name);
    }
  }

  void _drawNameTag(Canvas canvas, Offset headPos, double headRadius, String name) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          color: Colors.white,
          fontSize: (headRadius * 0.9).clamp(10, 16),
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 140);

    textPainter.paint(
      canvas,
      headPos - Offset(textPainter.width / 2, headRadius * 2.2),
    );
  }

  void _drawTeamSlotBadge(Canvas canvas, Offset headPos, double headRadius, int slot) {
    final badgeCenter = headPos - Offset(0, headRadius * 1.35);
    canvas.drawCircle(
      badgeCenter,
      headRadius * 0.42,
      Paint()..color = Colors.black.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      badgeCenter,
      headRadius * 0.42,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$slot',
        style: TextStyle(
          color: Colors.white,
          fontSize: headRadius * 0.55,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      badgeCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawCrown(Canvas canvas, Offset headPos, double headRadius, double angle) {
    final crownPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    Offset crownCenter = headPos - Offset(0, headRadius * 1.4);
    Path crownPath = Path();
    crownPath.moveTo(crownCenter.dx - 12, crownCenter.dy + 8);
    crownPath.lineTo(crownCenter.dx - 16, crownCenter.dy - 8);
    crownPath.lineTo(crownCenter.dx - 6, crownCenter.dy - 2);
    crownPath.lineTo(crownCenter.dx, crownCenter.dy - 12);
    crownPath.lineTo(crownCenter.dx + 6, crownCenter.dy - 2);
    crownPath.lineTo(crownCenter.dx + 16, crownCenter.dy - 8);
    crownPath.lineTo(crownCenter.dx + 12, crownCenter.dy + 8);
    crownPath.close();

    canvas.drawPath(crownPath, crownPaint);
  }
}
