import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../app/constants/server_config.dart';
import '../models/matchmaking_models.dart';
import '../models/player_sync_state.dart';

class OnlineService {
  static final OnlineService _instance = OnlineService._internal();
  factory OnlineService() => _instance;
  OnlineService._internal();

  io.Socket? _socket;
  MatchReadyPayload? lastMatchPayload;

  final _loadingController = StreamController<LoadingUpdate>.broadcast();
  final _matchReadyController = StreamController<MatchReadyPayload>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _syncController = StreamController<PlayerSyncState>.broadcast();
  final _deathController = StreamController<String>.broadcast();

  Stream<LoadingUpdate> get loadingStream => _loadingController.stream;
  Stream<MatchReadyPayload> get matchReadyStream => _matchReadyController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<PlayerSyncState> get syncStream => _syncController.stream;
  Stream<String> get deathStream => _deathController.stream;

  bool get isConnected => _socket?.connected ?? false;
  String? get socketId => _socket?.id;

  void joinQueue({required String nickname, required bool isTeamMode}) {
    disconnect(clearMatch: false);

    final modo = isTeamMode ? 'equipe' : 'solo';

    _socket = io.io(
      ServerConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!
      ..onConnect((_) {
        _connectionController.add(true);
        _socket?.emit('clicouJogar', {
          'nomeUsuario': nickname,
          'modo': modo,
        });
      })
      ..onDisconnect((_) => _connectionController.add(false))
      ..onConnectError((error) {
        _connectionController.add(false);
        _errorController.add('Falha ao conectar ao servidor: $error');
      })
      ..on('atualizarCarregamento', _handleLoadingUpdate)
      ..on('partidaPronta', _handleMatchReady)
      ..on('iniciarPartida', _handleMatchReady)
      ..on('syncEstado', _handleSyncEstado)
      ..on('syncMorte', _handleSyncMorte)
      ..on('erroFila', (data) {
        if (data is Map && data['mensagem'] != null) {
          _errorController.add(data['mensagem'].toString());
        }
      });

    _socket!.connect();
  }

  void joinGameRoom(String roomId) {
    _socket?.emit('entrandoPartida', {'sala': roomId});
  }

  void sendPlayerState({
    required String sala,
    required double x,
    required double y,
    required double angle,
    required double score,
    required bool boosting,
    required bool alive,
    required String nome,
    required int teamId,
  }) {
    _socket?.emit('syncEstado', {
      'sala': sala,
      'x': x,
      'y': y,
      'angle': angle,
      'score': score,
      'boosting': boosting,
      'alive': alive,
      'nome': nome,
      'teamId': teamId,
    });
  }

  void sendDeath({required String sala, String? mortoPor}) {
    _socket?.emit('syncMorte', {
      'sala': sala,
      'mortoPor': mortoPor,
    });
  }

  void _handleLoadingUpdate(dynamic data) {
    if (data is! Map) return;
    _loadingController.add(
      LoadingUpdate.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  void _handleMatchReady(dynamic data) {
    if (data is! Map) return;
    final payload = MatchReadyPayload.fromJson(Map<String, dynamic>.from(data));
    lastMatchPayload = payload;
    _matchReadyController.add(payload);
  }

  void _handleSyncEstado(dynamic data) {
    if (data is! Map) return;
    _syncController.add(
      PlayerSyncState.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  void _handleSyncMorte(dynamic data) {
    if (data is! Map) return;
    final id = data['id']?.toString();
    if (id != null && id.isNotEmpty) {
      _deathController.add(id);
    }
  }

  void disconnect({bool clearMatch = true}) {
    _socket?.off('atualizarCarregamento');
    _socket?.off('partidaPronta');
    _socket?.off('iniciarPartida');
    _socket?.off('syncEstado');
    _socket?.off('syncMorte');
    _socket?.off('erroFila');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    if (clearMatch) lastMatchPayload = null;
  }

  void dispose() {
    disconnect();
    _loadingController.close();
    _matchReadyController.close();
    _errorController.close();
    _connectionController.close();
    _syncController.close();
    _deathController.close();
  }
}
