import 'dart:async';

import '../models/player_sync_state.dart';
import 'online_service.dart';

class GameSyncService {
  static final GameSyncService _instance = GameSyncService._internal();
  factory GameSyncService() => _instance;
  GameSyncService._internal();

  final OnlineService _online = OnlineService();
  StreamSubscription<PlayerSyncState>? _syncSub;
  StreamSubscription<String>? _deathSub;
  String? _activeRoom;
  void Function(PlayerSyncState state)? onRemoteState;
  void Function(String id)? onRemoteDeath;

  bool get isActive => _activeRoom != null;

  void start({
    required String roomId,
    required void Function(PlayerSyncState state) onState,
    void Function(String id)? onDeath,
  }) {
    stop();
    _activeRoom = roomId;
    onRemoteState = onState;
    onRemoteDeath = onDeath;
    _online.joinGameRoom(roomId);
    _syncSub = _online.syncStream.listen((state) {
      if (state.id == _online.socketId) return;
      onRemoteState?.call(state);
    });
    _deathSub = _online.deathStream.listen((id) {
      if (id == _online.socketId) return;
      onRemoteDeath?.call(id);
    });
  }

  void broadcast({
    required double x,
    required double y,
    required double angle,
    required double score,
    required bool boosting,
    required bool alive,
    required String nome,
    required int teamId,
  }) {
    if (_activeRoom == null) return;
    _online.sendPlayerState(
      sala: _activeRoom!,
      x: x,
      y: y,
      angle: angle,
      score: score,
      boosting: boosting,
      alive: alive,
      nome: nome,
      teamId: teamId,
    );
  }

  void notifyDeath({String? mortoPor}) {
    if (_activeRoom == null) return;
    _online.sendDeath(sala: _activeRoom!, mortoPor: mortoPor);
  }

  void stop() {
    _syncSub?.cancel();
    _deathSub?.cancel();
    _syncSub = null;
    _deathSub = null;
    _activeRoom = null;
    onRemoteState = null;
    onRemoteDeath = null;
  }
}
