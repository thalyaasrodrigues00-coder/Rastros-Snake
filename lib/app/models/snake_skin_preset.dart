import 'package:flutter/material.dart';

class SnakeSkinPreset {
  final String name;
  final List<Color> colors;

  const SnakeSkinPreset({
    required this.name,
    required this.colors,
  });

  Color get primaryColor => colors.first;
}

abstract class SnakeSkinPresets {
  static const List<SnakeSkinPreset> all = [
    SnakeSkinPreset(name: 'Rosa e Roxo', colors: [Color(0xFFEC4899), Color(0xFFA855F7)]),
    SnakeSkinPreset(name: 'Rosa e Preto', colors: [Color(0xFFF472B6), Color(0xFF111827)]),
    SnakeSkinPreset(name: 'Azul e Amarelo', colors: [Color(0xFF3B82F6), Color(0xFFFACC15)]),
    SnakeSkinPreset(name: 'Cinza e Preto', colors: [Color(0xFF9CA3AF), Color(0xFF111827)]),
    SnakeSkinPreset(name: 'Cinza e Azul', colors: [Color(0xFF6B7280), Color(0xFF2563EB)]),
    SnakeSkinPreset(name: 'Preto e Azul', colors: [Color(0xFF0F172A), Color(0xFF38BDF8)]),
    SnakeSkinPreset(name: 'Verde e Azul', colors: [Color(0xFF22C55E), Color(0xFF3B82F6)]),
    SnakeSkinPreset(name: 'Verde, Amarelo e Azul', colors: [Color(0xFF22C55E), Color(0xFFFACC15), Color(0xFF3B82F6)]),
    SnakeSkinPreset(name: 'Vermelho e Preto', colors: [Color(0xFFEF4444), Color(0xFF111827)]),
    SnakeSkinPreset(name: 'Preto e Branco', colors: [Color(0xFF1F2937), Color(0xFFF9FAFB)]),
  ];
}
