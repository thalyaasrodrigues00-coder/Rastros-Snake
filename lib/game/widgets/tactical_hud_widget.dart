import 'package:flutter/material.dart';

import '../entities/snake.dart';

class TacticalHudWidget extends StatelessWidget {
  final List<Snake> teamMembers;
  final String currentSector;
  final VoidCallback onTurboPressed;
  final VoidCallback onTurboReleased;

  const TacticalHudWidget({
    super.key,
    required this.teamMembers,
    required this.currentSector,
    required this.onTurboPressed,
    required this.onTurboReleased,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 15,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
              ),
              child: Text(
                currentSector,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 50,
          right: 12,
          child: Container(
            width: 190,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SUA EQUIPE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 10),
                ...List.generate(teamMembers.length, (index) {
                  final member = teamMembers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: Colors.white,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            member.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: member.isPlayer ? Colors.cyanAccent : Colors.white,
                              fontSize: 11,
                              fontWeight: member.isPlayer ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          '${member.score.toInt()}',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 30,
          right: 20,
          child: GestureDetector(
            onTapDown: (_) => onTurboPressed(),
            onTapUp: (_) => onTurboReleased(),
            onTapCancel: onTurboReleased,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF0055), Color(0xFF880022)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF0055).withValues(alpha: 0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'TURBO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
