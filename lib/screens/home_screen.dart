import 'package:flutter/material.dart';
import '../models/quiz_settings.dart';
import 'quiz_screen.dart';
import 'session_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<Operation> _selectedOps = {Operation.add};
  Digits _digits = Digits.one;
  TimeLimitOption _timeLimit = TimeLimitOption.sixty;

  void _toggleOperation(Operation op) {
    setState(() {
      if (_selectedOps.contains(op)) {
        if (_selectedOps.length > 1) _selectedOps.remove(op);
      } else {
        _selectedOps.add(op);
      }
    });
  }

  void _start() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => QuizScreen(
        settings: QuizSettings(
          operations: Set.from(_selectedOps),
          digits: _digits,
          timeLimit: _timeLimit,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFFE65100)),
            tooltip: 'きろく',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const SessionListScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text(
                'けいさん\nれんしゅう',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _SectionCard(
                title: 'けいさんのしゅるい',
                color: Colors.orange.shade50,
                borderColor: Colors.orange.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: Operation.values.map((op) {
                    final selected = _selectedOps.contains(op);
                    return GestureDetector(
                      onTap: () => _toggleOperation(op),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.orange.shade400
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.orange.shade400,
                            width: 2.5,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Colors.orange.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            op.label,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : Colors.orange.shade400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'けたすう',
                color: Colors.blue.shade50,
                borderColor: Colors.blue.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: Digits.values.map((d) {
                    final selected = _digits == d;
                    return GestureDetector(
                      onTap: () => setState(() => _digits = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.blue.shade400
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.blue.shade400, width: 2.5),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          d.label,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : Colors.blue.shade400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'せいげんじかん',
                color: Colors.green.shade50,
                borderColor: Colors.green.shade200,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: TimeLimitOption.values.map((t) {
                    final selected = _timeLimit == t;
                    return GestureDetector(
                      onTap: () => setState(() => _timeLimit = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.green.shade400
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.green.shade400, width: 2.5),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Colors.green.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          t.label,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : Colors.green.shade600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'スタート！',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '© 2026 kujirabo.jp yamamotodin',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color color;
  final Color borderColor;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
