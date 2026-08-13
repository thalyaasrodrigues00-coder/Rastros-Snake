import 'package:flutter/material.dart';

import 'hud_layout.dart';

class ArenaAliveCounterWidget extends StatelessWidget {
  final int aliveCount;
  final int totalCount;
  final bool isTeamMode;
  final int? aliveTeamsCount;

  const ArenaAliveCounterWidget({
    super.key,
    required this.aliveCount,
    required this.totalCount,
    required this.isTeamMode,
    this.aliveTeamsCount,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isTeamMode ? const Color(0xFFFFD700) : const Color(0xFF00E5FF);

    return Positioned(
      top: HudLayout.edgePadding,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups, color: accent, size: 14),
              const SizedBox(width: 6),
              Text(
                'NA ARENA: ',
                style: TextStyle(
                  color: accent.withValues(alpha: 0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '$aliveCount',
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                ' / $totalCount',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isTeamMode && aliveTeamsCount != null) ...[
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 14,
                  color: Colors.white24,
                ),
                const SizedBox(width: 10),
                Text(
                  'EQUIPES: $aliveTeamsCount',
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.9),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
