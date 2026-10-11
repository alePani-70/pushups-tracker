import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences that do not belong in the relational history
/// (spec §3.7). Backed by shared_preferences; notifies listeners on change.
class AppSettings extends ChangeNotifier {
  static const _kHaptics = 'settings.haptics';
  static const _kSound = 'settings.sound';
  static const _kKeepAwake = 'settings.keepAwake';
  static const _kRestEndAlert = 'settings.restEndAlert';

  bool _haptics = true;
  bool _sound = true;
  bool _keepAwake = true;
  bool _restEndAlert = true;

  /// Vibrate on each rep and when a rest ends.
  bool get haptics => _haptics;

  /// Ticking in the last 3 seconds of a rest.
  bool get sound => _sound;

  /// Keep the screen on during a workout session.
  bool get keepAwake => _keepAwake;

  /// Post a local notification when a rest ends (works with the screen off).
  bool get restEndAlert => _restEndAlert;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _haptics = prefs.getBool(_kHaptics) ?? true;
    _sound = prefs.getBool(_kSound) ?? true;
    _keepAwake = prefs.getBool(_kKeepAwake) ?? true;
    _restEndAlert = prefs.getBool(_kRestEndAlert) ?? true;
    notifyListeners();
  }

  Future<void> setHaptics(bool value) => _set(_kHaptics, value, () => _haptics = value);
  Future<void> setSound(bool value) => _set(_kSound, value, () => _sound = value);
  Future<void> setKeepAwake(bool value) => _set(_kKeepAwake, value, () => _keepAwake = value);
  Future<void> setRestEndAlert(bool value) => _set(_kRestEndAlert, value, () => _restEndAlert = value);

  Future<void> _set(String key, bool value, VoidCallback apply) async {
    apply();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in [_kHaptics, _kSound, _kKeepAwake, _kRestEndAlert]) {
      await prefs.remove(k);
    }
    _haptics = _sound = _keepAwake = _restEndAlert = true;
    notifyListeners();
  }
}
