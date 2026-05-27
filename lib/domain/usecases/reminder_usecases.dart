import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

// ── Use Cases (Single Responsibility) ─────────────────────────────────────────
// Each use case encapsulates exactly one business action. They orchestrate
// repository calls and can be tested independently.

class GetAllReminders {
  final ReminderRepository _repo;
  GetAllReminders(this._repo);
  Future<List<Reminder>> call() => _repo.getAllReminders();
}

class WatchAllReminders {
  final ReminderRepository _repo;
  WatchAllReminders(this._repo);
  Stream<List<Reminder>> call() => _repo.watchAllReminders();
}

class AddReminder {
  final ReminderRepository _repo;
  AddReminder(this._repo);
  Future<void> call(Reminder reminder) => _repo.addReminder(reminder);
}

class UpdateReminder {
  final ReminderRepository _repo;
  UpdateReminder(this._repo);
  Future<void> call(Reminder reminder) => _repo.updateReminder(reminder);
}

class DeleteReminder {
  final ReminderRepository _repo;
  DeleteReminder(this._repo);
  Future<void> call(String id) => _repo.deleteReminder(id);
}

class ToggleReminderComplete {
  final ReminderRepository _repo;
  ToggleReminderComplete(this._repo);
  Future<void> call(String id) => _repo.toggleComplete(id);
}

class SearchReminders {
  final ReminderRepository _repo;
  SearchReminders(this._repo);
  Future<List<Reminder>> call(String query) => _repo.searchReminders(query);
}

class FilterRemindersByType {
  final ReminderRepository _repo;
  FilterRemindersByType(this._repo);
  Future<List<Reminder>> call(ReminderType type) => _repo.filterByType(type);
}

class GetRemindersForDay {
  final ReminderRepository _repo;
  GetRemindersForDay(this._repo);
  Future<List<Reminder>> call(DateTime day) => _repo.getRemindersForDay(day);
}

class GetUpcomingFinancialTotal {
  final ReminderRepository _repo;
  GetUpcomingFinancialTotal(this._repo);

  /// Sums the amounts of expense, subscription, and insurance reminders
  /// within the next [days] days.
  Future<double> call({int days = 30}) async {
    final now = DateTime.now();
    final reminders =
        await _repo.getRemindersInRange(now, now.add(Duration(days: days)));
    return reminders
        .where((r) =>
            !r.isCompleted &&
            (r.type == ReminderType.expense ||
                r.type == ReminderType.subscription ||
                r.type == ReminderType.insurance) &&
            r.amount != null)
        .fold(0.0, (sum, r) => sum + (r.amount ?? 0));
  }
}
