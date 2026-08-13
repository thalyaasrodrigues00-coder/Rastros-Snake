import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../app/audio/audio_manager.dart';
import '../app/constants/app_colors.dart';
import '../app/constants/game_constants.dart';
import '../models/matchmaking_models.dart';
import '../models/player_sync_state.dart';
import 'widgets/hud_layout.dart';
import 'entities/boundary.dart';
import 'entities/food.dart';
import 'entities/snake.dart';
import 'entities/tunnel.dart';
import 'systems/ai_system.dart';
import 'systems/camera_system.dart';
import 'systems/collision_system.dart';
import 'systems/crown_system.dart';
import 'systems/food_system.dart';
import 'systems/movement_system.dart';
import 'systems/tunnel_system.dart';

class _ParticipantEntry {
  final MatchParticipant participant;
  final int teamId;
  final int teamSlot;

  const _ParticipantEntry({
    required this.participant,
    required this.teamId,
    required this.teamSlot,
  });
}

class GameLoop extends ChangeNotifier {
  late Ticker _ticker;
  late Boundary boundary;
  late Snake player;

  List<Snake> bots = [];
  List<Snake> remoteHumans = [];
  List<Snake> allSnakes = [];
  final Map<String, Snake> _remoteByNetworkId = {};
  List<Food> foodPool = [];
  List<Tunnel> tunnels = [];
  List<Snake> leaderboard = [];

  late MovementSystem movementSystem;
  late CollisionSystem collisionSystem;
  late TunnelSystem tunnelSystem;
  late FoodSystem foodSystem;
  late AISystem aiSystem;
  late CameraSystem cameraSystem;
  late CrownSystem crownSystem;

  bool isPlaying = false;
  bool isTeamMode = false;
  bool isSpectating = false;
  bool matchEnded = false;
  int? winningTeamId;
  double playerTargetAngle = 0.0;
  double lastDt = 0.016;
  Duration? _lastElapsed;
  Offset? playerDeathMarker;
  bool _wasPlayerBoosting = false;

  GameLoop(
    TickerProvider vsync, {
    String? playerName,
    List<Color>? playerSkinColors,
    bool isTeamMode = false,
    MatchReadyPayload? matchPayload,
    String? localSocketId,
  }) {
    this.isTeamMode = isTeamMode;
    _initGame(
      playerName: playerName,
      playerSkinColors: playerSkinColors,
      matchPayload: matchPayload,
      localSocketId: localSocketId,
    );
    _ticker = vsync.createTicker(_tick);
  }

  List<_ParticipantEntry> _flattenParticipants(MatchReadyPayload? payload) {
    if (payload == null) return [];

    if (payload.jogadores != null) {
      return payload.jogadores!
          .map((p) => _ParticipantEntry(participant: p, teamId: -1, teamSlot: 0))
          .toList();
    }

    if (payload.equipes != null) {
      final entries = <_ParticipantEntry>[];
      for (final team in payload.equipes!) {
        for (int i = 0; i < team.membros.length; i++) {
          entries.add(
            _ParticipantEntry(
              participant: team.membros[i],
              teamId: team.id,
              teamSlot: i + 1,
            ),
          );
        }
      }
      return entries;
    }

    return [];
  }

  List<Offset> _generateSpreadSpawns(int count) {
    const margin = 450.0;
    const minDist = 400.0;
    final rand = Random(count);
    final positions = <Offset>[];

    for (int i = 0; i < count; i++) {
      Offset? chosen;
      for (int attempt = 0; attempt < 300; attempt++) {
        final candidate = Offset(
          margin + rand.nextDouble() * (boundary.width - margin * 2),
          margin + rand.nextDouble() * (boundary.height - margin * 2),
        );
        if (positions.every((p) => (p - candidate).distance >= minDist)) {
          chosen = candidate;
          break;
        }
      }
      positions.add(
        chosen ??
            Offset(
              margin + (i * 137.0) % (boundary.width - margin * 2),
              margin + (i * 211.0) % (boundary.height - margin * 2),
            ),
      );
    }

    return positions;
  }

