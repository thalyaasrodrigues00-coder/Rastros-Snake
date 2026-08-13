import '../../services/storage_service.dart';

class SettingsService {
  Future<int> getSelectedSkinIndex() => StorageService.getSnakeColorIndex();

  Future<void> saveSelectedSkinIndex(int index) => StorageService.saveSnakeColorIndex(index);

  Future<String> getNickname() async {
    final nickname = await StorageService.getNickname();
    return nickname.isEmpty ? 'Jogador' : nickname;
  }

  Future<void> saveNickname(String nickname) => StorageService.saveNickname(nickname);

  Future<int> getHighScore() => StorageService.getSoloHighScore();

  Future<int> getTeamHighScore() => StorageService.getTeamHighScore();

  Future<int> updateHighScore(int score) async {
    await StorageService.saveSoloHighScore(score);
    return StorageService.getSoloHighScore();
  }

  Future<int> updateTeamHighScore(int score) async {
    await StorageService.saveTeamHighScore(score);
    return StorageService.getTeamHighScore();
  }
}
