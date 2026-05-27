import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../domain/entities/reminder.dart';
import '../../core/constants/app_constants.dart';
import 'dart:io';

/// Central notification service wrapping flutter_local_notifications.
/// Handles scheduling, cancelling, grouping, and boot-rescheduling.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request Android 13+ notification permission.
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Future: Navigate to reminder detail screen using a navigator key.
    // NavigatorService.navigateTo('/reminder/${response.payload}');
  }

  // ── Schedule ───────────────────────────────────────────────────────────────

  Future<void> scheduleReminder(Reminder reminder) async {
    if (!_initialized) await initialize();

    final triggerTime = tz.TZDateTime.from(
      reminder.notificationDateTime,
      tz.local,
    );

    // Don't schedule notifications in the past.
    if (triggerTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    final notifId = _idFromUuid(reminder.id);
    final details = _buildNotificationDetails(reminder);

    if (reminder.recurrenceRule == RecurrenceRule.oneTime) {
      await _plugin.zonedSchedule(
        notifId,
        _buildTitle(reminder),
        _buildBody(reminder),
        triggerTime,
        details,
        payload: reminder.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      final matchDateTimeComponents = _matchComponents(reminder.recurrenceRule);
      if (matchDateTimeComponents != null) {
        await _plugin.zonedSchedule(
          notifId,
          _buildTitle(reminder),
          _buildBody(reminder),
          triggerTime,
          details,
          payload: reminder.id,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      }
    }
  }

  /// Reschedule all active reminders — call this after device reboot.
  Future<void> rescheduleAllReminders(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      if (!reminder.isCompleted) {
        await scheduleReminder(reminder);
      }
    }
  }

  Future<void> cancelReminder(String id) async {
    await _plugin.cancel(_idFromUuid(id));
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _buildTitle(Reminder reminder) {
    if (reminder.reminderOffsetDays == 0) {
      return '📅 ${reminder.title} is today!';
    }
    return '⏰ ${reminder.title} in ${reminder.reminderOffsetDays} day(s)';
  }

  String _buildBody(Reminder reminder) {
    final parts = <String>[];
    if (reminder.description != null && reminder.description!.isNotEmpty) {
      parts.add(reminder.description!);
    }
    if (reminder.amount != null) {
      parts.add('Amount: ${reminder.amount!.toStringAsFixed(2)}');
    }
    parts.add('Type: ${reminder.type.label}');
    return parts.join(' · ');
  }

  NotificationDetails _buildNotificationDetails(Reminder reminder) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        groupKey: 'notifyq_${reminder.type.name}',
        styleInformation: BigTextStyleInformation(_buildBody(reminder)),
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: reminder.type.name,
        threadIdentifier: 'notifyq_${reminder.type.name}',
      ),
    );
  }

  DateTimeComponents? _matchComponents(RecurrenceRule rule) {
    switch (rule) {
      case RecurrenceRule.daily:
        return DateTimeComponents.time;
      case RecurrenceRule.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RecurrenceRule.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RecurrenceRule.yearly:
        return DateTimeComponents.dateAndTime;
      case RecurrenceRule.oneTime:
        return null;
    }
  }

  /// Converts a UUID string to a stable int for notification IDs.
  int _idFromUuid(String uuid) =>
      uuid.replaceAll('-', '').hashCode.abs() % 2147483647;
}
