import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool isMuted = false;
  bool _menuBgmPlaying = false;

  Future<void> _safePlay(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }

  Future<void> playMenuBgm() async {
    if (isMuted || _menuBgmPlaying) return;
    await _safePlay(() async {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('audio/bgm_menu.wav'), volume: 0.35);
      _menuBgmPlaying = true;
    });
  }

  Future<void> pauseMenuBgm() async {
    await _bgmPlayer.pause();
    _menuBgmPlaying = false;
  }

  Future<void> resumeMenuBgm() async {
    if (isMuted) return;
    if (_menuBgmPlaying) {
      await _bgmPlayer.resume();
    } else {
      await playMenuBgm();
    }
  }

  Future<void> stopMenuBgm() async {
    await _bgmPlayer.stop();
    _menuBgmPlaying = false;
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      _bgmPlayer.setVolume(0);
    } else if (_menuBgmPlaying) {
      _bgmPlayer.setVolume(0.35);
    }
  }

  Future<void> playEatSound() async {
    if (isMuted) return;
    await _safePlay(() => _sfxPlayer.play(AssetSource('audio/sfx_click.wav'), volume: 0.45));
  }

  Future<void> playCollisionSound() async {
    if (isMuted) return;
    await _safePlay(() => _sfxPlayer.play(AssetSource('audio/sfx_click.wav'), volume: 0.7));
  }

  Future<void> playTunnelSound() async {
    if (isMuted) return;
    await _safePlay(() => _sfxPlayer.play(AssetSource('audio/sfx_click.wav'), volume: 0.55));
  }

  Future<void> playBoostSound() async {
    if (isMuted) return;
    await _safePlay(() => _sfxPlayer.play(AssetSource('audio/sfx_boost.wav'), volume: 0.35));
  }

  Future<void> playGameOverSound() async {
    if (isMuted) return;
    await _safePlay(() => _sfxPlayer.play(AssetSource('audio/sfx_boost.wav'), volume: 0.85));
  }
}
