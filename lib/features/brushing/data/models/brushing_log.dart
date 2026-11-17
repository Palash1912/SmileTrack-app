import 'package:cloud_firestore/cloud_firestore.dart';

enum BrushingSession { morning, evening }

enum DayStatus { green, yellow, red, white }

class BrushingLog {
  final String id;
  final String userId;
  final DateTime timestamp;
  final BrushingSession session;
  final String timezone;
  final int durationSeconds;
  final int pointsEarned;

  const BrushingLog({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.session,
    required this.timezone,
    this.durationSeconds = 0,
    this.pointsEarned = 10,
  });

  factory BrushingLog.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    if (data == null) {
      throw Exception('Document data is null.');
    }

    final Timestamp? ts = data['timestamp'] as Timestamp?;

    return BrushingLog(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      timestamp: ts?.toDate() ?? DateTime.now(),
      session: (data['session'] as String?) == 'morning'
          ? BrushingSession.morning
          : BrushingSession.evening,
      timezone: data['timezone'] as String? ?? 'UTC',
      durationSeconds: data['duration_seconds'] as int? ?? 0,
      pointsEarned: data['points_earned'] as int? ?? 10,
    );
  }

  factory BrushingLog.fromMap(Map<String, dynamic> map) {
    return BrushingLog(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      session: (map['session'] as String?) == 'morning'
          ? BrushingSession.morning
          : BrushingSession.evening,
      timezone: map['timezone'] as String? ?? 'UTC',
      durationSeconds: map['duration_seconds'] as int? ?? 0,
      pointsEarned: map['points_earned'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    final offsetMins = _getOffsetMinutes(timezone);
    final localTime = timestamp.toUtc().add(Duration(minutes: offsetMins));
    final dateKey =
        '${localTime.year.toString().padLeft(4, '0')}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}';
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'date_key': dateKey,
      'session': session.name,
      'timezone': timezone,
      'duration_seconds': durationSeconds,
      'points_earned': pointsEarned,
    };
  }

  static int _getOffsetMinutes(String timezone) {
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

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'session': session.name,
      'timezone': timezone,
      'duration_seconds': durationSeconds,
      'points_earned': pointsEarned,
    };
  }
}

class DailyBrushingStatus {
  final DateTime date;
  final bool morningBrushed;
  final bool eveningBrushed;
  final DayStatus status;

  const DailyBrushingStatus({
    required this.date,
    this.morningBrushed = false,
    this.eveningBrushed = false,
    required this.status,
  });
}
