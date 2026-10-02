import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../features/transactions/repositories/transaction_repository.dart';
import '../core/i18n/app_locale_controller.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  static const _enabledKey = 'notifications_enabled';
  static const _timeKey = 'notification_time'; // HH:mm
  static const int _reminderId = 100;
  static const int defaultHour = 20;

  Future<void> init() async {
    tz.initializeTimeZones();
    _configureLocalTimeZone();
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

  /// Sin esto `tz.local` queda en UTC y el recordatorio de las 20:00 sonaba
  /// a las 17:00 en Argentina. No hay paquete para leer el nombre IANA del
  /// sistema, así que se elige una zona con el mismo desfase actual
  /// (prefiriendo Buenos Aires).
  void _configureLocalTimeZone() {
    final offset = DateTime.now().timeZoneOffset;
    try {
      final preferred = tz.getLocation('America/Argentina/Buenos_Aires');
      if (tz.TZDateTime.now(preferred).timeZoneOffset == offset) {
        tz.setLocalLocation(preferred);
        return;
      }
      for (final location in tz.timeZoneDatabase.locations.values) {
        if (tz.TZDateTime.now(location).timeZoneOffset == offset) {
          tz.setLocalLocation(location);
          return;
        }
      }
    } catch (_) {
      // Si falla, queda UTC (comportamiento anterior).
    }
  }

  Future<void> scheduleDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = _readSettings(prefs);
    if (!settings.enabled) {
      await _notifications.cancel(_reminderId);
      return;
    }
    final hour = settings.hour;
    final minute = settings.minute;

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

  ({bool enabled, int hour, int minute}) _readSettings(
    SharedPreferences prefs,
  ) {
    final enabled = prefs.getBool(_enabledKey) ?? true;
    var hour = defaultHour;
    var minute = 0;
    final timeStr = prefs.getString(_timeKey);
    if (timeStr != null) {
      final parts = timeStr.split(':');
      hour = int.tryParse(parts[0]) ?? defaultHour;
      minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    }
    return (enabled: enabled, hour: hour, minute: minute);
  }

  /// Configuración actual del recordatorio (para la pantalla de Ajustes).
  Future<({bool enabled, int hour, int minute})> getReminderSettings() async {
    return _readSettings(await SharedPreferences.getInstance());
  }

  /// Activa o desactiva el recordatorio. Al activarlo pide el permiso de
  /// notificaciones (Android 13+); si el usuario lo niega devuelve false y
  /// no lo activa, para que el interruptor no mienta.
  Future<bool> setReminderEnabled(bool enabled) async {
    if (enabled) {
      final granted = await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      if (granted == false) return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    await scheduleDailyReminder();
    return true;
  }

  Future<void> setReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _timeKey,
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
    );
    await scheduleDailyReminder();
  }

  Future<void> _scheduleDailyReminderAt(
    int hour,
    int minute,
    AndroidScheduleMode scheduleMode,
  ) async {
    final l10n = AppLocaleController.instance;
    await _notifications.zonedSchedule(
      _reminderId,
      l10n.text('reminder_notification_title'),
      l10n.text('reminder_notification_body'),
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
