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
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);
    }

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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
