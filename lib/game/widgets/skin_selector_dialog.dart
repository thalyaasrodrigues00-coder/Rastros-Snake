import 'package:flutter/material.dart';

class SkinSelectorDialog extends StatelessWidget {
  final Function(Color) onSelectColor;

  const SkinSelectorDialog({super.key, required this.onSelectColor});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.cyan,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.amber,
      Colors.pinkAccent,
    ];

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('Escolha sua Skin', style: TextStyle(color: Colors.white)),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colors
            .map((color) => GestureDetector(
                  onTap: () {
                    onSelectColor(color);
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(backgroundColor: color, radius: 24),
                ))
            .toList(),
      ),
    );
  }
}
