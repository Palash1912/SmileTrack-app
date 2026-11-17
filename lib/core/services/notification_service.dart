import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'database_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Keys
  static const String keyRemindersEnabled = 'notif_reminders_enabled';
  static const String keyMorningHour = 'notif_morning_hour';
  static const String keyMorningMinute = 'notif_morning_minute';
  static const String keyEveningHour = 'notif_evening_hour';
  static const String keyEveningMinute = 'notif_evening_minute';
  static const String keyStreakAlerts = 'notif_streak_alerts_enabled';
  static const String keyQuizReminders = 'notif_quiz_reminders_enabled';

  // Notification IDs
  static const int idMorning = 101;
  static const int idEvening = 102;
  static const int idStreak = 103;
  static const int idQuiz = 104;
  static const int idInstant = 105;

  void configureTimezone(String? timezoneName) {
    try {
      if (timezoneName != null && timezoneName.isNotEmpty) {
        final loc = tz.getLocation(timezoneName);
        tz.setLocalLocation(loc);
        print('NotificationService: local timezone set to ${loc.name}');
        return;
      }
    } catch (e) {
      print('Could not find timezone $timezoneName, attempting offset fallback: $e');
    }

    try {
      final deviceOffset = DateTime.now().timeZoneOffset.inMilliseconds;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == deviceOffset) {
          tz.setLocalLocation(loc);
          print('NotificationService: local timezone set to offset match ${loc.name}');
          return;
        }
      }
    } catch (_) {}
  }

  Future<void> initialize({String? timezone}) async {
    if (_isInitialized) {
      if (timezone != null) configureTimezone(timezone);
      return;
    }

    try {
      tz.initializeTimeZones();
      configureTimezone(timezone);

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          // Navigation logic can be handled here if needed
        },
      );

      // Create notification channel for Android
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'brushing_reminders',
            'Brushing Reminders',
            description: 'Daily alerts to keep your brushing habits on track',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
      }

      _isInitialized = true;
    } catch (e) {
      print('NotificationService init error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted =
            await androidImplementation.requestNotificationsPermission();
        try {
          await androidImplementation.requestExactAlarmsPermission();
        } catch (_) {}
        return granted ?? false;
      }

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
    return true;
  }

  Future<void> scheduleBrushingReminders({
    required TimeOfDay morning,
    required TimeOfDay evening,
    String? timezone,
  }) async {
    await initialize(timezone: timezone);

    String? tzName = timezone;
    if (tzName == null || tzName.isEmpty) {
      final active = await DatabaseHelper().getActiveUser();
      tzName = active?.timezone;
    }
    configureTimezone(tzName);

    // Cancel existing
    await cancelBrushingReminders();

    // Schedule Morning
    await _scheduleDailyNotification(
      id: idMorning,
      title: '☀️ Time for Morning Brush!',
      body: 'Start your day fresh with 2 minutes for a sparkling smile! 🪥',
      time: morning,
    );

    // Schedule Evening
    await _scheduleDailyNotification(
      id: idEvening,
      title: '🌙 Don\'t Forget Your Evening Brush!',
      body: 'Protect your teeth overnight and keep your streak going! 🌟',
      time: evening,
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    print('NotificationService: local now = $now');

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      0,
    );

    // If time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    print('NotificationService: Scheduled for $scheduledDate (id: $id)');

    const androidDetails = AndroidNotificationDetails(
      'brushing_reminders',
      'Brushing Reminders',
      channelDescription: 'Daily alerts to keep your brushing habits on track',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    const AndroidScheduleMode scheduleMode =
        AndroidScheduleMode.exactAllowWhileIdle;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelBrushingReminders() async {
    await _notificationsPlugin.cancel(idMorning);
    await _notificationsPlugin.cancel(idEvening);
  }

  Future<void> showInstantTestNotification() async {
    await initialize();
    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      'brushing_reminders',
      'Brushing Reminders',
      channelDescription: 'Daily alerts to keep your brushing habits on track',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      idInstant,
      '🪥 SmileTrack Reminder Active!',
      'Notifications are enabled! You\'ll receive reminders for your daily brush.',
      notificationDetails,
    );
  }

  // Preference Persistence
  Future<NotificationPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(keyRemindersEnabled) ?? true;
    final morningHour = prefs.getInt(keyMorningHour) ?? 8;
    final morningMin = prefs.getInt(keyMorningMinute) ?? 0;
    final eveningHour = prefs.getInt(keyEveningHour) ?? 21;
    final eveningMin = prefs.getInt(keyEveningMinute) ?? 30;
    final streakAlerts = prefs.getBool(keyStreakAlerts) ?? true;
    final quizReminders = prefs.getBool(keyQuizReminders) ?? false;

    return NotificationPreferences(
      remindersEnabled: enabled,
      morningTime: TimeOfDay(hour: morningHour, minute: morningMin),
      eveningTime: TimeOfDay(hour: eveningHour, minute: eveningMin),
      streakAlerts: streakAlerts,
      quizReminders: quizReminders,
    );
  }

  Future<void> savePreferences(NotificationPreferences pref, {String? timezone}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyRemindersEnabled, pref.remindersEnabled);
    await prefs.setInt(keyMorningHour, pref.morningTime.hour);
    await prefs.setInt(keyMorningMinute, pref.morningTime.minute);
    await prefs.setInt(keyEveningHour, pref.eveningTime.hour);
    await prefs.setInt(keyEveningMinute, pref.eveningTime.minute);
    await prefs.setBool(keyStreakAlerts, pref.streakAlerts);
    await prefs.setBool(keyQuizReminders, pref.quizReminders);

    if (pref.remindersEnabled) {
      await scheduleBrushingReminders(
        morning: pref.morningTime,
        evening: pref.eveningTime,
        timezone: timezone,
      );
    } else {
      await cancelBrushingReminders();
    }
  }
}

class NotificationPreferences {
  final bool remindersEnabled;
  final TimeOfDay morningTime;
  final TimeOfDay eveningTime;
  final bool streakAlerts;
  final bool quizReminders;

  const NotificationPreferences({
    required this.remindersEnabled,
    required this.morningTime,
    required this.eveningTime,
    required this.streakAlerts,
    required this.quizReminders,
  });

  NotificationPreferences copyWith({
    bool? remindersEnabled,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    bool? streakAlerts,
    bool? quizReminders,
  }) {
    return NotificationPreferences(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
      streakAlerts: streakAlerts ?? this.streakAlerts,
      quizReminders: quizReminders ?? this.quizReminders,
    );
  }
}

