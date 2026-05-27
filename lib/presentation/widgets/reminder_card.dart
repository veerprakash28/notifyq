import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/reminder.dart';

/// Shared color + icon mapping for reminder types.
/// Import this from any widget to keep type styling consistent.
class ReminderTypeExtension {
  ReminderTypeExtension._();

  static Color colorFor(ReminderType type) {
    switch (type) {
      case ReminderType.expense:
        return AppColors.expense;
      case ReminderType.subscription:
        return AppColors.subscription;
      case ReminderType.birthday:
        return AppColors.birthday;
      case ReminderType.insurance:
        return AppColors.insurance;
      case ReminderType.custom:
        return AppColors.custom;
    }
  }

  static IconData iconFor(ReminderType type) {
    switch (type) {
      case ReminderType.expense:
        return Icons.receipt_long_rounded;
      case ReminderType.subscription:
        return Icons.replay_rounded;
      case ReminderType.birthday:
        return Icons.cake_rounded;
      case ReminderType.insurance:
        return Icons.shield_rounded;
      case ReminderType.custom:
        return Icons.bookmark_rounded;
    }
  }
}

/// Animated card that displays a single reminder.
class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;
  final bool showActions;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = ReminderTypeExtension.colorFor(reminder.type);
    final typeIcon = ReminderTypeExtension.iconFor(reminder.type);
    final theme = Theme.of(context);
    final isCompleted = reminder.isCompleted;
    final isOverdue = reminder.isOverdue;

    return AnimatedOpacity(
      opacity: isCompleted ? 0.55 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Type Icon ────────────────────────────────────────────
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 22),
                ),
                const SizedBox(width: 14),

                // ── Content ──────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminder.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isOverdue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Overdue',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (reminder.description != null &&
                          reminder.description!.isNotEmpty)
                        Text(
                          reminder.description!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _Chip(
                            label: reminder.type.label,
                            color: typeColor,
                          ),
                          const SizedBox(width: 6),
                          _Chip(
                            label: reminder.recurrenceRule.label,
                            color: theme.colorScheme.primary,
                          ),
                          if (reminder.amount != null) ...[
                            const SizedBox(width: 6),
                            _Chip(
                              label: reminder.amount!.toStringAsFixed(0),
                              color: AppColors.success,
                              prefix: '₹',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Actions ──────────────────────────────────────────────
                if (showActions)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onToggleComplete,
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.success.withOpacity(0.15)
                                : theme.colorScheme.outline.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 20,
                            color: isCompleted
                                ? AppColors.success
                                : theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final String? prefix;

  const _Chip({required this.label, required this.color, this.prefix});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        prefix != null ? '$prefix$label' : label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }
}