  void applyRemoteState(PlayerSyncState state) {
    var snake = _remoteByNetworkId[state.id];
    if (snake == null) {
      snake = Snake(
        id: 9000 + _remoteByNetworkId.length,
        name: state.nome,
        networkId: state.id,
        skinColor: AppColors.snakeSkins[_remoteByNetworkId.length % AppColors.snakeSkins.length],
        initialPosition: Offset(state.x, state.y),
        teamId: state.teamId,
      );
      _remoteByNetworkId[state.id] = snake;
      remoteHumans.add(snake);
      allSnakes = [player, ...remoteHumans, ...bots];
    }

    if (!state.alive) {
      snake.isAlive = false;
      return;
    }

    snake.head.position = Offset(state.x, state.y);
    snake.head.angle = state.angle;
    snake.score = state.score;
    snake.isBoosting = state.boosting;
    snake.isAlive = true;
    if (state.teamId >= 0) {
      final color = Color(HudLayout.teamColors[state.teamId % HudLayout.teamColors.length]);
      snake.skinColor = color;
      snake.skinColors = [color, color.withValues(alpha: 0.75)];
      snake.teamId = state.teamId;
    }
    snake.updateTail();
  }

  void markRemoteDead(String networkId) {
    _remoteByNetworkId[networkId]?.isAlive = false;
  }

  void _initGame({
    String? playerName,
    List<Color>? playerSkinColors,
    MatchReadyPayload? matchPayload,
    String? localSocketId,
  }) {
    boundary = Boundary(width: GameConstants.worldWidth, height: GameConstants.worldHeight);

    movementSystem = MovementSystem(boundary: boundary);
    collisionSystem = CollisionSystem();
    aiSystem = AISystem(boundary: boundary);
    cameraSystem = CameraSystem();
    crownSystem = CrownSystem();
    foodSystem = FoodSystem(boundary: boundary);

    tunnels = [
      Tunnel(id: 1, targetTunnelId: 2, position: const Offset(180, 180), exitDirection: const Offset(1, 1)),
      Tunnel(id: 2, targetTunnelId: 1, position: const Offset(8820, 8820), exitDirection: const Offset(-1, -1)),
      Tunnel(id: 3, targetTunnelId: 4, position: const Offset(8820, 180), exitDirection: const Offset(-1, 1)),
      Tunnel(id: 4, targetTunnelId: 3, position: const Offset(180, 8820), exitDirection: const Offset(1, -1)),
      Tunnel(id: 5, targetTunnelId: 6, position: const Offset(4500, 240), exitDirection: const Offset(0, 1)),
      Tunnel(id: 6, targetTunnelId: 5, position: const Offset(4500, 8760), exitDirection: const Offset(0, -1)),
    ];
    tunnelSystem = TunnelSystem(tunnels: tunnels);

    final entries = _flattenParticipants(matchPayload);
    final totalCount = entries.isNotEmpty ? entries.length : GameConstants.totalSnakes;
    final spawns = _generateSpreadSpawns(totalCount);

    _ParticipantEntry? localEntry;
    if (localSocketId != null && entries.isNotEmpty) {
      final idx = entries.indexWhere((e) => e.participant.id == localSocketId);
      if (idx >= 0) localEntry = entries[idx];
    }
    localEntry ??= entries.isNotEmpty
        ? entries.firstWhere(
            (e) => !e.participant.isBot,
            orElse: () => entries.first,
          )
        : null;

    final localSpawn = spawns.isNotEmpty ? spawns[0] : Offset(boundary.width / 2, boundary.height / 2);
    final localIndex = localEntry != null ? entries.indexOf(localEntry) : 0;
    final playerSpawn = localIndex < spawns.length ? spawns[localIndex] : localSpawn;

    player = Snake(
      id: 0,
      name: localEntry?.participant.nome ?? playerName ?? 'Você',
      skinColor: playerSkinColors?.first ?? Colors.cyan,
      skinColors: playerSkinColors ?? const [Colors.cyan],
      initialPosition: playerSpawn,
      isPlayer: true,
      teamId: localEntry?.teamId ?? -1,
      teamSlot: localEntry?.teamSlot ?? 0,
    );

    remoteHumans = [];
    bots = [];
    _remoteByNetworkId.clear();
    int botId = 1;

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final p = entry.participant;
      if (localSocketId != null && p.id == localSocketId) continue;
      if (!p.isBot) continue;

      final spawn = i < spawns.length ? spawns[i] : playerSpawn;
      Color color = AppColors.snakeSkins[botId % AppColors.snakeSkins.length];
      if (isTeamMode && entry.teamId >= 0) {
        color = Color(HudLayout.teamColors[entry.teamId % HudLayout.teamColors.length]);
      }

      bots.add(
        Snake(
          id: botId++,
          name: p.nome,
          skinColor: color,
          skinColors: [color, color.withValues(alpha: 0.75)],
          initialPosition: spawn,
          isBot: true,
          teamId: entry.teamId,
          teamSlot: entry.teamSlot,
        ),
      );
    }

