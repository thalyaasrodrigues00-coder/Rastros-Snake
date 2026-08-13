import 'package:flutter/material.dart';

class RenderCulling {
  static bool isVisible({
    required Offset position,
    required Offset cameraOffset,
    required Size screenSize,
    double margin = 100.0,
  }) {
    double screenLeft = cameraOffset.dx - margin;
    double screenRight = cameraOffset.dx + screenSize.width + margin;
    double screenTop = cameraOffset.dy - margin;
    double screenBottom = cameraOffset.dy + screenSize.height + margin;

    return position.dx >= screenLeft &&
        position.dx <= screenRight &&
        position.dy >= screenTop &&
        position.dy <= screenBottom;
  }

  static Size viewportWorldSize(Size screenSize, double zoom) {
    final safeZoom = zoom.clamp(0.1, 4.0);
    return Size(screenSize.width / safeZoom, screenSize.height / safeZoom);
  }
}
