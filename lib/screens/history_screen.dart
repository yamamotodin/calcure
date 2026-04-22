import 'package:flutter/material.dart';
import '../models/problem_result.dart';

class HistoryScreen extends StatelessWidget {
  final List<ProblemResult> history;
  final String title;

  const HistoryScreen({
    super.key,
    required this.history,
    this.title = 'といあわせ けっか',
  });

  @override
  Widget build(BuildContext context) {
    final correctCount = history.where((r) => r.isCorrect).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── サマリーバー ──
          Container(
            color: const Color(0xFF6A1B9A),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryChip(
                  label: 'ぜんぶ',
                  value: '${history.length}もん',
                  color: Colors.white,
                  textColor: const Color(0xFF6A1B9A),
                ),
                _SummaryChip(
                  label: 'せいかい',
                  value: '$correctCountもん',
                  color: Colors.green.shade400,
                  textColor: Colors.white,
                ),
                _SummaryChip(
                  label: 'まちがい',
                  value: '${history.length - correctCount}もん',
                  color: Colors.red.shade400,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
          // ── 問題リスト ──
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'まだきろくがありません',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final result = history[index];
                      return _ProblemCard(
                        number: index + 1,
                        result: result,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.8),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final int number;
  final ProblemResult result;

  const _ProblemCard({required this.number, required this.result});

  @override
  Widget build(BuildContext context) {
    final p = result.problem;
    final isCorrect = result.isCorrect;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 問題番号
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 問題文
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.left} ${p.symbol} ${p.right} ＝',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // ユーザーの答え
                    _AnswerBubble(
                      label: 'こたえ',
                      value: '${result.userAnswer}',
                      color: isCorrect
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      textColor: isCorrect
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      // 正解
                      _AnswerBubble(
                        label: 'せいかい',
                        value: '${p.answer}',
                        color: Colors.blue.shade50,
                        textColor: Colors.blue.shade700,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 正誤アイコン
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerBubble extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  const _AnswerBubble({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label：',
            style: TextStyle(
                fontSize: 12, color: textColor.withOpacity(0.8)),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor),
          ),
        ],
      ),
    );
  }
}
