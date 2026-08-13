import 'package:flutter/material.dart';

import '../entities/boundary.dart';
import '../entities/food.dart';
import '../entities/snake.dart';
import '../entities/tunnel.dart';
import '../renderers/minimap_painter.dart';
import 'hud_layout.dart';

class GameMapPanelWidget extends StatelessWidget {
  final Boundary boundary;
  final List<Snake> snakes;
  final List<Snake> teamMembers;
  final Snake player;
  final List<Food> foodPool;
  final List<Tunnel> tunnels;
  final Offset? deathMarker;
  final bool isTeamMode;
  final int playerTeamId;
  final int? teamScoreOverlay;

  const GameMapPanelWidget({
    super.key,
    required this.boundary,
    required this.snakes,
    required this.teamMembers,
    required this.player,
    required this.foodPool,
    required this.tunnels,
    this.deathMarker,
    required this.isTeamMode,
    this.playerTeamId = -1,
    this.teamScoreOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: HudLayout.edgePadding,
      left: HudLayout.edgePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              MinimapWidget(
                boundary: boundary,
                snakes: snakes,
                teamMembers: teamMembers,
                player: player,
                foodPool: foodPool,
                tunnels: tunnels,
                deathMarker: deathMarker,
                size: HudLayout.mapSize,
                isTeamMode: isTeamMode,
                playerTeamId: playerTeamId,
                drawAllEntities: true,
              ),
              if (isTeamMode && teamScoreOverlay != null)
                Positioned(
                  left: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Equipe: $teamScoreOverlay',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
