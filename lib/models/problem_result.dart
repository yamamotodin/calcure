import 'quiz_problem.dart';

class ProblemResult {
  final QuizProblem problem;
  final int userAnswer;
  final bool isCorrect;

  const ProblemResult({
    required this.problem,
    required this.userAnswer,
    required this.isCorrect,
  });
}
