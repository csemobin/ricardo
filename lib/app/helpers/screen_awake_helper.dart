import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the device screen on while ride tracking is visible.
///
/// Uses the platform keep-screen-on flag (`FLAG_KEEP_SCREEN_ON` /
/// `idleTimerDisabled`). It does **not** change the system timeout setting
/// and is released as soon as tracking is no longer in the foreground.
class ScreenAwakeHelper {
  ScreenAwakeHelper._();

  static bool _desired = false;
  static bool _applied = false;
  static bool _syncing = false;

  static bool get isApplied => _applied;

  /// Idempotent. Rapid toggles coalesce onto one enable/disable call.
  static Future<void> setDesired(bool desired) async {
    _desired = desired;
    await _sync();
  }

  static Future<void> release() => setDesired(false);

  static Future<void> _sync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      while (_applied != _desired) {
        final next = _desired;
        try {
          if (next) {
            await WakelockPlus.enable();
          } else {
            await WakelockPlus.disable();
          }
          _applied = next;
        } catch (e) {
          debugPrint('ScreenAwakeHelper: $e');
          break;
        }
      }
    } finally {
      _syncing = false;
    }
  }
}
