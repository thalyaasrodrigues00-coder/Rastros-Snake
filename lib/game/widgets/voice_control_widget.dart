import 'package:flutter/material.dart';

class VoiceControlWidget extends StatefulWidget {
  final int teamId;

  const VoiceControlWidget({super.key, required this.teamId});

  @override
  State<VoiceControlWidget> createState() => _VoiceControlWidgetState();
}

class _VoiceControlWidgetState extends State<VoiceControlWidget> {
  bool _isMuted = false;
  bool _isSpeakerMuted = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 15,
      top: 120,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isMuted = !_isMuted),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isMuted ? Colors.redAccent : const Color(0xFF00E5FF),
                ),
              ),
              child: Icon(
                _isMuted ? Icons.mic_off : Icons.mic,
                color: _isMuted ? Colors.redAccent : const Color(0xFF00E5FF),
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _isSpeakerMuted = !_isSpeakerMuted),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isSpeakerMuted ? Colors.redAccent : const Color(0xFF00E5FF),
                ),
              ),
              child: Icon(
                _isSpeakerMuted ? Icons.volume_off : Icons.volume_up,
                color: _isSpeakerMuted ? Colors.redAccent : const Color(0xFF00E5FF),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
