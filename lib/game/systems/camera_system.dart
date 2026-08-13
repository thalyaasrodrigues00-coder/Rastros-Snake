import 'dart:ui';
import 'package:flutter/material.dart';

class CameraSystem {
  Offset cameraOffset = Offset.zero;
  double currentZoom = 1.0;
  double targetZoom = 1.0;

  // Atualiza a posição da câmera e calcula o zoom dinâmico
  Offset updateCamera({
    required Offset playerHeadPosition,
    required double playerScore,
    required Size screenSize,
    required double dt,
  }) {
    // 1. Posição ideal da câmera (Centraliza a cabeça da cobra na tela)
    Offset targetOffset = playerHeadPosition - Offset(screenSize.width / 2, screenSize.height / 2);

    // Perseguição suave da câmera (Interpolação Linear)
    cameraOffset = Offset(
      lerpDouble(cameraOffset.dx, targetOffset.dx, dt * 5.0) ?? targetOffset.dx,
      lerpDouble(cameraOffset.dy, targetOffset.dy, dt * 5.0) ?? targetOffset.dy,
    );

    // 2. Zoom Dinâmico baseado no tamanho/massa da cobra
    // Quanto maior a cobra, menor o valor do zoom para afastar a câmera
    targetZoom = (1.0 - (playerScore / 2000.0)).clamp(0.55, 1.0);
    currentZoom = lerpDouble(currentZoom, targetZoom, dt * 2.0) ?? targetZoom;

    return cameraOffset;
  }
}
