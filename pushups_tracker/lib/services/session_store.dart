import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Crash-recoverable snapshot of the in-progress workout session.
///
/// The bloc writes a snapshot on every state change (each rep, each rest tick
/// boundary, set completion) and clears it once the workout is saved or
/// discarded. On launch the dashboard offers to resume if a snapshot exists.
class SessionStore {
  static const _key = 'active_session_v1';

  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      await prefs.remove(_key);
      return null;
    }
  }

  Future<void> save(Map<String, dynamic> snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(snapshot));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
