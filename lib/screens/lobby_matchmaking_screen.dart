import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../app/constants/game_constants.dart';
import '../game/game_screen.dart';
import '../models/matchmaking_models.dart';
import '../services/gemini_service.dart';
import '../services/online_service.dart';

class LobbyMatchmakingScreen extends StatefulWidget {
  final String playerNickname;
  final List<Color> playerSkinColors;
  final bool isTeamMode;

  const LobbyMatchmakingScreen({
    super.key,
    required this.playerNickname,
    required this.playerSkinColors,
    this.isTeamMode = true,
  });

  @override
  State<LobbyMatchmakingScreen> createState() => _LobbyMatchmakingScreenState();
}

class _LobbyMatchmakingScreenState extends State<LobbyMatchmakingScreen> with SingleTickerProviderStateMixin {
  static const int _totalSlots = GameConstants.totalPlayersInMatch;
  static const int _teamCount = 10;
  static const int _playersPerTeam = GameConstants.playersPerTeam;

  final OnlineService _onlineService = OnlineService();

  int _playersFound = 1;
  int _timeLeft = 0;
  bool _isNavigating = false;
  bool _isConnected = false;
  String? _statusMessage;
  String? _geminiTip;
  late AnimationController _spinController;
  Timer? _syncDisplayTimer;
  Timer? _offlineFallbackTimer;
  int? _fimEsperaMs;
  bool _serverMatchReceived = false;

  static const _fallbackTips = [
    'Use o turbo com sabedoria!',
    'Evite colidir com outras cobras!',
    'Coma comida para crescer e pontuar!',
    'No modo equipe, proteja seus aliados!',
    'Domine os túneis para escapar!',
  ];

  StreamSubscription<LoadingUpdate>? _loadingSub;
  StreamSubscription<MatchReadyPayload>? _matchSub;
  StreamSubscription<String>? _errorSub;
  StreamSubscription<bool>? _connectionSub;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _bindOnlineEvents();
    _startSyncDisplayTimer();
    _onlineService.joinQueue(
      nickname: widget.playerNickname,
      isTeamMode: widget.isTeamMode,
    );
    _loadGeminiTip();

    _offlineFallbackTimer = Timer(const Duration(seconds: 20), () {
      if (!mounted || _isNavigating || _serverMatchReceived || _isConnected) return;
      setState(() {
        _statusMessage = 'Servidor inacessível — partida local com bots.';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted || _isNavigating || _serverMatchReceived) return;
        _navigateToGame(_buildLocalPayload());
      });
    });
  }

  void _startSyncDisplayTimer() {
    _syncDisplayTimer?.cancel();
    _syncDisplayTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted || _fimEsperaMs == null) return;
      final remaining = ((_fimEsperaMs! - DateTime.now().millisecondsSinceEpoch) / 1000).ceil();
      setState(() => _timeLeft = remaining.clamp(0, 999));
    });
  }

  void _applyLoadingUpdate(LoadingUpdate update) {
    _fimEsperaMs = update.fimEsperaMs;
    _playersFound = update.humanosConectados.clamp(1, _totalSlots);
    if (_fimEsperaMs != null) {
      _timeLeft = ((_fimEsperaMs! - DateTime.now().millisecondsSinceEpoch) / 1000).ceil().clamp(0, 999);
    } else {
      _timeLeft = update.tempo.clamp(0, 999);
    }
  }

  MatchReadyPayload _buildLocalPayload() {
    return MatchReadyPayload(
      sala: 'local-${DateTime.now().millisecondsSinceEpoch}',
      modo: widget.isTeamMode ? 'equipe' : 'solo',
      jogadores: [
        MatchParticipant(
          id: 'local-player',
          nome: widget.playerNickname,
          isBot: false,
        ),
        ...List.generate(
          _totalSlots - 1,
          (i) => MatchParticipant(
            id: 'local-bot-$i',
            nome: 'Bot ${i + 1}',
            isBot: true,
          ),
        ),
      ],
    );
  }

  Future<void> _loadGeminiTip() async {
    final tip = await GeminiService().generateLobbyTip(isTeamMode: widget.isTeamMode);
    if (!mounted) return;
    setState(() {
      _geminiTip = tip ?? _fallbackTips[Random().nextInt(_fallbackTips.length)];
    });
  }

  void _bindOnlineEvents() {
    _loadingSub = _onlineService.loadingStream.listen((update) {
      if (!mounted) return;
      setState(() {
        _applyLoadingUpdate(update);
        _statusMessage = null;
      });
    });

    _matchSub = _onlineService.matchReadyStream.listen(_navigateToGame);

    _errorSub = _onlineService.errorStream.listen((message) {
      if (!mounted) return;
      setState(() {
        _statusMessage = message.contains('Falha ao conectar')
            ? 'Conectando ao servidor... verifique Wi‑Fi e se o servidor está ligado.'
            : message;
      });
    });

    _connectionSub = _onlineService.connectionStream.listen((connected) {
      if (!mounted) return;
      setState(() {
        _isConnected = connected;
        if (connected) {
          _offlineFallbackTimer?.cancel();
          _statusMessage = null;
        }
      });
    });
  }

  void _navigateToGame(MatchReadyPayload payload) {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    _serverMatchReceived = true;
    _offlineFallbackTimer?.cancel();
    _syncDisplayTimer?.cancel();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          playerName: widget.playerNickname,
          playerSkinColors: widget.playerSkinColors,
          isTeamMode: widget.isTeamMode,
          matchRoomId: payload.sala,
          matchPayload: payload,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _syncDisplayTimer?.cancel();
    _offlineFallbackTimer?.cancel();
    _loadingSub?.cancel();
    _matchSub?.cancel();
    _errorSub?.cancel();
    _connectionSub?.cancel();
    _spinController.dispose();
    if (!_isNavigating) {
      _onlineService.disconnect();
    }
    super.dispose();
  }

  int get _filledTeams => (_playersFound / _playersPerTeam).ceil().clamp(1, _teamCount);

  double get _fillProgress => _playersFound / _totalSlots;

  @override
  Widget build(BuildContext context) {
    final modeColor = widget.isTeamMode ? const Color(0xFFFFD700) : const Color(0xFF00E5FF);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1026), Color(0xFF1A0B2E), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: modeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: modeColor),
                    ),
                    child: Text(
                      widget.isTeamMode ? 'MODO EQUIPE — 10×5' : 'MODO SOLO',
                      style: TextStyle(color: modeColor, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: _isConnected ? Colors.greenAccent : Colors.orangeAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isConnected ? 'Conectado — sincronizando jogadores reais' : 'Conectando ao servidor...',
                        style: TextStyle(
                          color: _isConnected ? Colors.greenAccent : Colors.orangeAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RotationTransition(
                          turns: _spinController,
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                          ),
                        ),
                        Text(
                          '$_timeLeft',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PROCURANDO JOGADORES REAIS...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _fillProgress,
                      minHeight: 10,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$_playersFound humano(s) na fila · meta $_totalSlots',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (widget.isTeamMode) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Equipes parciais: $_filledTeams / $_teamCount',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    _timeLeft > 0
                        ? 'Sincronizando — $_timeLeft s (mesmo tempo para todos)'
                        : 'Completando com bots...',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                    ),
                  ],
                  if (_geminiTip != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _geminiTip!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  TextButton(
                    onPressed: _isNavigating ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
