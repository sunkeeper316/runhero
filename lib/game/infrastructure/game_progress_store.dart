import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GameProgressStore {
  static const _progressKey = 'run_hero_progress_v1';

  Future<Map<String, dynamic>?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_progressKey);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> save(Map<String, dynamic> progress) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_progressKey, jsonEncode(progress));
  }
}
