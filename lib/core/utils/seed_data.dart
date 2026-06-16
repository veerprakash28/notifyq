import 'package:uuid/uuid.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/reminder_usecases.dart';
import '../di/service_locator.dart';

/// Seeds the database with representative sample reminders.
/// Call once on first launch (check with a SharedPreferences flag).
class SeedData {
  SeedData._();

  static final _uuid = Uuid();

  static final List<Reminder> reminders = [
    Reminder(
      id: _uuid.v4(),
      title: 'Netflix Subscription',
      description: 'Monthly streaming subscription',
      type: ReminderType.subscription,
      amount: 649,
      dateTime: DateTime.now().add(const Duration(days: 3)),
      recurrenceRule: RecurrenceRule.monthly,
      reminderOffsetDays: 2,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Reminder(
      id: _uuid.v4(),
      title: 'House Rent',
      description: 'Monthly rent payment to landlord',
      type: ReminderType.expense,
      amount: 18000,
      dateTime: DateTime.now().add(const Duration(days: 1)),
      recurrenceRule: RecurrenceRule.monthly,
      reminderOffsetDays: 3,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Reminder(
      id: _uuid.v4(),
      title: "Mom's Birthday",
      description: 'Order flowers and cake!',
      type: ReminderType.birthday,
      amount: null,
      dateTime: DateTime.now().add(const Duration(days: 5)),
      recurrenceRule: RecurrenceRule.yearly,
      reminderOffsetDays: 2,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Reminder(
      id: _uuid.v4(),
      title: 'Car Insurance Renewal',
      description: 'Renew comprehensive car insurance',
      type: ReminderType.insurance,
      amount: 12500,
      dateTime: DateTime.now().add(const Duration(days: 14)),
      recurrenceRule: RecurrenceRule.yearly,
      reminderOffsetDays: 3,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Reminder(
      id: _uuid.v4(),
      title: 'Spotify Premium',
      description: 'Music subscription',
      type: ReminderType.subscription,
      amount: 119,
      dateTime: DateTime.now().add(const Duration(days: 7)),
      recurrenceRule: RecurrenceRule.monthly,
      reminderOffsetDays: 1,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Reminder(
      id: _uuid.v4(),
      title: 'Home Loan EMI',
      description: 'SBI home loan monthly installment',
      type: ReminderType.expense,
      amount: 35000,
      dateTime: DateTime.now().add(const Duration(days: 10)),
      recurrenceRule: RecurrenceRule.monthly,
      reminderOffsetDays: 2,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Reminder(
      id: _uuid.v4(),
      title: 'Wedding Anniversary',
      description: 'Plan a special dinner 💑',
      type: ReminderType.birthday,
      amount: null,
      dateTime: DateTime.now().add(const Duration(days: 21)),
      recurrenceRule: RecurrenceRule.yearly,
      reminderOffsetDays: 3,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Reminder(
      id: _uuid.v4(),
      title: 'Domain Renewal',
      description: 'Renew notifyq.app domain',
      type: ReminderType.custom,
      amount: 999,
      dateTime: DateTime.now().add(const Duration(days: 30)),
      recurrenceRule: RecurrenceRule.yearly,
      reminderOffsetDays: 7,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
  ];

  /// Inserts all seed reminders into the repository.
  static Future<void> seed() async {
    final addReminder = sl<AddReminder>();
    for (final reminder in reminders) {
      await addReminder(reminder);
    }
  }
}
