import '../entities/snake.dart';

class CrownSystem {
  // Atualiza qual cobra recebe a coroa de Rei/Rainha e retorna o ranking ordenado
  List<Snake> updateCrownAndRankings(List<Snake> allSnakes) {
    // Filtra apenas cobras vivas
    List<Snake> activeSnakes = allSnakes.where((s) => s.isAlive).toList();

    if (activeSnakes.isEmpty) return [];

    // Ordena do maior score para o menor
    activeSnakes.sort((a, b) => b.score.compareTo(a.score));

    // Reseta a coroa de todas as cobras
    for (final snake in allSnakes) {
      snake.hasCrown = false;
    }

    // Atribui a coroa ao 1º lugar
    activeSnakes.first.hasCrown = true;

    return activeSnakes;
  }
}
