import 'package:flutter/material.dart';
import '../models/session_result.dart';
import '../models/quiz_settings.dart';
import '../services/session_store.dart';
import 'history_screen.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  List<SessionResult> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await SessionStore.loadAll();
    if (mounted) setState(() { _sessions = sessions; _loading = false; });
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('きろくをけす',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('すべてのきろくをけしますか？\nこの操作はもとに戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('けす',
                style: TextStyle(color: Colors.red, fontSize: 16)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await SessionStore.clearAll();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        title: const Text('セッション きろく',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          if (_sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'きろくをけす',
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _SessionCard(
                      session: _sessions[index],
                      number: _sessions.length - index,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HistoryScreen(
                            history: _sessions[index].history,
                            title: _sessionTitle(_sessions[index]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _sessionTitle(SessionResult s) {
    final m = s.startedAt.month;
    final d = s.startedAt.day;
    final h = s.startedAt.hour.toString().padLeft(2, '0');
    final min = s.startedAt.minute.toString().padLeft(2, '0');
    return '$m/$d $h:$min のきろく';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text('まだきろくがありません',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('れんしゅうすると ここにきろくされます',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionResult session;
  final int number;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = session;
    final accuracy = s.accuracy;
    final accuracyColor = accuracy >= 90
        ? Colors.green.shade600
        : accuracy >= 70
            ? Colors.orange.shade700
            : Colors.red.shade600;

    // 日時フォーマット
    final dt = s.startedAt;
    final dateStr =
        '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.shade50,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // セッション番号・日時
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$number',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                const SizedBox(height: 6),
                Text(dateStr,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600)),
                Text(timeStr,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(width: 16),
            // 設定サマリー
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingChips(session: s),
                  const SizedBox(height: 8),
                  // スコア
                  Row(
                    children: [
                      _ScoreItem(
                          icon: Icons.circle,
                          color: Colors.green,
                          label: '${s.correct}もん'),
                      const SizedBox(width: 8),
                      _ScoreItem(
                          icon: Icons.close,
                          color: Colors.red,
                          label: '${s.wrong}もん'),
                      const SizedBox(width: 8),
                      Text('/ ${s.total}もん',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 正解率
            Column(
              children: [
                Text(
                  '$accuracy%',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: accuracyColor,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingChips extends StatelessWidget {
  final SessionResult session;
  const _SettingChips({required this.session});

  @override
  Widget build(BuildContext context) {
    final ops = session.operations.map((o) => o.label).join('');
    return Wrap(
      spacing: 4,
      children: [
        _Chip(ops, Colors.orange.shade100, Colors.orange.shade700),
        _Chip(session.digits.label, Colors.blue.shade100, Colors.blue.shade700),
        _Chip(session.timeLimit.label, Colors.green.shade100,
            Colors.green.shade700),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.bold)),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _ScoreItem(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 2),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}