    while (bots.length + remoteHumans.length < GameConstants.totalSnakes - 1) {
      final idx = bots.length + remoteHumans.length + 1;
      final spawn = idx < spawns.length ? spawns[idx] : _getSafeSpawnPosition();
      bots.add(
        Snake(
          id: botId++,
          name: 'Bot $idx',
          skinColor: AppColors.snakeSkins[idx % AppColors.snakeSkins.length],
          initialPosition: spawn,
          isBot: true,
        ),
      );
    }

    allSnakes = [player, ...remoteHumans, ...bots];

    if (isTeamMode && entries.isEmpty) {
      _assignTeams();
    } else if (isTeamMode && localEntry != null) {
      player.skinColor = Color(HudLayout.teamColors[localEntry.teamId % HudLayout.teamColors.length]);
      player.skinColors = [player.skinColor, player.skinColor.withValues(alpha: 0.75)];
    }

    foodPool = List.generate(
      GameConstants.maxFoodCount,
      (i) => Food(
        id: i,
        position: Offset.zero,
        color: AppColors.foodColors[i % AppColors.foodColors.length],
      ),
    );
    foodSystem.initializeFoodPool(foodPool);

    leaderboard = crownSystem.updateCrownAndRankings(allSnakes);
  }

  void _assignTeams() {
    if (!isTeamMode) {
      player.teamId = -1;
      player.teamSlot = 0;
      for (final bot in bots) {
        bot.teamId = -1;
        bot.teamSlot = 0;
      }
      return;
    }

    for (int i = 0; i < allSnakes.length; i++) {
      final snake = allSnakes[i];
      final teamId = i ~/ GameConstants.playersPerTeam;
      final teamSlot = (i % GameConstants.playersPerTeam) + 1;
      final teamColor = Color(
        HudLayout.teamColors[teamId % HudLayout.teamColors.length],
      );

      snake.teamId = teamId;
      snake.teamSlot = teamSlot;
      snake.skinColor = teamColor;
      snake.skinColors = [teamColor, teamColor.withValues(alpha: 0.75)];
    }
  }

  List<Snake> get teamMembers {
    if (!isTeamMode) return [player];
    return allSnakes.where((s) => s.teamId == player.teamId).toList();
  }

  Snake? get spectatorTarget {
    if (!isSpectating) return null;
    final aliveAllies = teamMembers.where((s) => s.isAlive).toList();
    if (aliveAllies.isEmpty) return null;
    return aliveAllies.first;
  }

  Snake get cameraFocusSnake => (isSpectating && spectatorTarget != null) ? spectatorTarget! : player;

  bool get playerTeamEliminated =>
      isTeamMode && teamMembers.every((member) => !member.isAlive);

  int get alivePlayersCount => allSnakes.where((s) => s.isAlive).length;

  int get totalPlayersCount => allSnakes.length;

  int get aliveTeamsCount {
    if (!isTeamMode) return alivePlayersCount > 0 ? 1 : 0;
    final teams = <int>{};
    for (final snake in allSnakes) {
      if (snake.isAlive) teams.add(snake.teamId);
    }
    return teams.length;
  }

  int get teamEliminationTotal =>
      teamMembers.fold<int>(0, (sum, member) => sum + member.eliminationCount);

  void _checkTeamVictory() {
    if (!isTeamMode || matchEnded) return;

    final aliveTeams = <int>{};
    for (final snake in allSnakes) {
      if (snake.isAlive) aliveTeams.add(snake.teamId);
    }

    if (aliveTeams.length <= 1) {
      matchEnded = true;
      winningTeamId = aliveTeams.isEmpty ? null : aliveTeams.first;
      pause();
    }
  }

  void start() {
    isPlaying = true;
    _lastElapsed = null;
    _ticker.start();
  }

  void pause() {
    isPlaying = false;
    _ticker.stop();
  }

  void respawnPlayer() {
    if (isTeamMode) return;
    isSpectating = false;
    player.score = 0;
    player.reset(_getSafeSpawnPosition());
    if (!isPlaying) start();
  }

  Offset _getSafeSpawnPosition() {
    const margin = 200.0;
    final center = Offset(boundary.width / 2, boundary.height / 2);
    return Offset(
      center.dx.clamp(margin, boundary.width - margin),
      center.dy.clamp(margin, boundary.height - margin),
    );
  }

  void setPlayerAngle(double angle) {
    playerTargetAngle = angle;
  }

  void setPlayerBoost(bool boosting) {
    if (boosting && !_wasPlayerBoosting && player.isAlive) {
      AudioManager().playBoostSound();
    }
    _wasPlayerBoosting = boosting;
    player.isBoosting = boosting;
  }

  void _tick(Duration elapsed) {
    if (_lastElapsed != null) {
      lastDt = (elapsed - _lastElapsed!).inMicroseconds / 1000000.0;
      lastDt = lastDt.clamp(0.001, 0.05);
    }
    _lastElapsed = elapsed;

    if (!isPlaying) return;

    if (!isSpectating && player.isAlive) {
      movementSystem.updateSnake(player, playerTargetAngle, lastDt);
    }

    aiSystem.updateBots(bots, foodPool, lastDt, isTeamMode: isTeamMode);
    for (final bot in bots) {
      if (bot.isAlive && bot.isBot) {
        movementSystem.updateSnake(bot, bot.head.angle, lastDt);
      }
    }

    final playerPosBeforeTunnel = player.head.position;
    tunnelSystem.update(allSnakes, lastDt);
    if (player.isAlive && (player.head.position - playerPosBeforeTunnel).distance > 500) {
      AudioManager().playTunnelSound();
    }

    final scoreBeforeFood = player.score;
    foodSystem.updateFoodInteractions(allSnakes, foodPool, lastDt);
    if (player.isAlive && player.score > scoreBeforeFood) {
      AudioManager().playEatSound();
    }

    final deadSnakes = collisionSystem.checkSnakeCollisions(allSnakes);
    for (final dead in deadSnakes) {
      if (dead.isPlayer) {
        playerDeathMarker = dead.head.position;
        AudioManager().playCollisionSound();
        if (isTeamMode) {
          isSpectating = true;
        }
      }
      collisionSystem.convertDeadSnakeToFood(dead, foodPool);
      if (dead.isBot && !isTeamMode) {
        dead.reset(_getSafeSpawnPosition());
      }
    }

    if (isTeamMode) {
      _checkTeamVictory();
    }

    leaderboard = crownSystem.updateCrownAndRankings(allSnakes);

    notifyListeners();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
