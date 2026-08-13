import 'package:flutter/material.dart';

import 'hud_layout.dart';

class TeamMapControlsWidget extends StatefulWidget {
  final VoidCallback onHome;
  final ValueChanged<bool>? onMicToggle;
  final ValueChanged<bool>? onSpeakerToggle;

  const TeamMapControlsWidget({
    super.key,
    required this.onHome,
    this.onMicToggle,
    this.onSpeakerToggle,
  });

  @override
  State<TeamMapControlsWidget> createState() => _TeamMapControlsWidgetState();
}

class _TeamMapControlsWidgetState extends State<TeamMapControlsWidget> {
  bool _micMuted = false;
  bool _speakerMuted = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: HudLayout.edgePadding,
      left: HudLayout.edgePadding + HudLayout.mapSize + HudLayout.sideButtonGap,
      child: Column(
        children: [
          _MapSideButton(
            icon: Icons.mic,
            activeIcon: Icons.mic_off,
            tooltip: 'Microfone',
            isActive: _micMuted,
            onTap: () {
              setState(() => _micMuted = !_micMuted);
              widget.onMicToggle?.call(_micMuted);
            },
          ),
          SizedBox(height: HudLayout.sideButtonGap),
          _MapSideButton(
            icon: Icons.volume_up,
            activeIcon: Icons.volume_off,
            tooltip: 'Silenciar equipe',
            isActive: _speakerMuted,
            onTap: () {
              setState(() => _speakerMuted = !_speakerMuted);
              widget.onSpeakerToggle?.call(_speakerMuted);
            },
          ),
          SizedBox(height: HudLayout.sideButtonGap),
          _MapSideButton(
            icon: Icons.home_rounded,
            onTap: widget.onHome,
            tooltip: 'Voltar ao menu',
          ),
        ],
      ),
    );
  }
}

class _MapSideButton extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final VoidCallback? onTap;
  final String tooltip;
  final bool isActive;

  const _MapSideButton({
    required this.icon,
    this.activeIcon,
    this.onTap,
    required this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = HudLayout.sideButtonSize;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.redAccent : const Color(0xFF00E5FF),
            ),
          ),
          child: Icon(
            isActive && activeIcon != null ? activeIcon : icon,
            size: 12,
            color: isActive ? Colors.redAccent : const Color(0xFF00E5FF),
          ),
        ),
      ),
    );
  }
}
