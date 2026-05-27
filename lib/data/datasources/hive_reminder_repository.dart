import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../models/reminder_model.dart';
import 'notification_service.dart';

/// Concrete Hive-backed implementation of [ReminderRepository].
/// All persistence is local; designed to be replaced/augmented with a
/// cloud implementation later (Future: CloudReminderRepository).
class HiveReminderRepository implements ReminderRepository {
  final Box<ReminderModel> _box;
  final NotificationService _notificationService;

  // Internal stream controller for reactive updates.
  final _streamController = StreamController<List<Reminder>>.broadcast();

  HiveReminderRepository(this._box, this._notificationService) {
    // Listen to Hive box changes and push to stream.
    _box.watch().listen((_) => _pushUpdate());
  }

  void _pushUpdate() {
    _streamController.add(_getSortedReminders());
  }

  List<Reminder> _getSortedReminders() {
    return _box.values
        .map((m) => m.toEntity())
        .toList()
      ..sort((a, b) => a.effectiveDateTime.compareTo(b.effectiveDateTime));
  }

  @override
  Stream<List<Reminder>> watchAllReminders() => _streamController.stream;

  @override
  Future<List<Reminder>> getAllReminders() async => _getSortedReminders();

  @override
  Future<List<Reminder>> getRemindersInRange(
      DateTime start, DateTime end) async {
    return _getSortedReminders()
        .where((r) =>
            r.effectiveDateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            r.effectiveDateTime.isBefore(end.add(const Duration(seconds: 1))))
        .toList();
  }

  @override
  Future<List<Reminder>> getRemindersForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    return getRemindersInRange(start, end);
  }

  @override
  Future<void> addReminder(Reminder reminder) async {
    await _box.put(
        reminder.id, ReminderModel.fromEntity(reminder));
    await _notificationService.scheduleReminder(reminder);
    _pushUpdate();
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    await _notificationService.cancelReminder(reminder.id);
    await _box.put(reminder.id, ReminderModel.fromEntity(reminder));
    if (!reminder.isCompleted) {
      await _notificationService.scheduleReminder(reminder);
    }
    _pushUpdate();
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _notificationService.cancelReminder(id);
    await _box.delete(id);
    _pushUpdate();
  }

  @override
  Future<void> toggleComplete(String id) async {
    final model = _box.get(id);
    if (model == null) return;
    final updated = model.toEntity().copyWith(isCompleted: !model.isCompleted);
    await updateReminder(updated);
  }

  @override
  Future<List<Reminder>> searchReminders(String query) async {
    final q = query.toLowerCase().trim();
    return _getSortedReminders()
        .where((r) =>
            r.title.toLowerCase().contains(q) ||
            (r.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Future<List<Reminder>> filterByType(ReminderType type) async {
    return _getSortedReminders().where((r) => r.type == type).toList();
  }

  void dispose() => _streamController.close();
}
