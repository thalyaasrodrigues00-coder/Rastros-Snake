class LoadingUpdate {
  final int humanosConectados;
  final int tempo;
  final int maxJogadores;
  final int? fimEsperaMs;

  const LoadingUpdate({
    required this.humanosConectados,
    required this.tempo,
    required this.maxJogadores,
    this.fimEsperaMs,
  });

  factory LoadingUpdate.fromJson(Map<String, dynamic> json) {
    return LoadingUpdate(
      humanosConectados: _asInt(json['humanosConectados']),
      tempo: _asInt(json['tempo']),
      maxJogadores: _asInt(json['maxJogadores'], fallback: 50),
      fimEsperaMs: json['fimEsperaMs'] is int ? json['fimEsperaMs'] as int : null,
    );
  }
}

class MatchParticipant {
  final String id;
  final String nome;
  final bool isBot;

  const MatchParticipant({
    required this.id,
    required this.nome,
    required this.isBot,
  });

  factory MatchParticipant.fromJson(Map<String, dynamic> json) {
    return MatchParticipant(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? 'Jogador',
      isBot: json['isBot'] == true,
    );
  }
}

class MatchTeam {
  final int id;
  final String nomeEquipe;
  final List<MatchParticipant> membros;

  const MatchTeam({
    required this.id,
    required this.nomeEquipe,
    required this.membros,
  });

  factory MatchTeam.fromJson(Map<String, dynamic> json) {
    final rawMembros = json['membros'];
    final membros = rawMembros is List
        ? rawMembros
            .whereType<Map>()
            .map((m) => MatchParticipant.fromJson(Map<String, dynamic>.from(m)))
            .toList()
        : <MatchParticipant>[];

    return MatchTeam(
      id: _asInt(json['id']),
      nomeEquipe: json['nomeEquipe']?.toString() ?? 'Equipe',
      membros: membros,
    );
  }
}

class MatchReadyPayload {
  final String sala;
  final String modo;
  final List<MatchParticipant>? jogadores;
  final List<MatchTeam>? equipes;

  const MatchReadyPayload({
    required this.sala,
    required this.modo,
    this.jogadores,
    this.equipes,
  });

  bool get isTeamMode => modo == 'equipe';

  int get totalParticipants {
    if (jogadores != null) return jogadores!.length;
    if (equipes != null) {
      return equipes!.fold<int>(0, (sum, team) => sum + team.membros.length);
    }
    return 0;
  }

  factory MatchReadyPayload.fromJson(Map<String, dynamic> json) {
    final rawJogadores = json['jogadores'];
    final rawEquipes = json['equipes'];

    return MatchReadyPayload(
      sala: json['sala']?.toString() ?? '',
      modo: json['modo']?.toString() ?? 'solo',
      jogadores: rawJogadores is List
          ? rawJogadores
              .whereType<Map>()
              .map((m) => MatchParticipant.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : null,
      equipes: rawEquipes is List
          ? rawEquipes
              .whereType<Map>()
              .map((m) => MatchTeam.fromJson(Map<String, dynamic>.from(m)))
              .toList()
          : null,
    );
  }
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
