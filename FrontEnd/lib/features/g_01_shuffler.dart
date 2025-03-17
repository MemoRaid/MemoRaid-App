import '../features/g_01_task_step.dart';
import 'dart:math';

class Shuffler {
  static List<TaskStep> shuffleSteps(List<TaskStep> steps) {
    final random = Random();
    final List<TaskStep> shuffled = List.from(steps);

    // Fisher-Yates shuffle algorithm
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    return shuffled;
  }
}
