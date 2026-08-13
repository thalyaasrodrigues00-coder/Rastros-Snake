import 'dart:math';

import 'package:flutter/material.dart';

import 'hud_layout.dart';

class GameJoystickWidget extends StatefulWidget {
  final ValueChanged<double?> onAngleChanged;
  final ValueChanged<bool> onBoostChanged;
  final bool enabled;

  const GameJoystickWidget({
    super.key,
    required this.onAngleChanged,
    required this.onBoostChanged,
    this.enabled = true,
  });

  @override
  State<GameJoystickWidget> createState() => _GameJoystickWidgetState();
}

class _GameJoystickWidgetState extends State<GameJoystickWidget> {
  Offset _knob = Offset.zero;
  double _speedRatio = 0.0;

  void _updateKnob(Offset local, Size size) {
    if (!widget.enabled) return;
    final center = Offset(size.width / 2, size.height / 2);
    final delta = local - center;
    final maxR = HudLayout.joystickRadius;
    final distance = delta.distance.clamp(0.0, maxR);
    final direction = delta.distance == 0 ? Offset.zero : delta / delta.distance;
    final clamped = direction * distance;

    setState(() {
      _knob = clamped;
      _speedRatio = distance / maxR;
    });

    if (distance > 4) {
      widget.onAngleChanged(atan2(clamped.dy, clamped.dx));
      widget.onBoostChanged(_speedRatio > 0.85);
    } else {
      widget.onAngleChanged(null);
      widget.onBoostChanged(false);
    }
  }

  void _resetKnob() {
    setState(() {
      _knob = Offset.zero;
      _speedRatio = 0.0;
    });
    widget.onAngleChanged(null);
    widget.onBoostChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: HudLayout.edgePadding,
      bottom: HudLayout.edgePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: HudLayout.joystickSize,
            height: HudLayout.joystickSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.55),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.7), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final center = Offset(size.width / 2, size.height / 2);
                return GestureDetector(
                  onPanStart: (d) => _updateKnob(d.localPosition, size),
                  onPanUpdate: (d) => _updateKnob(d.localPosition, size),
                  onPanEnd: (_) => _resetKnob(),
                  onPanCancel: _resetKnob,
                  child: CustomPaint(
                    size: size,
                    painter: _JoystickPainter(
                      knobCenter: center + _knob,
                      baseCenter: center,
                      radius: HudLayout.joystickRadius,
                      speedRatio: _speedRatio,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Velocidade: ${(_speedRatio * 100).toInt()}%',
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_speedRatio > 0.85)
            const Text(
              'TURBO',
              style: TextStyle(color: Color(0xFFFF0055), fontSize: 10, fontWeight: FontWeight.w900),
            ),
        ],
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset knobCenter;
  final Offset baseCenter;
  final double radius;
  final double speedRatio;

  _JoystickPainter({
    required this.knobCenter,
    required this.baseCenter,
    required this.radius,
    required this.speedRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      baseCenter,
      radius,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final knobPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(const Color(0xFF00E5FF), const Color(0xFFFF0055), speedRatio)!,
          Colors.white24,
        ],
      ).createShader(Rect.fromCircle(center: knobCenter, radius: 22));

    canvas.drawCircle(knobCenter, 22, knobPaint);
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) {
    return oldDelegate.knobCenter != knobCenter || oldDelegate.speedRatio != speedRatio;
  }
}
