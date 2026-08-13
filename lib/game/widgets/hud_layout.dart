/// Layout da HUD in-game (proporções baseadas na arena 9000×9000).
abstract class HudLayout {
  static const double mapSize = 180.0;
  static const double scoreboardWidth = 180.0;
  static const double scoreboardHeight = 300.0;
  static const double teamScoreboardWidth = 90.0;
  static const double teamScoreboardHeight = 200.0;
  static const double edgePadding = 12.0;
  static const double sideButtonSize = 20.0;
  static const double sideButtonGap = 8.0;
  static const double joystickSize = 130.0;
  static const double joystickRadius = 55.0;

  static const List<int> teamColors = [
    0xFF00E5FF,
    0xFFFF007F,
    0xFFFFD700,
    0xFF39FF14,
    0xFFFF5722,
    0xFF9C27B0,
    0xFF3F51B5,
    0xFF00BCD4,
    0xFF8BC34A,
    0xFFE91E63,
  ];
}
