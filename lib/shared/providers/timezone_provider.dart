import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Timezone offset provider
//
// Stores the user's UTC offset in whole minutes (e.g. +330 for IST, -300 for
// US/EST).  On first launch it seeds itself from the device's current offset
// so the app works out of the box with no setup required.
//
// The user can later override this from a Settings screen by calling:
//   ref.read(timezoneOffsetProvider.notifier).setOffset(offsetMinutes)
// ─────────────────────────────────────────────────────────────────────────────

const _kTimezoneOffsetKey = 'user_timezone_offset_minutes';

class TimezoneOffsetNotifier extends StateNotifier<int> {
  TimezoneOffsetNotifier() : super(_deviceOffsetMinutes()) {
    _loadSaved();
  }

  /// Device's current UTC offset in minutes (handles DST automatically).
  static int _deviceOffsetMinutes() => DateTime.now().timeZoneOffset.inMinutes;

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_kTimezoneOffsetKey)) {
      state = prefs.getInt(_kTimezoneOffsetKey)!;
    } else {
      // First launch — persist device offset so it is explicit going forward.
      await prefs.setInt(_kTimezoneOffsetKey, state);
    }
  }

  /// Persist a user-chosen UTC offset (in minutes).
  Future<void> setOffset(int offsetMinutes) async {
    state = offsetMinutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTimezoneOffsetKey, offsetMinutes);
  }

  /// Re-sync to whatever the device reports right now (call after DST changes).
  Future<void> syncToDevice() => setOffset(_deviceOffsetMinutes());
}

final timezoneOffsetProvider =
    StateNotifierProvider<TimezoneOffsetNotifier, int>(
  (ref) => TimezoneOffsetNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Convenience helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the current wall-clock time adjusted to the user's stored timezone.
///
/// Usage:
///   final now = ref.watch(localNowProvider);
///   final isMorning = now.hour < 12;
final localNowProvider = Provider<DateTime>((ref) {
  final offsetMinutes = ref.watch(timezoneOffsetProvider);
  final utcNow = DateTime.now().toUtc();
  return utcNow.add(Duration(minutes: offsetMinutes));
});

/// True when the current local hour is before noon (morning session).
final isMorningSessionProvider = Provider<bool>((ref) {
  return ref.watch(localNowProvider).hour < 12;
});

// ─────────────────────────────────────────────────────────────────────────────
// Human-readable label helpers used by UI
// ─────────────────────────────────────────────────────────────────────────────

/// A signed UTC offset string like "+05:30" or "-05:00".
String formatUtcOffset(int totalMinutes) {
  final sign = totalMinutes >= 0 ? '+' : '-';
  final abs = totalMinutes.abs();
  final h = (abs ~/ 60).toString().padLeft(2, '0');
  final m = (abs % 60).toString().padLeft(2, '0');
  return 'UTC$sign$h:$m';
}

/// All standard UTC offsets the user can choose from in the settings picker.
const List<Map<String, dynamic>> kUtcOffsetOptions = [
  {'label': 'UTC-12:00', 'minutes': -720},
  {'label': 'UTC-11:00', 'minutes': -660},
  {'label': 'UTC-10:00 (Hawaii)', 'minutes': -600},
  {'label': 'UTC-09:00 (Alaska)', 'minutes': -540},
  {'label': 'UTC-08:00 (PST)', 'minutes': -480},
  {'label': 'UTC-07:00 (MST)', 'minutes': -420},
  {'label': 'UTC-06:00 (CST)', 'minutes': -360},
  {'label': 'UTC-05:00 (EST)', 'minutes': -300},
  {'label': 'UTC-04:00 (AST)', 'minutes': -240},
  {'label': 'UTC-03:00', 'minutes': -180},
  {'label': 'UTC-02:00', 'minutes': -120},
  {'label': 'UTC-01:00', 'minutes': -60},
  {'label': 'UTC+00:00 (GMT/WET)', 'minutes': 0},
  {'label': 'UTC+01:00 (CET)', 'minutes': 60},
  {'label': 'UTC+02:00 (EET)', 'minutes': 120},
  {'label': 'UTC+03:00 (MSK)', 'minutes': 180},
  {'label': 'UTC+03:30 (Iran)', 'minutes': 210},
  {'label': 'UTC+04:00 (Gulf)', 'minutes': 240},
  {'label': 'UTC+04:30 (Afghanistan)', 'minutes': 270},
  {'label': 'UTC+05:00 (PKT)', 'minutes': 300},
  {'label': 'UTC+05:30 (IST)', 'minutes': 330},
  {'label': 'UTC+05:45 (Nepal)', 'minutes': 345},
  {'label': 'UTC+06:00 (BST)', 'minutes': 360},
  {'label': 'UTC+06:30 (Myanmar)', 'minutes': 390},
  {'label': 'UTC+07:00 (ICT)', 'minutes': 420},
  {'label': 'UTC+08:00 (CST/SGT)', 'minutes': 480},
  {'label': 'UTC+09:00 (JST/KST)', 'minutes': 540},
  {'label': 'UTC+09:30 (ACST)', 'minutes': 570},
  {'label': 'UTC+10:00 (AEST)', 'minutes': 600},
  {'label': 'UTC+10:30 (Lord Howe)', 'minutes': 630},
  {'label': 'UTC+11:00 (AEDT)', 'minutes': 660},
  {'label': 'UTC+12:00 (NZST)', 'minutes': 720},
  {'label': 'UTC+13:00 (NZDT)', 'minutes': 780},
];
