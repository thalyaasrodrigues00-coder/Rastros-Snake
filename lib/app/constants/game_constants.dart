abstract class GameConstants {
  // Arena 9000×9000
  static const double worldWidth = 9000.0;
  static const double worldHeight = 9000.0;

  static const int totalStars = 1000;
  static const int totalCrystals = 50;
  static const int totalPlayersInMatch = 50;
  static const int playersPerTeam = 5;

  // Cobras e População
  static const int totalSnakes = 50;
  static const int totalFoodPellets = 1000;
  static const int maxFoodCount = 4000;
  static const int totalTunnels = 6;

  // Dimensões da Cobra
  static const double initialSnakeRadius = 16.0;
  static const double segmentSpacing = 6.0;
  static const int initialSegmentCount = 10;

  // Velocidades
  static const double baseSpeed = 180.0; // pixels por segundo
  static const double boostSpeedMultiplier = 1.8;
  static const double rotationSpeed = 5.0; // radianos por segundo

  // Mecânicas
  static const double foodMagnetRadius = 120.0;
  static const double tunnelCooldownSeconds = 1.5;
  static const double minTunnelDistance = 300.0;

  // Mapeia coordenadas em setores (grid 5x5: A1 até E5)
  static String getSectorName(double x, double y) {
    final col = ((x / worldWidth) * 5).clamp(0, 4).toInt();
    final row = ((y / worldHeight) * 5).clamp(0, 4).toInt();
    const columns = ['A', 'B', 'C', 'D', 'E'];
    return 'Setor ${columns[col]}${row + 1}';
  }
}
