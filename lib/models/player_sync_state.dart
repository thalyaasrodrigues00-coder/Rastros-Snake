class PlayerSyncState {
  final String id;
  final double x;
  final double y;
  final double angle;
  final double score;
  final bool boosting;
  final bool alive;
  final String nome;
  final int teamId;

  const PlayerSyncState({
    required this.id,
    required this.x,
    required this.y,
    required this.angle,
    required this.score,
    required this.boosting,
    required this.alive,
    required this.nome,
    this.teamId = -1,
  });

  factory PlayerSyncState.fromJson(Map<String, dynamic> json) {
    return PlayerSyncState(
      id: json['id']?.toString() ?? '',
      x: _asDouble(json['x']),
      y: _asDouble(json['y']),
      angle: _asDouble(json['angle']),
      score: _asDouble(json['score']),
      boosting: json['boosting'] == true,
      alive: json['alive'] != false,
      nome: json['nome']?.toString() ?? 'Jogador',
      teamId: _asInt(json['teamId'], fallback: -1),
    );
  }
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
