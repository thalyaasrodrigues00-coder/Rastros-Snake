import 'package:flutter/material.dart';

class Boundary {
  final double width;
  final double height;

  Boundary({
    required this.width,
    required this.height,
  });

  // Garante que a cabeça da cobra não saia dos limites do mapa (deslize na parede)
  Offset clampPosition(Offset position, double radius) {
    double clampedX = position.dx.clamp(radius, width - radius);
    double clampedY = position.dy.clamp(radius, height - radius);
    return Offset(clampedX, clampedY);
  }

  bool isOutOfBounds(Offset position, double radius) {
    return position.dx - radius < 0 ||
        position.dx + radius > width ||
        position.dy - radius < 0 ||
        position.dy + radius > height;
  }
}
