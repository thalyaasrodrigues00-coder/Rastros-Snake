class AdService {
  static int _soloGameOverCount = 0;

  static void handleGameOver(bool isTeamMode, Function onShowAd) {
    if (isTeamMode) return;

    _soloGameOverCount++;
    if (_soloGameOverCount >= 5) {
      _soloGameOverCount = 0;
      onShowAd();
    }
  }
}
