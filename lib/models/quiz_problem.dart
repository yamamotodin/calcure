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
    final min = settings.digits.min;
    final max = settings.digits.max;

    int left, right, answer;

    switch (operation) {
      case Operation.add:
        left = _rand(random, min, max);
        right = _rand(random, min, max);
        answer = left + right;
        break;
      case Operation.subtract:
        left = _rand(random, min, max);
        right = _rand(random, min, max);
        if (left < right) {
          final tmp = left;
          left = right;
          right = tmp;
        }
        answer = left - right;
        break;
      case Operation.multiply:
        // 右辺は1〜9で固定（掛け算の桁が大きくなりすぎないように）
        left = _rand(random, min, max);
        right = _rand(random, 1, 9);
        answer = left * right;
        break;
      case Operation.divide:
        // 割り切れる問題のみ生成
        right = _rand(random, 1, 9);
        final maxAnswer = (max / right).floor().clamp(1, 999);
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
