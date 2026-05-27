import '../entities/reminder.dart';

/// Abstract contract for reminder persistence.
/// The data layer provides the concrete implementation; the domain layer
/// only depends on this interface (Dependency Inversion Principle).
///
/// Future: a [CloudReminderRepository] can implement this same interface
/// and be swapped in without touching domain or presentation code.
abstract class ReminderRepository {
  /// Returns all reminders, sorted by effective date ascending.
  Future<List<Reminder>> getAllReminders();

  /// Returns reminders whose effective date falls within [start]..[end].
  Future<List<Reminder>> getRemindersInRange(DateTime start, DateTime end);

  /// Returns reminders for a specific calendar day.
  Future<List<Reminder>> getRemindersForDay(DateTime day);

  /// Persists a new reminder and schedules its notification.
  Future<void> addReminder(Reminder reminder);

  /// Updates an existing reminder and reschedules notification.
  Future<void> updateReminder(Reminder reminder);

  /// Removes a reminder and cancels its scheduled notification.
  Future<void> deleteReminder(String id);

  /// Marks a reminder as completed/incomplete.
  Future<void> toggleComplete(String id);

  /// Returns reminders matching [query] in title or description.
  Future<List<Reminder>> searchReminders(String query);

  /// Returns reminders filtered by [type].
  Future<List<Reminder>> filterByType(ReminderType type);

  /// Reactive stream of all reminders — UI rebuilds automatically on changes.
  Stream<List<Reminder>> watchAllReminders();

  // ── Future: Cloud Sync Hook ────────────────────────────────────────────────
  // Future<void> syncWithCloud();
  // Future<bool> get hasPendingSync;
}
