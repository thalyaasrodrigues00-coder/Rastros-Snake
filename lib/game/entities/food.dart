import 'package:flutter/material.dart';

class Food {
  final int id;
  Offset position;
  Color color;
  double value;
  double radius;
  bool isActive;
  bool isBeingEaten;
  Offset? targetHeadPosition;

  Food({
    required this.id,
    required this.position,
    required this.color,
    this.value = 1.0,
    this.radius = 6.0,
    this.isActive = true,
    this.isBeingEaten = false,
    this.targetHeadPosition,
  });

  void reset({
    required Offset newPosition,
    required Color newColor,
    double newValue = 1.0,
    double newRadius = 6.0,
  }) {
    position = newPosition;
    color = newColor;
    value = newValue;
    radius = newRadius;
    isActive = true;
    isBeingEaten = false;
    targetHeadPosition = null;
  }
}
