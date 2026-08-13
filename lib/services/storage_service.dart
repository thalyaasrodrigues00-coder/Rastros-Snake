import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyNickname = 'player_nickname';
  static const String _keySoloHighScore = 'solo_high_score';
  static const String _keyTeamHighScore = 'team_high_score';
  static const String _keySnakeColorIndex = 'snake_color_index';

  static const String _legacyHighScoreKey = 'high_score';
  static const String _legacySkinIndexKey = 'selected_skin_index';

  static Future<void> _migrateLegacyPrefs(SharedPreferences prefs) async {
    if (!prefs.containsKey(_keySoloHighScore) && prefs.containsKey(_legacyHighScoreKey)) {
      await prefs.setInt(_keySoloHighScore, prefs.getInt(_legacyHighScoreKey) ?? 0);
    }
    if (!prefs.containsKey(_keySnakeColorIndex) && prefs.containsKey(_legacySkinIndexKey)) {
      await prefs.setInt(_keySnakeColorIndex, prefs.getInt(_legacySkinIndexKey) ?? 0);
    }
  }

  static Future<void> saveNickname(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, name);
  }

  static Future<String> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyPrefs(prefs);
    return prefs.getString(_keyNickname) ?? '';
  }

  static Future<void> saveSoloHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keySoloHighScore) ?? 0;
    if (score > current) await prefs.setInt(_keySoloHighScore, score);
  }

  static Future<int> getSoloHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyPrefs(prefs);
    return prefs.getInt(_keySoloHighScore) ?? 0;
  }

  static Future<void> saveTeamHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyTeamHighScore) ?? 0;
    if (score > current) await prefs.setInt(_keyTeamHighScore, score);
  }

  static Future<int> getTeamHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTeamHighScore) ?? 0;
  }

  static Future<void> saveSnakeColorIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySnakeColorIndex, index);
    await prefs.setInt(_legacySkinIndexKey, index);
  }

  static Future<int> getSnakeColorIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyPrefs(prefs);
    return prefs.getInt(_keySnakeColorIndex) ?? 0;
  }
}
