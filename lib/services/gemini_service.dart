import 'package:google_generative_ai/google_generative_ai.dart';

import '../app/constants/api_keys.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  bool get isEnabled => _model != null;

  Future<void> init() async {
    if (!ApiKeys.isGeminiConfigured) return;

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: ApiKeys.geminiApiKey,
    );
  }

  Future<String?> generateLobbyTip({required bool isTeamMode}) async {
    if (_model == null) return null;

    try {
      final mode = isTeamMode ? 'equipe 10x5' : 'solo 50 jogadores';
      final response = await _model!.generateContent([
        Content.text(
          'Escreva UMA frase curta (máx 60 caracteres) em português para a tela de carregamento '
          'do jogo mobile "Rastros Snake" no modo $mode. Tom energético. Sem aspas.',
        ),
      ]);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) return null;
      return text.length > 60 ? text.substring(0, 60) : text;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> generateBotNames({required int count, required int teamId}) async {
    if (_model == null || count <= 0) return [];

    try {
      final teamLetter = String.fromCharCode(65 + teamId.clamp(0, 25));
      final response = await _model!.generateContent([
        Content.text(
          'Gere exatamente $count nicknames curtos (1 palavra, máx 12 letras) para cobras bots '
          'da equipe $teamLetter no jogo Rastros Snake. Responda só com os nomes separados por vírgula, sem numeração.',
        ),
      ]);
      final raw = response.text ?? '';
      final names = raw
          .split(',')
          .map((n) => n.trim())
          .where((n) => n.isNotEmpty)
          .take(count)
          .toList();
      return names;
    } catch (_) {
      return [];
    }
  }
}
