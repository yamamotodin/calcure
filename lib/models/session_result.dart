import 'dart:convert';
import 'quiz_settings.dart';
import 'quiz_problem.dart';
import 'problem_result.dart';

class SessionResult {
  final String id;
  final DateTime startedAt;
  final int correct;
  final int wrong;
  final int total;
  final Set<Operation> operations;
  final Digits digits;
  final TimeLimitOption timeLimit;
  final List<ProblemResult> history;

  SessionResult({
    required this.id,
    required this.startedAt,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.operations,
    required this.digits,
    required this.timeLimit,
    required this.history,
  });

  int get accuracy => total > 0 ? (correct / total * 100).round() : 0;

  factory SessionResult.fromQuiz({
    required int correct,
    required int wrong,
    required int total,
    required QuizSettings settings,
    required List<ProblemResult> history,
  }) {
    return SessionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: DateTime.now(),
      correct: correct,
      wrong: wrong,
      total: total,
      operations: settings.operations,
      digits: settings.digits,
      timeLimit: settings.timeLimit,
      history: history,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'correct': correct,
        'wrong': wrong,
        'total': total,
        'operations': operations.map((o) => o.index).toList(),
        'digits': digits.index,
        'timeLimit': timeLimit.index,
        'history': history
            .map((r) => {
                  'left': r.problem.left,
                  'right': r.problem.right,
                  'operation': r.problem.operation.index,
                  'answer': r.problem.answer,
                  'userAnswer': r.userAnswer,
                  'isCorrect': r.isCorrect,
                })
            .toList(),
      };

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    final ops = (json['operations'] as List)
        .map((i) => Operation.values[i as int])
        .toSet();
    final historyJson = json['history'] as List;
    final history = historyJson.map((h) {
      final op = Operation.values[h['operation'] as int];
      final problem = QuizProblem(
        left: h['left'] as int,
        right: h['right'] as int,
        operation: op,
        answer: h['answer'] as int,
      );
      return ProblemResult(
        problem: problem,
        userAnswer: h['userAnswer'] as int,
        isCorrect: h['isCorrect'] as bool,
      );
    }).toList();

    return SessionResult(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      correct: json['correct'] as int,
      wrong: json['wrong'] as int,
      total: json['total'] as int,
      operations: ops,
      digits: Digits.values[json['digits'] as int],
      timeLimit: TimeLimitOption.values[json['timeLimit'] as int],
      history: history,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static SessionResult fromJsonString(String s) =>
      SessionResult.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
