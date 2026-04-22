import 'package:flutter/material.dart';
import '../models/quiz_settings.dart';
import '../models/problem_result.dart';
import '../models/session_result.dart';
import '../services/session_store.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';
import 'history_screen.dart';

class ResultScreen extends StatefulWidget {
  final int correct;
  final int wrong;
  final int total;
  final QuizSettings settings;
  final List<ProblemResult> history;

  const ResultScreen({
    super.key,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.settings,
    required this.history,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveSession();
  }

  Future<void> _saveSession() async {
    final session = SessionResult.fromQuiz(
      correct: widget.correct,
      wrong: widget.wrong,
      total: widget.total,
      settings: widget.settings,
      history: widget.history,
    );
    await SessionStore.add(session);
  }

  String get _emoji {
    if (widget.total == 0) return '😅';
    final pct = widget.correct / widget.total * 100;
    if (pct >= 90) return '🎉';
    if (pct >= 70) return '😊';
    if (pct >= 50) return '🤔';
    return '😅';
  }

  String get _message {
    if (widget.total == 0) return 'がんばろう！';
    final pct = widget.correct / widget.total * 100;
    if (pct >= 90) return 'すごい！';
    if (pct >= 70) return 'よくできました！';
    if (pct >= 50) return 'もうすこし！';
    return 'がんばろう！';
  }

  @override
  Widget build(BuildContext context) {
    final accuracy =
        widget.total > 0 ? (widget.correct / widget.total * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_emoji,
                  style: const TextStyle(fontSize: 80),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                _message,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade100,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _Row(label: 'もんだいすう', value: '${widget.total} もん'),
                    _Divider(),
                    _Row(
                        label: 'せいかい',
                        value: '${widget.correct} もん',
                        valueColor: Colors.green.shade600),
                    _Divider(),
                    _Row(
                        label: 'まちがい',
                        value: '${widget.wrong} もん',
                        valueColor: Colors.red.shade600),
                    _Divider(),
                    _Row(
                      label: 'せいかいりつ',
                      value: '$accuracy ％',
                      valueColor: Colors.orange.shade700,
                      large: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HistoryScreen(history: widget.history),
                  ),
                ),
                icon: const Icon(Icons.list_alt),
                label: const Text('といあわせ けっかをみる',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6A1B9A),
                  side: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) =>
                          QuizScreen(settings: widget.settings)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                ),
                child: const Text('もういちど',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6A1B9A),
                  side: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('せってい にもどる',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool large;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: large ? 20 : 16, color: Colors.grey.shade600)),
          Text(value,
              style: TextStyle(
                fontSize: large ? 30 : 22,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              )),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.grey.shade200, height: 1);
  }
}
