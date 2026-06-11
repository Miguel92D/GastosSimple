import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../features/transactions/repositories/transaction_repository.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(initializationSettings);

    // Android 13+ exige el permiso POST_NOTIFICATIONS en runtime;
    // sin esto el recordatorio diario nunca se muestra.
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    if (!enabled) {
      await _notifications.cancel(100);
      return;
    }

    final String? timeStr = prefs.getString('notification_time'); // HH:mm
    int hour = 20;
    int minute = 0;

    if (timeStr != null) {
      final parts = timeStr.split(':');
      hour = int.tryParse(parts[0]) ?? 20;
      minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    }

    try {
      await _scheduleDailyReminderAt(
        hour,
        minute,
        AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException {
      // Android 12+ puede denegar alarmas exactas (SCHEDULE_EXACT_ALARM).
      // Un recordatorio diario no necesita precisión de segundos: caemos
      // a modo inexacto antes que perder la notificación.
      await _scheduleDailyReminderAt(
        hour,
        minute,
        AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> _scheduleDailyReminderAt(
    int hour,
    int minute,
    AndroidScheduleMode scheduleMode,
  ) async {
    await _notifications.zonedSchedule(
      100,
      '¿Registraste tus gastos de hoy?',
      'No olvides anotar tus movimientos para mantener tu control financiero.',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          channelDescription:
              'Reminds you to register transactions if you haven\'t yet',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> checkAndNotify() async {
    // This could be called from a background task or on app resume
    final transactions = await TransactionRepository.getTransactionsToday();
    if (transactions.isEmpty) {
      // Send immediate notification if it's evening?
      // Actually, scheduling is better.
    }
  }
}
