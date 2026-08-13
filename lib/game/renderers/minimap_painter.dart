import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../entities/boundary.dart';
import '../entities/food.dart';
import '../entities/snake.dart';
import '../entities/tunnel.dart';
import '../widgets/hud_layout.dart';

class MinimapPainter extends CustomPainter {
  final double worldWidth;
  final double worldHeight;
  final List<Snake> snakes;
  final List<Snake> teamMembers;
  final Snake player;
  final List<Food> foodPool;
  final List<Tunnel> tunnels;
  final Offset? deathMarker;
  final bool isTeamMode;
  final int playerTeamId;
  final bool drawAllEntities;

  MinimapPainter({
    required this.worldWidth,
    required this.worldHeight,
    required this.snakes,
    required this.teamMembers,
    required this.player,
    required this.foodPool,
    required this.tunnels,
    this.deathMarker,
    this.isTeamMode = false,
    this.playerTeamId = -1,
    this.drawAllEntities = true,
  });

  Offset _toMap(Offset world, double scaleX, double scaleY) {
    return Offset(world.dx * scaleX, world.dy * scaleY);
  }

  Color _teamColor(int teamId) {
    return Color(HudLayout.teamColors[teamId.clamp(0, 9) % HudLayout.teamColors.length]);
  }

  void _drawMapSlotLabel(Canvas canvas, Offset mapPos, int slot) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$slot',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 6,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      mapPos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / worldWidth;
    final scaleY = size.height / worldHeight;

    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final borderPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    if (drawAllEntities) {
      for (final food in foodPool) {
        if (!food.isActive) continue;
        final mapPos = _toMap(food.position, scaleX, scaleY);
        final isCrystal = food.value >= 3.0;
        final dotPaint = Paint()
          ..color = isCrystal
              ? const Color(0xFF00B0FF).withValues(alpha: 0.95)
              : const Color(0xFF39FF14).withValues(alpha: 0.85);
        canvas.drawCircle(mapPos, isCrystal ? 1.8 : 0.8, dotPaint);
      }

      final tunnelPaint = Paint()
        ..color = const Color(0xFFD500F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      final tunnelFill = Paint()..color = const Color(0xFFAA00FF).withValues(alpha: 0.6);
      for (final tunnel in tunnels) {
        final mapPos = _toMap(tunnel.position, scaleX, scaleY);
        canvas.drawCircle(mapPos, 3.5, tunnelFill);
        canvas.drawCircle(mapPos, 3.5, tunnelPaint);
      }
    }

    if (isTeamMode) {
      for (final snake in snakes) {
        if (!snake.isAlive) continue;
        final mapPos = _toMap(snake.head.position, scaleX, scaleY);
        final paint = Paint()..color = _teamColor(snake.teamId);
        canvas.drawCircle(mapPos, snake.isPlayer ? 3.5 : 2.5, paint);

        if (snake.teamId == playerTeamId && snake.teamSlot > 0) {
          _drawMapSlotLabel(canvas, mapPos, snake.teamSlot);
        }
      }
    } else {
      for (final snake in snakes) {
        if (!snake.isAlive) continue;
        final mapPos = _toMap(snake.head.position, scaleX, scaleY);
        final paint = Paint()
          ..color = snake.isPlayer
              ? Colors.cyanAccent
              : (snake.hasCrown ? Colors.orangeAccent : Colors.redAccent);
        canvas.drawCircle(mapPos, snake.isPlayer ? 3.5 : 2.0, paint);
      }
    }

    if (deathMarker != null) {
      final deathPos = _toMap(deathMarker!, scaleX, scaleY);
      canvas.drawCircle(deathPos, 3.0, Paint()..color = Colors.redAccent);
    }

    if (player.isAlive) {
      final playerPos = _toMap(player.head.position, scaleX, scaleY);
      final angle = player.head.angle;
      final dirEnd = playerPos + Offset(math.cos(angle) * 6, math.sin(angle) * 6);
      canvas.drawLine(
        playerPos,
        dirEnd,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.2,
      );
    }

    final viewportPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(
      Rect.fromCenter(
        center: _toMap(player.head.position, scaleX, scaleY),
        width: size.width * 0.2,
        height: size.height * 0.2,
      ),
      viewportPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MinimapPainter oldDelegate) {
    return oldDelegate.player.head.position != player.head.position ||
        oldDelegate.player.head.angle != player.head.angle ||
        oldDelegate.deathMarker != deathMarker ||
        oldDelegate.snakes.length != snakes.length ||
        oldDelegate.foodPool.length != foodPool.length ||
        oldDelegate.isTeamMode != isTeamMode;
  }
}

class MinimapWidget extends StatelessWidget {
  final Boundary boundary;
  final List<Snake> snakes;
  final List<Snake> teamMembers;
  final Snake player;
  final List<Food> foodPool;
  final List<Tunnel> tunnels;
  final Offset? deathMarker;
  final double size;
  final bool isTeamMode;
  final int playerTeamId;
  final bool drawAllEntities;

  const MinimapWidget({
    super.key,
    required this.boundary,
    required this.snakes,
    required this.teamMembers,
    required this.player,
    required this.foodPool,
    required this.tunnels,
    this.deathMarker,
    this.size = 140.0,
    this.isTeamMode = false,
    this.playerTeamId = -1,
    this.drawAllEntities = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CustomPaint(
          painter: MinimapPainter(
            worldWidth: boundary.width,
            worldHeight: boundary.height,
            snakes: snakes,
            teamMembers: teamMembers,
            player: player,
            foodPool: foodPool,
            tunnels: tunnels,
            deathMarker: deathMarker,
            isTeamMode: isTeamMode,
            playerTeamId: playerTeamId,
            drawAllEntities: drawAllEntities,
          ),
        ),
      ),
    );
  }
}
