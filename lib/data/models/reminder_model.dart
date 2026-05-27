import 'package:hive/hive.dart';
import '../../domain/entities/reminder.dart';

part 'reminder_model.g.dart';

/// Hive-backed data model that mirrors the [Reminder] domain entity.
/// The type IDs (0-5) are unique across all registered Hive adapters.
@HiveType(typeId: 0)
class ReminderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int typeIndex; // maps to ReminderType enum

  @HiveField(4)
  final double? amount;

  @HiveField(5)
  final DateTime dateTime;

  @HiveField(6)
  final int recurrenceIndex; // maps to RecurrenceRule enum

  @HiveField(7)
  final int reminderOffsetDays;

  @HiveField(8)
  final bool isCompleted;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final bool? isCustomOffset;

  ReminderModel({
    required this.id,
    required this.title,
    this.description,
    required this.typeIndex,
    this.amount,
    required this.dateTime,
    required this.recurrenceIndex,
    required this.reminderOffsetDays,
    required this.isCompleted,
    required this.createdAt,
    this.isCustomOffset,
  });

  /// Convert from domain entity → Hive model.
  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      typeIndex: reminder.type.index,
      amount: reminder.amount,
      dateTime: reminder.dateTime,
      recurrenceIndex: reminder.recurrenceRule.index,
      reminderOffsetDays: reminder.reminderOffsetDays,
      isCompleted: reminder.isCompleted,
      createdAt: reminder.createdAt,
      isCustomOffset: reminder.isCustomOffset,
    );
  }

  /// Convert Hive model → domain entity.
  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      description: description,
      type: ReminderType.values[typeIndex],
      amount: amount,
      dateTime: dateTime,
      recurrenceRule: RecurrenceRule.values[recurrenceIndex],
      reminderOffsetDays: reminderOffsetDays,
      isCompleted: isCompleted,
      createdAt: createdAt,
      isCustomOffset: isCustomOffset ?? false,
    );
  }
}

/// Hive adapter for [ReminderType].
@HiveType(typeId: 1)
enum ReminderTypeHive {
  @HiveField(0)
  expense,
  @HiveField(1)
  subscription,
  @HiveField(2)
  birthday,
  @HiveField(3)
  insurance,
  @HiveField(4)
  custom,
}

/// Hive adapter for [RecurrenceRule].
@HiveType(typeId: 2)
enum RecurrenceRuleHive {
  @HiveField(0)
  oneTime,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  yearly,
}
