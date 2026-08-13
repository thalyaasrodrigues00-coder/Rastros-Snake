import 'package:flutter/material.dart';

class BoostButtonController {
  bool isBoosting = false;
  DateTime? _lastTapTime;

  void onPressDown() {
    isBoosting = true;
  }

  void onPressUp() {
    isBoosting = false;
  }

  // Suporte a toque duplo para ativar o impulso
  bool handleDoubleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      isBoosting = !isBoosting;
      _lastTapTime = null;
      return isBoosting;
    }
    _lastTapTime = now;
    return isBoosting;
  }
}
