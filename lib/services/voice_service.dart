import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  MediaStream? _localStream;
  bool isMuted = false;
  bool isSpeakerMuted = false;

  bool get isActive => _localStream != null;

  Future<bool> initialize() async {
    if (kIsWeb) return false;
    if (_localStream != null) return true;

    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  void setMuted(bool muted) {
    isMuted = muted;
    final tracks = _localStream?.getAudioTracks() ?? [];
    for (final track in tracks) {
      track.enabled = !muted;
    }
  }

  void setSpeakerMuted(bool muted) {
    isSpeakerMuted = muted;
  }

  void dispose() {
    final tracks = _localStream?.getTracks() ?? [];
    for (final track in tracks) {
      track.stop();
    }
    _localStream?.dispose();
    _localStream = null;
    isMuted = false;
    isSpeakerMuted = false;
  }
}
