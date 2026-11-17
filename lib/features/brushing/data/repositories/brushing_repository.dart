import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brushing_log.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/database_helper.dart';

class BrushingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  DateTime getEffectiveLocalTime(DateTime utc, String timezone) =>
      getEffectiveLocalTimeStatic(utc, timezone);

  static DateTime getEffectiveLocalTimeStatic(DateTime utc, String timezone) {
    final offsetMins = getTimezoneOffsetMinutes(timezone);
    return utc.toUtc().add(Duration(minutes: offsetMins));
  }

  static int getTimezoneOffsetMinutes(String timezone) {
    const offsets = {
      'UTC': 0,
      'America/New_York': -300,
      'America/Chicago': -360,
      'America/Denver': -420,
      'America/Los_Angeles': -480,
      'Asia/Kolkata': 330,
      'Asia/Tokyo': 540,
      'Asia/Shanghai': 480,
      'Asia/Singapore': 480,
      'Asia/Dubai': 240,
      'Australia/Sydney': 600,
      'Europe/Paris': 60,
      'Europe/Berlin': 60,
      'Europe/London': 0,
      'Pacific/Auckland': 720,
    };
    return offsets[timezone] ?? DateTime.now().timeZoneOffset.inMinutes;
  }

  Future<BrushingLog?> logBrushing({
    required String userId,
    required String timezone,
    required int durationSeconds,
    BrushingSession? explicitSession,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final localTime = getEffectiveLocalTime(now, timezone);

      final session = explicitSession ??
          (localTime.hour < 12
              ? BrushingSession.morning
              : BrushingSession.evening);

      // Check if already logged this session
      final alreadyLogged = await hasBrushedToday(
        userId: userId,
        session: session,
        timezone: timezone,
      );

      if (alreadyLogged) {
        print("Session $session already logged today for user $userId");
        return null;
      }

      final logId = 'log_${DateTime.now().millisecondsSinceEpoch}';
      final log = BrushingLog(
        id: logId,
        userId: userId,
        timestamp: now,
        session: session,
        timezone: timezone,
        durationSeconds: durationSeconds,
        pointsEarned: 10,
      );

      // Save to local SQLite database
      await _dbHelper.insertBrushingLog(log);
      await _dbHelper.addPoints(userId, 10);

      // Optional background sync to Firestore
      try {
        await _firestore
            .collection(AppConstants.brushingCollection)
            .doc(log.id)
            .set(log.toFirestore());
      } catch (e) {
        print("Firestore sync skipped/failed: $e");
      }

      return log;
    } catch (e) {
      print("Error logging brushing: $e");
      return null;
    }
  }

  Future<List<BrushingLog>> getMonthLogs({
    required String userId,
    required int year,
    required int month,
    required String timezone,
  }) async {
    try {
      // 1. Read from local SQLite
      final localLogs = await _dbHelper.getLogsForMonth(userId, year, month);
      if (localLogs.isNotEmpty) {
        return localLogs;
      }

      // 2. Fallback to Firestore if local DB is empty
      try {
        final offsetMinutes = getTimezoneOffsetMinutes(timezone);
        final localStart = DateTime(year, month, 1);
        final localEnd = DateTime(year, month + 1, 1);
        final utcStart = localStart.subtract(Duration(minutes: offsetMinutes));
        final utcEnd = localEnd.subtract(Duration(minutes: offsetMinutes));

        final snapshot = await _firestore
            .collection(AppConstants.brushingCollection)
            .where('user_id', isEqualTo: userId)
            .where('timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(utcStart))
            .where('timestamp', isLessThan: Timestamp.fromDate(utcEnd))
            .orderBy('timestamp')
            .get();

        final remoteLogs = snapshot.docs
            .map((e) => BrushingLog.fromFirestore(e))
            .toList();

        for (final rLog in remoteLogs) {
          await _dbHelper.insertBrushingLog(rLog);
        }
        return remoteLogs;
      } catch (_) {
        return localLogs;
      }
    } catch (e) {
      print("Error fetching month logs: $e");
      return [];
    }
  }

  Future<int> getDailyBrushingCount({
    required String userId,
    required String timezone,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final local = _toLocalTime(targetDate.toUtc(), timezone);
    final dateKey =
        '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    return await _dbHelper.getBrushingCountForDate(userId, dateKey);
  }

  Map<DateTime, DailyBrushingStatus> buildDailyStatusMap({
    required List<BrushingLog> logs,
    required String timezone,
    required DateTime today,
  }) {
    final Map<DateTime, DailyBrushingStatus> result = {};
    final localToday = _toLocalTime(today, timezone);
    final start = DateTime(localToday.year, localToday.month, 1);
    final end = DateTime(localToday.year, localToday.month + 1, 0);

    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      final key = DateTime(d.year, d.month, d.day);
      result[key] = DailyBrushingStatus(
        date: key,
        morningBrushed: false,
        eveningBrushed: false,
        status: DayStatus.red,
      );
    }

    for (final log in logs) {
      final local = _toLocalTime(log.timestamp, timezone);
      final key = DateTime(local.year, local.month, local.day);
      final existing = result[key] ??
          DailyBrushingStatus(
            date: key,
            morningBrushed: false,
            eveningBrushed: false,
            status: DayStatus.red,
          );

      final morning =
          existing.morningBrushed || log.session == BrushingSession.morning;

      final evening =
          existing.eveningBrushed || log.session == BrushingSession.evening;

      DayStatus status;
      if (morning && evening) {
        status = DayStatus.green;
      } else if (morning || evening) {
        status = DayStatus.yellow;
      } else {
        status = DayStatus.red;
      }

      result[key] = DailyBrushingStatus(
        date: key,
        morningBrushed: morning,
        eveningBrushed: evening,
        status: status,
      );
    }

    return result;
  }

  Map<String, int> calculateStreaks({
    required Map<DateTime, DailyBrushingStatus> statusMap,
    required String timezone,
  }) {
    final today = _toLocalTime(DateTime.now().toUtc(), timezone);
    final todayDate = DateTime(today.year, today.month, today.day);

    int current = 0;
    int max = 0;
    int temp = 0;

    final todayStatus = statusMap[todayDate]?.status;
    if (todayStatus == DayStatus.green || todayStatus == DayStatus.yellow) {
      current = 1;
    }

    var check = todayDate.subtract(const Duration(days: 1));
    while (statusMap[check]?.status == DayStatus.green ||
        statusMap[check]?.status == DayStatus.yellow) {
      current++;
      check = check.subtract(const Duration(days: 1));
    }

    final sorted = statusMap.keys.toList()..sort();
    for (final d in sorted) {
      if (statusMap[d]?.status == DayStatus.green ||
          statusMap[d]?.status == DayStatus.yellow) {
        temp++;
        if (temp > max) max = temp;
      } else {
        temp = 0;
      }
    }

    return {'current': current, 'max': max};
  }

  Future<bool> hasBrushedToday({
    required String userId,
    required BrushingSession session,
    required String timezone,
  }) async {
    try {
      final now = _toLocalTime(DateTime.now().toUtc(), timezone);
      final dateKey =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // 1. Fast local SQLite check
      final hasBrushedLocal = await _dbHelper.hasBrushedSessionToday(
        userId,
        dateKey,
        session.name,
      );

      if (hasBrushedLocal) return true;

      // 2. Fallback to Firestore check
      try {
        final offsetMinutes = getTimezoneOffsetMinutes(timezone);
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));

        final utcStart = start.subtract(Duration(minutes: offsetMinutes));
        final utcEnd = end.subtract(Duration(minutes: offsetMinutes));

        final snap = await _firestore
            .collection(AppConstants.brushingCollection)
            .where('user_id', isEqualTo: userId)
            .where('session', isEqualTo: session.name)
            .where('timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(utcStart))
            .where('timestamp', isLessThan: Timestamp.fromDate(utcEnd))
            .limit(1)
            .get();

        return snap.docs.isNotEmpty;
      } catch (_) {
        return hasBrushedLocal;
      }
    } catch (e) {
      print("Error checking today's brush: $e");
      return false;
    }
  }

  DateTime _toLocalTime(DateTime utc, String timezone) =>
      getEffectiveLocalTime(utc, timezone);
}
