import 'dart:async';

import 'package:flutter/material.dart';

import '../app/audio/audio_manager.dart';
import '../app/services/ad_service.dart';
import '../services/ad_service.dart' as ad_policy;
import '../app/services/settings_service.dart';
import '../models/matchmaking_models.dart';
import '../services/game_sync_service.dart';
import '../services/online_service.dart';
import '../services/voice_service.dart';
import 'game_loop.dart';
import 'renderers/world_painter.dart';
import 'widgets/arena_alive_counter_widget.dart';
import 'widgets/game_joystick_widget.dart';
import 'widgets/game_map_panel_widget.dart';
import 'widgets/game_over_dialog.dart';
import 'widgets/game_scoreboard_widget.dart';
import 'widgets/hud_layout.dart';
import 'widgets/team_map_controls_widget.dart';

class GameScreen extends StatefulWidget {
  final String? playerName;
  final List<Color>? playerSkinColors;
  final bool isTeamMode;
  final String? matchRoomId;
  final MatchReadyPayload? matchPayload;

  const GameScreen({
    super.key,
    this.playerName,
    this.playerSkinColors,
    this.isTeamMode = false,
    this.matchRoomId,
    this.matchPayload,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameLoop _gameLoop;
  final SettingsService _settingsService = SettingsService();
  final VoiceService _voiceService = VoiceService();
  final GameSyncService _gameSync = GameSyncService();
  final OnlineService _onlineService = OnlineService();
  Timer? _syncBroadcastTimer;
  bool _matchResultShown = false;

  bool get _isOnlineMatch =>
      widget.matchRoomId != null && widget.matchRoomId!.startsWith('partida_');

  @override
  void initState() {
    super.initState();
    AudioManager().pauseMenuBgm();
    _gameLoop = GameLoop(
      this,
      playerName: widget.playerName,
      playerSkinColors: widget.playerSkinColors,
      isTeamMode: widget.isTeamMode,
      matchPayload: widget.matchPayload,
      localSocketId: _onlineService.socketId,
    );
    _gameLoop.start();
    _gameLoop.addListener(_onGameLoopUpdate);
    if (widget.isTeamMode) {
      _voiceService.initialize();
    }
    if (_isOnlineMatch) {
      _startOnlineSync();
    }
  }

  void _startOnlineSync() {
    _gameSync.start(
      roomId: widget.matchRoomId!,
      onState: _gameLoop.applyRemoteState,
      onDeath: _gameLoop.markRemoteDead,
    );

    _syncBroadcastTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!_gameLoop.player.isAlive) return;
      final p = _gameLoop.player;
      _gameSync.broadcast(
        x: p.head.position.dx,
        y: p.head.position.dy,
        angle: p.head.angle,
        score: p.score,
        boosting: p.isBoosting,
        alive: p.isAlive,
        nome: p.name,
        teamId: p.teamId,
      );
    });
  }

  void _onGameLoopUpdate() {
    if (_gameLoop.isTeamMode && _gameLoop.matchEnded && !_matchResultShown) {
      _matchResultShown = true;
      _showTeamMatchResult();
      return;
    }

    if (!_gameLoop.isTeamMode) {
      _checkSoloGameOver();
    }
  }

  void _checkSoloGameOver() {
    if (!_gameLoop.player.isAlive && _gameLoop.isPlaying) {
      _gameLoop.pause();
      AudioManager().playGameOverSound();
      ad_policy.AdService.handleGameOver(false, () {
        AdService().showInterstitialAd();
      });
      final finalScore = _gameLoop.player.score.toInt();
      _settingsService.updateHighScore(finalScore);
      final rank = _gameLoop.leaderboard.indexWhere((s) => s.isPlayer) + 1;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameOverDialog(
          score: finalScore,
          rank: rank > 0 ? rank : _gameLoop.leaderboard.length + 1,
          onRespawn: () {
            Navigator.pop(context);
            _gameLoop.respawnPlayer();
          },
        ),
      );
    }
  }

  void _showTeamMatchResult() {
    AudioManager().playGameOverSound();
    final finalScore = _gameLoop.player.score.toInt();
    _settingsService.updateTeamHighScore(finalScore);
    final playerWon = _gameLoop.winningTeamId == _gameLoop.player.teamId;
    final teamLabel = String.fromCharCode(65 + _gameLoop.player.teamId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          playerWon ? 'VITÓRIA DA EQUIPE $teamLabel!' : 'EQUIPE ELIMINADA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: playerWon ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              playerWon
                  ? 'Sua equipe foi a última sobrevivente na arena!'
                  : 'A equipe ${String.fromCharCode(65 + (_gameLoop.winningTeamId ?? 0))} venceu a partida.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Text(
              'Sua pontuação: $finalScore',
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Voltar ao Menu'),
          ),
        ],
      ),
    );
  }

  int _playerTeamScore() {
    return _gameLoop.teamMembers.fold<int>(0, (sum, s) => sum + s.score.toInt());
  }

  @override
  void dispose() {
    _syncBroadcastTimer?.cancel();
    _gameSync.stop();
    _gameLoop.removeListener(_onGameLoopUpdate);
    _gameLoop.dispose();
    if (widget.isTeamMode) {
      _voiceService.dispose();
    }
    _onlineService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final canControl = !_gameLoop.isSpectating && _gameLoop.player.isAlive;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gameLoop,
        builder: (context, _) {
          final focusSnake = _gameLoop.cameraFocusSnake;
          final cameraOffset = _gameLoop.cameraSystem.updateCamera(
            playerHeadPosition: focusSnake.head.position,
            playerScore: focusSnake.score,
            screenSize: screenSize,
            dt: _gameLoop.lastDt,
          );

          return Stack(
            children: [
              CustomPaint(
                size: screenSize,
                painter: WorldPainter(
                  boundary: _gameLoop.boundary,
                  snakes: _gameLoop.allSnakes,
                  foodPool: _gameLoop.foodPool,
                  tunnels: _gameLoop.tunnels,
                  cameraOffset: cameraOffset,
                  zoom: _gameLoop.cameraSystem.currentZoom,
                  dt: _gameLoop.lastDt,
                  isTeamMode: _gameLoop.isTeamMode,
                  playerTeamId: _gameLoop.player.teamId,
                ),
              ),

              ArenaAliveCounterWidget(
                aliveCount: _gameLoop.alivePlayersCount,
                totalCount: _gameLoop.totalPlayersCount,
                isTeamMode: _gameLoop.isTeamMode,
                aliveTeamsCount: _gameLoop.isTeamMode ? _gameLoop.aliveTeamsCount : null,
              ),

              GameMapPanelWidget(
                boundary: _gameLoop.boundary,
                snakes: _gameLoop.allSnakes,
                teamMembers: _gameLoop.teamMembers,
                player: _gameLoop.player,
                foodPool: _gameLoop.foodPool,
                tunnels: _gameLoop.tunnels,
                deathMarker: _gameLoop.playerDeathMarker,
                isTeamMode: _gameLoop.isTeamMode,
                playerTeamId: _gameLoop.player.teamId,
                teamScoreOverlay: _gameLoop.isTeamMode ? _playerTeamScore() : null,
              ),

              if (_gameLoop.isTeamMode)
                TeamMapControlsWidget(
                  onHome: () {
                    _gameLoop.pause();
                    Navigator.pop(context);
                  },
                  onMicToggle: (muted) => _voiceService.setMuted(muted),
                  onSpeakerToggle: (muted) => _voiceService.setSpeakerMuted(muted),
                ),

              if (_gameLoop.isTeamMode)
                TeamScoreboardWidget(
                  teamMembers: _gameLoop.teamMembers,
                  playerTeamId: _gameLoop.player.teamId,
                )
              else
                SoloScoreboardWidget(leaderboard: _gameLoop.leaderboard),

              GameJoystickWidget(
                enabled: canControl,
                onAngleChanged: (angle) {
                  if (angle != null) _gameLoop.setPlayerAngle(angle);
                },
                onBoostChanged: (boost) => _gameLoop.setPlayerBoost(boost),
              ),

              if (_gameLoop.isSpectating)
                Positioned(
                  top: HudLayout.edgePadding + HudLayout.mapSize + 8,
                  left: HudLayout.edgePadding,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _gameLoop.spectatorTarget != null
                          ? 'ESPECTADOR — ${_gameLoop.spectatorTarget!.name}'
                          : 'ESPECTADOR — Equipe eliminada',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
