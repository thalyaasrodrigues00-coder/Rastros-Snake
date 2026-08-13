import 'package:flutter/material.dart';
import '../../app/constants/game_constants.dart';
import 'snake_head.dart';
import 'snake_segment.dart';

class Snake {
  final int id;
  final String name;
  Color skinColor;
  List<Color> skinColors;
  final bool isPlayer;
  final bool isBot;
  final String? networkId;
  int teamId;
  int teamSlot;

  late SnakeHead head;
  List<SnakeSegment> segments = [];
  List<Offset> positionHistory = []; // Fila de histórico para o rastro da cauda

  // Espaçamento reduzido para unir os gomos e eliminar lacunas visuais
  static const double segmentSpacing = 6.0;
  static const int _historyStep = 2;

  bool get isRemoteHuman => networkId != null && !isPlayer;

  Color colorAt(int index) => skinColors[index % skinColors.length];

  double score;
  bool isBoosting = false;
  bool isAlive = true;
  bool hasCrown = false;
  int eliminationCount = 0;

  Snake({
    required this.id,
    required this.name,
    required this.skinColor,
    List<Color>? skinColors,
    required Offset initialPosition,
    this.isPlayer = false,
    this.isBot = false,
    this.networkId,
    this.teamId = -1,
    this.teamSlot = 0,
    double initialScore = 0.0,
  }) : score = initialScore,
       skinColors = skinColors ?? [skinColor] {
    head = SnakeHead(
      position: initialPosition,
      radius: GameConstants.initialSnakeRadius,
    );

    _initBody(initialPosition);
  }

  void _initBody(Offset startPos) {
    segments.clear();
    positionHistory.clear();

    for (int i = 0; i < 20; i++) {
      positionHistory.add(startPos - Offset(i * segmentSpacing * 0.8, 0));
    }

    const double miniRadius = GameConstants.initialSnakeRadius * 0.85;
    segments.add(
      SnakeSegment(
        position: startPos - const Offset(segmentSpacing, 0),
        radius: miniRadius,
      ),
    );
    segments.add(
      SnakeSegment(
        position: startPos - const Offset(segmentSpacing * 2, 0),
        radius: miniRadius,
      ),
    );
  }

  // Atualiza a cauda seguindo o histórico gravado pela cabeça
  void updateTail() {
    positionHistory.insert(0, head.position);

    // Mantém o histórico limitado ao tamanho necessário da cobra
    int maxHistory = (segments.length + 1) * 3;
    if (positionHistory.length > maxHistory) {
      positionHistory.removeRange(maxHistory, positionHistory.length);
    }

    for (int i = 0; i < segments.length; i++) {
      int historyIndex = (i + 1) * _historyStep;
      if (historyIndex < positionHistory.length) {
        segments[i].position = positionHistory[historyIndex];
      }
    }
  }

  void grow(double amount) {
    score += amount;
    int targetSegments = (score / 2.0).clamp(2, 300).toInt();

    while (segments.length < targetSegments) {
      Offset lastPos = segments.isNotEmpty ? segments.last.position : head.position;
      segments.add(
        SnakeSegment(
          position: lastPos,
          radius: head.radius * 0.92,
        ),
      );
    }
  }

  void shrink(double amount) {
    score = (score - amount).clamp(0.0, 99999.0);
    int targetSegments = (score / 2.0).clamp(2, 300).toInt();

    while (segments.length > targetSegments && segments.length > 2) {
      segments.removeLast();
    }
  }

  void reset(Offset newPosition) {
    score = 0.0;
    isAlive = true;
    isBoosting = false;
    hasCrown = false;
    eliminationCount = 0;
    head = SnakeHead(
      position: newPosition,
      radius: GameConstants.initialSnakeRadius,
    );
    _initBody(newPosition);
  }
}
