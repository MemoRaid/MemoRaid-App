import '../features/g_01_task_step.dart';
import 'dart:math';

class Shuffler {
  static List<TaskStep> ShuffleSteps(List<TaskStep> steps) {
    final random = Random();
    final List<TaskStep> shuffled = List.from(steps);
  }

  for (int i = shuffled.length - 1; i > 0; i--) {
    final int n = random.nextInt(i + 1);
    final TaskStep temp = shuffled[i];
    shuffled[i] = shuffled[n];
    shuffled[n] = temp;
  }
  return shuffled;
} 
