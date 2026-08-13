class ServerConfig {
  /// ═══════════════════════════════════════════════════════════════
  /// PRODUÇÃO (mundo todo): cole a URL do Render após o deploy.
  /// Exemplo: https://rastros-snake.onrender.com
  /// ═══════════════════════════════════════════════════════════════
  static const String productionServerUrl = '';

  /// Rede local (testes na mesma Wi‑Fi). Usado se [productionServerUrl] estiver vazio.
  static const String _localHost = String.fromEnvironment(
    'SERVER_HOST',
    defaultValue: '192.168.15.9',
  );

  /// Override no build: --dart-define=SERVER_URL=https://seu-app.onrender.com
  static const String _buildServerUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: '',
  );

  static String get socketUrl {
    if (_buildServerUrl.isNotEmpty) return _buildServerUrl;
    if (productionServerUrl.isNotEmpty) return productionServerUrl;
    return 'http://$_localHost:3000';
  }

  static String get voiceSignalingUrl => '$socketUrl/voice';

  static bool get isProduction =>
      _buildServerUrl.isNotEmpty || productionServerUrl.isNotEmpty;
}
