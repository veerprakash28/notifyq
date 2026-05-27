/// Reminder domain entity — pure Dart, no framework dependencies.
/// This is the single source of truth for reminder data throughout the app.
class Reminder {
  final String id;
  final String title;
  final String? description;
  final ReminderType type;
  final double? amount;
  final DateTime dateTime;
  final RecurrenceRule recurrenceRule;

  /// How many days before [dateTime] the notification fires.
  final int reminderOffsetDays;
  final bool isCompleted;
  final DateTime createdAt;
  final bool isCustomOffset;

  const Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.amount,
    required this.dateTime,
    required this.recurrenceRule,
    required this.reminderOffsetDays,
    required this.isCompleted,
    required this.createdAt,
    this.isCustomOffset = false,
  });

  /// Returns the exact [DateTime] when the notification should fire.
  DateTime get notificationDateTime {
    if (reminderOffsetDays == 0) return dateTime;
    return dateTime.subtract(Duration(days: reminderOffsetDays));
  }

  /// True if the reminder notification time is within the next [days] days.
  bool isUpcomingWithin(int days) {
    final now = DateTime.now();
    final trigger = notificationDateTime;
    return trigger.isAfter(now) &&
        trigger.isBefore(now.add(Duration(days: days)));
  }

  /// True if the event (not notification) is today.
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// True if overdue and not completed.
  bool get isOverdue =>
      !isCompleted && dateTime.isBefore(DateTime.now());

  /// Returns next occurrence for recurring reminders.
  /// Returns null for one-time reminders.
  DateTime? get nextOccurrence {
    if (recurrenceRule == RecurrenceRule.oneTime) return null;
    final now = DateTime.now();
    DateTime candidate = dateTime;

    while (candidate.isBefore(now)) {
      switch (recurrenceRule) {
        case RecurrenceRule.daily:
          candidate = candidate.add(const Duration(days: 1));
          break;
        case RecurrenceRule.weekly:
          candidate = candidate.add(const Duration(days: 7));
          break;
        case RecurrenceRule.monthly:
          candidate = _addMonths(candidate, 1);
          break;
        case RecurrenceRule.yearly:
          candidate = _addMonths(candidate, 12);
          break;
        case RecurrenceRule.oneTime:
          break;
      }
    }
    return candidate;
  }

  /// Safe month addition that handles month-end edge cases and leap years.
  static DateTime _addMonths(DateTime date, int months) {
    int year = date.year;
    int month = date.month + months;
    while (month > 12) {
      month -= 12;
      year++;
    }
    // Clamp day to last valid day of resulting month.
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day, date.hour, date.minute, date.second);
  }

  /// Effective display date: next occurrence for recurring, original for one-time.
  DateTime get effectiveDateTime =>
      nextOccurrence ?? dateTime;

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    double? amount,
    DateTime? dateTime,
    RecurrenceRule? recurrenceRule,
    int? reminderOffsetDays,
    bool? isCompleted,
    DateTime? createdAt,
    bool? isCustomOffset,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      reminderOffsetDays: reminderOffsetDays ?? this.reminderOffsetDays,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      isCustomOffset: isCustomOffset ?? this.isCustomOffset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Reminder && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum ReminderType {
  expense,
  subscription,
  birthday,
  insurance,
  custom;

  String get label {
    switch (this) {
      case ReminderType.expense:
        return 'Expense';
      case ReminderType.subscription:
        return 'Subscription';
      case ReminderType.birthday:
        return 'Birthday';
      case ReminderType.insurance:
        return 'Insurance';
      case ReminderType.custom:
        return 'Custom';
    }
  }
}

enum RecurrenceRule {
  oneTime,
  daily,
  weekly,
  monthly,
  yearly;

  String get label {
    switch (this) {
      case RecurrenceRule.oneTime:
        return 'One-time';
      case RecurrenceRule.daily:
        return 'Daily';
      case RecurrenceRule.weekly:
        return 'Weekly';
      case RecurrenceRule.monthly:
        return 'Monthly';
      case RecurrenceRule.yearly:
        return 'Yearly';
    }
  }
}
