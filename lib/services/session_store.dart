import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_result.dart';

class SessionStore {
  static const _key = 'session_results';

  static Future<List<SessionResult>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list
        .map((s) => SessionResult.fromJsonString(s))
        .toList()
        .reversed
        .toList(); // 新しい順
  }

  static Future<void> add(SessionResult session) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(session.toJsonString());
    await prefs.setStringList(_key, list);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
