import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/quiz_settings.dart';
import '../models/quiz_problem.dart';
import '../models/problem_result.dart';
import 'result_screen.dart';

enum _Feedback { none, correct, wrong }

class QuizScreen extends StatefulWidget {
  final QuizSettings settings;
  const QuizScreen({super.key, required this.settings});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _random = Random();
  late QuizProblem _current;
  String _input = '';
  int _correct = 0;
  int _wrong = 0;
  int _total = 0;
  int? _remainingSeconds;
  Timer? _timer;
  _Feedback _feedback = _Feedback.none;
  final List<ProblemResult> _history = [];

  @override
  void initState() {
    super.initState();
    _current = QuizProblem.generate(widget.settings, _random);
    final limit = widget.settings.timeLimit.seconds;
    if (limit != null) {
      _remainingSeconds = limit;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remainingSeconds = _remainingSeconds! - 1);
      if (_remainingSeconds! <= 0) {
        t.cancel();
        _goToResult();
      }
    });
  }

  void _onNumber(String value) {
    if (_feedback != _Feedback.none) return;
    setState(() {
      if (_input.length < 6) _input += value;
    });
  }

  void _onDelete() {
    if (_feedback != _Feedback.none) return;
    setState(() {
      if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
    });
  }

  void _onSubmit() {
    if (_input.isEmpty || _feedback != _Feedback.none) return;
    final userAnswer = int.tryParse(_input);
    if (userAnswer == null) return;

    final isCorrect = userAnswer == _current.answer;
    setState(() {
      _feedback = isCorrect ? _Feedback.correct : _Feedback.wrong;
      _total++;
      if (isCorrect) { _correct++; } else { _wrong++; }
    });
    _history.add(ProblemResult(
      problem: _current,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
    ));

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final noTimer = widget.settings.timeLimit.seconds == null;
      if (noTimer && _total >= widget.settings.questionCount) {
        _goToResult();
        return;
      }
      setState(() {
        _feedback = _Feedback.none;
        _input = '';
        _current = QuizProblem.generate(widget.settings, _random);
      });
    });
  }

  void _goToResult() {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          correct: _correct,
          wrong: _wrong,
          total: _total,
          settings: widget.settings,
          history: List.unmodifiable(_history),
        ),
      ),
    );
  }

  void _showQuitDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('やめますか？',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (_remainingSeconds != null && _remainingSeconds! > 0) {
                _startTimer();
              }
            },
            child: const Text('つづける', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('やめる',
                style: TextStyle(color: Colors.red, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTimer = _remainingSeconds != null;
    final limitSeconds = widget.settings.timeLimit.seconds;

    Color answerBorderColor;
    Color answerBgColor;
    switch (_feedback) {
      case _Feedback.correct:
        answerBorderColor = Colors.green;
        answerBgColor = Colors.green.shade50;
        break;
      case _Feedback.wrong:
        answerBorderColor = Colors.red;
        answerBgColor = Colors.red.shade50;
        break;
      case _Feedback.none:
        answerBorderColor = Colors.blue.shade300;
        answerBgColor = Colors.white;
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            // ── トップバー ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: _showQuitDialog,
                  ),
                  const Spacer(),
                  _ScoreBadge(correct: _correct, wrong: _wrong),
                  const Spacer(),
                  if (hasTimer)
                    _TimerBadge(seconds: _remainingSeconds!)
                  else
                    Text(
                      '$_total / ${widget.settings.questionCount}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            // ── プログレスバー ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: hasTimer
                      ? _remainingSeconds! / limitSeconds!
                      : _total / widget.settings.questionCount,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  color: hasTimer
                      ? (_remainingSeconds! <= 10 ? Colors.red : Colors.blue)
                      : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── 問題エリア ──
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${_current.left} ${_current.symbol} ${_current.right} ＝',
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: const BoxConstraints(minWidth: 140),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 10),
                      decoration: BoxDecoration(
                        color: answerBgColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: answerBorderColor, width: 3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _input.isEmpty ? '？' : _input,
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: _input.isEmpty
                                  ? Colors.grey.shade400
                                  : answerBorderColor,
                            ),
                          ),
                          if (_feedback == _Feedback.correct)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.check_circle,
                                  color: Colors.green, size: 36),
                            ),
                          if (_feedback == _Feedback.wrong)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.cancel,
                                  color: Colors.red, size: 36),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── 数字パッド ──
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _NumberPad(
                  onNumber: _onNumber,
                  onDelete: _onDelete,
                  onSubmit: _onSubmit,
                  canSubmit:
                      _input.isNotEmpty && _feedback == _Feedback.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ウィジェット群 ────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  final int correct;
  final int wrong;
  const _ScoreBadge({required this.correct, required this.wrong});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Badge(
          color: Colors.green.shade100,
          icon: Icons.circle,
          iconColor: Colors.green,
          text: '$correct',
          textColor: Colors.green.shade700,
        ),
        const SizedBox(width: 8),
        _Badge(
          color: Colors.red.shade100,
          icon: Icons.close,
          iconColor: Colors.red,
          text: '$wrong',
          textColor: Colors.red.shade700,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;

  const _Badge({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
        ],
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final int seconds;
  const _TimerBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final isLow = seconds <= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer,
              color: isLow ? Colors.red : Colors.blue.shade700, size: 22),
          const SizedBox(width: 4),
          Text(
            '$seconds',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isLow ? Colors.red : Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final void Function(String) onNumber;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;
  final bool canSubmit;

  const _NumberPad({
    required this.onNumber,
    required this.onDelete,
    required this.onSubmit,
    required this.canSubmit,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    return Column(
      children: [
        Expanded(child: _row(['1', '2', '3'], gap)),
        const SizedBox(height: gap),
        Expanded(child: _row(['4', '5', '6'], gap)),
        const SizedBox(height: gap),
        Expanded(child: _row(['7', '8', '9'], gap)),
        const SizedBox(height: gap),
        // 最下行：⌫ ／ 0 ／ こたえる
        Expanded(
          child: Row(
            children: [
              Expanded(child: _DeleteBtn(onDelete: onDelete)),
              const SizedBox(width: gap),
              Expanded(child: _NumBtn(label: '0', onTap: () => onNumber('0'))),
              const SizedBox(width: gap),
              Expanded(
                child: _SubmitBtn(onSubmit: onSubmit, canSubmit: canSubmit),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(List<String> labels, double gap) {
    return Row(
      children: List.generate(labels.length, (i) {
        final label = labels[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : gap),
            child: label == '⌫'
                ? _DeleteBtn(onDelete: onDelete)
                : _NumBtn(label: label, onTap: () => onNumber(label)),
          ),
        );
      }),
    );
  }
}

class _NumBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NumBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteBtn extends StatelessWidget {
  final VoidCallback onDelete;
  const _DeleteBtn({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(18),
        child: const Center(
          child: Icon(Icons.backspace_outlined,
              size: 30, color: Colors.red),
        ),
      ),
    );
  }
}

class _SubmitBtn extends StatelessWidget {
  final VoidCallback onSubmit;
  final bool canSubmit;
  const _SubmitBtn({required this.onSubmit, required this.canSubmit});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: canSubmit ? const Color(0xFFE65100) : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(18),
      elevation: canSubmit ? 3 : 0,
      child: InkWell(
        onTap: canSubmit ? onSubmit : null,
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: Text(
            'こたえる',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: canSubmit ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }
}
