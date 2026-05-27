import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/reminder.dart';
import '../../providers/app_providers.dart';
import '../../widgets/reminder_card.dart';
import '../add_reminder/add_reminder_page.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/usecases/reminder_usecases.dart';

/// Calendar tab — monthly view with event markers and day detail sheet.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDay = ref.watch(selectedCalendarDateProvider);
    final remindersAsync = ref.watch(remindersStreamProvider);
    final dayReminders = ref.watch(remindersForSelectedDayProvider);

    // Build event map for calendar markers.
    final eventMap = <DateTime, List<Reminder>>{};
    remindersAsync.whenData((reminders) {
      for (final r in reminders) {
        final key = DateTime(
          r.effectiveDateTime.year,
          r.effectiveDateTime.month,
          r.effectiveDateTime.day,
        );
        eventMap.putIfAbsent(key, () => []).add(r);
      }
    });

    return Column(
      children: [
        // ── Calendar ──────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar<Reminder>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return eventMap[key] ?? [];
            },
            onDaySelected: (selected, focused) {
              ref.read(selectedCalendarDateProvider.notifier).state = selected;
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 5,
              markerMargin: const EdgeInsets.only(top: 1),
              weekendTextStyle:
                  TextStyle(color: theme.colorScheme.error.withOpacity(0.8)),
              defaultTextStyle:
                  TextStyle(fontFamily: 'Outfit', color: theme.colorScheme.onSurface),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
              ),
              todayTextStyle: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonShowsNext: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
              leftChevronIcon: Icon(Icons.chevron_left_rounded,
                  color: theme.colorScheme.primary),
              rightChevronIcon: Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.primary),
              formatButtonDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              formatButtonTextStyle: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              weekendStyle: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.error.withOpacity(0.7),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (ctx, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                // Show colored dots per type.
                final types =
                    events.map((e) => (e as Reminder).type).toSet().take(3).toList();
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: types
                        .map((t) => Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _typeColor(t),
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ),

        // ── Day Reminders ─────────────────────────────────────────────────
        Expanded(
          child: dayReminders.when(
            data: (reminders) {
              if (reminders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_available_rounded,
                          size: 48,
                          color: theme.colorScheme.outline.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text(
                        'No reminders this day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: reminders.length,
                itemBuilder: (ctx, i) => ReminderCard(
                  reminder: reminders[i],
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          AddReminderPage(existing: reminders[i]))),
                  onToggleComplete: () =>
                      sl<ToggleReminderComplete>().call(reminders[i].id),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Color _typeColor(ReminderType type) {
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
}
