import 'package:flutter/material.dart';

import '../entities/snake.dart';
import 'hud_layout.dart';

class SoloScoreboardWidget extends StatelessWidget {
  final List<Snake> leaderboard;

  const SoloScoreboardWidget({super.key, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    final top10 = leaderboard.take(10).toList();

    return Positioned(
      top: HudLayout.edgePadding,
      right: HudLayout.edgePadding,
      child: Container(
        width: HudLayout.scoreboardWidth,
        height: HudLayout.scoreboardHeight,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOP 10',
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const Divider(color: Colors.white24, height: 8),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: top10.length,
                itemBuilder: (context, index) {
                  final snake = top10[index];
                  final isDead = !snake.isAlive;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            color: snake.isPlayer ? Colors.cyanAccent : Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            decoration: isDead ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            snake.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDead
                                  ? Colors.white38
                                  : (snake.isPlayer ? Colors.cyanAccent : Colors.white),
                              fontSize: 10,
                              fontWeight: snake.isPlayer ? FontWeight.bold : FontWeight.normal,
                              decoration: isDead ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Text(
                          '${snake.score.toInt()}',
                          style: TextStyle(
                            color: isDead ? Colors.white38 : Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            decoration: isDead ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamScoreboardWidget extends StatelessWidget {
  final List<Snake> teamMembers;
  final int playerTeamId;

  const TeamScoreboardWidget({
    super.key,
    required this.teamMembers,
    required this.playerTeamId,
  });

  @override
  Widget build(BuildContext context) {
    final teamColor = Color(
      HudLayout.teamColors[playerTeamId.clamp(0, 9) % HudLayout.teamColors.length],
    );
    final teamLabel = String.fromCharCode(65 + playerTeamId.clamp(0, 25));
    final members = [...teamMembers]..sort((a, b) => a.teamSlot.compareTo(b.teamSlot));
    final teamTotalScore = members.fold<int>(0, (sum, s) => sum + s.score.toInt());
    final teamTotalEliminations = members.fold<int>(0, (sum, s) => sum + s.eliminationCount);

    return Positioned(
      top: HudLayout.edgePadding,
      right: HudLayout.edgePadding,
      child: Container(
        width: HudLayout.teamScoreboardWidth,
        height: HudLayout.teamScoreboardHeight,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: teamColor.withValues(alpha: 0.85), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: teamColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'EQ. $teamLabel',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: teamColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Pts: $teamTotalScore · Elim: $teamTotalEliminations',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 7.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24, height: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nome',
                      style: TextStyle(color: Colors.white38, fontSize: 6.5),
                    ),
                  ),
                  const SizedBox(
                    width: 18,
                    child: Text(
                      'Pts',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white38, fontSize: 6.5),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                    child: Text(
                      'K',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white38, fontSize: 6.5),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final snake = members[index];
                  final slot = snake.teamSlot > 0 ? snake.teamSlot : index + 1;
                  final isDead = !snake.isAlive;
                  final nameColor = isDead
                      ? Colors.white38
                      : (snake.isPlayer ? Colors.cyanAccent : Colors.white70);
                  final valueColor = isDead ? Colors.white38 : Colors.amberAccent;
                  final killColor = isDead ? Colors.white38 : teamColor;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          alignment: Alignment.center,
                          child: Text(
                            '$slot',
                            style: TextStyle(
                              color: isDead ? Colors.white38 : teamColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              decoration: isDead ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            snake.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: nameColor,
                              fontSize: 7.5,
                              fontWeight: snake.isPlayer ? FontWeight.bold : FontWeight.normal,
                              decoration: isDead ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 18,
                          child: Text(
                            '${snake.score.toInt()}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: valueColor,
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              decoration: isDead ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                          child: Text(
                            '${snake.eliminationCount}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: killColor,
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              decoration: isDead ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
