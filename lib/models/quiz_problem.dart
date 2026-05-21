import 'dart:math';
import 'quiz_settings.dart';

class QuizProblem {
  final int left;
  final int right;
  final Operation operation;
  final int answer;

  const QuizProblem({
    required this.left,
    required this.right,
    required this.operation,
    required this.answer,
  });

  String get symbol {
    switch (operation) {
      case Operation.add:
        return '＋';
      case Operation.subtract:
        return '－';
      case Operation.multiply:
        return '×';
      case Operation.divide:
        return '÷';
    }
  }

  static QuizProblem generate(QuizSettings settings, Random random) {
    final operation = settings.operations
        .elementAt(random.nextInt(settings.operations.length));
    final lMin = settings.leftDigits.min;
    final lMax = settings.leftDigits.max;
    final rMin = settings.rightDigits.min;
    final rMax = settings.rightDigits.max;

    int left, right, answer;

    switch (operation) {
      case Operation.add:
        left = _rand(random, lMin, lMax);
        right = _rand(random, rMin, rMax);
        answer = left + right;
        break;
      case Operation.subtract:
        left = _rand(random, lMin, lMax);
        right = _rand(random, rMin, rMax);
        if (left < right) {
          final tmp = left;
          left = right;
          right = tmp;
        }
        answer = left - right;
        break;
      case Operation.multiply:
        left = _rand(random, lMin, lMax);
        right = _rand(random, rMin, rMax);
        answer = left * right;
        break;
      case Operation.divide:
        // 割り切れる問題のみ生成
        right = _rand(random, rMin, rMax);
        final maxAnswer = (lMax / right).floor().clamp(1, 999);
        answer = _rand(random, 1, maxAnswer);
        left = right * answer;
        break;
    }

    return QuizProblem(
      left: left,
      right: right,
      operation: operation,
      answer: answer,
    );
  }

  static int _rand(Random random, int min, int max) {
    if (min >= max) return min;
    return random.nextInt(max - min + 1) + min;
  }
}
