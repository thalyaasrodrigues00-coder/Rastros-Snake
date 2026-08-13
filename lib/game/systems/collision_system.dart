import '../entities/food.dart';
import '../entities/snake.dart';

class CollisionSystem {
  List<Snake> checkSnakeCollisions(List<Snake> allSnakes) {
    final deadSnakes = <Snake>[];

    for (final snake in allSnakes) {
      if (!snake.isAlive || snake.isRemoteHuman) continue;

      for (final otherSnake in allSnakes) {
        if (!otherSnake.isAlive || snake.id == otherSnake.id) continue;

        if (snake.teamId >= 0 && snake.teamId == otherSnake.teamId) continue;

        bool snakeDied = false;

        for (final segment in otherSnake.segments) {
          final distance = (snake.head.position - segment.position).distance;
          if (distance < (snake.head.radius + segment.radius) * 0.75) {
            snake.isAlive = false;
            if (!otherSnake.isRemoteHuman) {
              otherSnake.eliminationCount++;
            }
            deadSnakes.add(snake);
            snakeDied = true;
            break;
          }
        }

        if (snakeDied) break;

        final headDistance = (snake.head.position - otherSnake.head.position).distance;
        if (headDistance < (snake.head.radius + otherSnake.head.radius) * 0.75) {
          snake.isAlive = false;
          otherSnake.isAlive = false;
          if (!otherSnake.isRemoteHuman) {
            otherSnake.eliminationCount++;
          }
          deadSnakes.add(snake);
          if (!deadSnakes.contains(otherSnake)) {
            deadSnakes.add(otherSnake);
          }
          break;
        }
      }
    }

    return deadSnakes.toSet().toList();
  }

  void convertDeadSnakeToFood(Snake deadSnake, List<Food> foodPool) {
    int foodIndex = 0;

    final positionsToConvert = [
      deadSnake.head.position,
      ...deadSnake.segments.map((s) => s.position),
    ];

    for (final pos in positionsToConvert) {
      while (foodIndex < foodPool.length && foodPool[foodIndex].isActive) {
        foodIndex++;
      }

      if (foodIndex < foodPool.length) {
        foodPool[foodIndex].reset(
          newPosition: pos,
          newColor: deadSnake.skinColor,
          newValue: 3.0,
          newRadius: 9.0,
        );
        foodIndex++;
      }
    }
  }
}
