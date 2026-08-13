import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int rank;
  final VoidCallback onRespawn;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.rank,
    required this.onRespawn,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'GAME OVER',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sua cobra colidiu!', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(
            'Pontuação Final: $score',
            style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Posição no Ranking: #$rank',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRespawn,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4ADE80),
                        Color(0xFF22C55E),
                        Color(0xFF16A34A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    child: const Text(
                      'Renascer Agora',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                backgroundColor: Colors.grey.withValues(alpha: 0.25),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Voltar ao Menu Principal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
