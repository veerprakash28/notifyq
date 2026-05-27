import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/reminder_usecases.dart';

// ── Settings State ─────────────────────────────────────────────────────────────

class AppSettings {
  final int defaultOffsetDays;
  final bool notificationsEnabled;
  final ThemeMode themeMode;
  final String currency;

  const AppSettings({
    this.defaultOffsetDays = AppConstants.defaultReminderOffsetDays,
    this.notificationsEnabled = true,
    this.themeMode = ThemeMode.system,
    this.currency = AppConstants.defaultCurrency,
  });

  AppSettings copyWith({
    int? defaultOffsetDays,
    bool? notificationsEnabled,
    ThemeMode? themeMode,
    String? currency,
  }) {
    return AppSettings(
      defaultOffsetDays: defaultOffsetDays ?? this.defaultOffsetDays,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  AppSettings build() {
    _prefs = sl<SharedPreferences>();
    return _load();
  }

  AppSettings _load() {
    final themeModeIndex = _prefs.getInt(AppConstants.keyThemeMode) ?? 0;
    return AppSettings(
      defaultOffsetDays: _prefs.getInt(AppConstants.keyDefaultOffset) ??
          AppConstants.defaultReminderOffsetDays,
      notificationsEnabled:
          _prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true,
      themeMode: ThemeMode.values[themeModeIndex.clamp(0, 2)],
      currency: _prefs.getString(AppConstants.keyCurrency) ??
          AppConstants.defaultCurrency,
    );
  }

  Future<void> setDefaultOffset(int days) async {
    await _prefs.setInt(AppConstants.keyDefaultOffset, days);
    state = state.copyWith(defaultOffsetDays: days);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyNotificationsEnabled, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(AppConstants.keyThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setCurrency(String currency) async {
    await _prefs.setString(AppConstants.keyCurrency, currency);
    state = state.copyWith(currency: currency);
  }
}

// ── Providers ──────────────────────────────────────────────────────────────────

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final remindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  return sl<WatchAllReminders>().call();
});

final upcomingRemindersProvider = Provider<List<Reminder>>((ref) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  return remindersAsync.when(
    data: (reminders) => reminders
        .where((r) =>
            !r.isCompleted &&
            r.effectiveDateTime.isAfter(DateTime.now()))
        .take(50)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final next7DaysProvider = Provider<List<Reminder>>((ref) {
  final remindersAsync = ref.watch(remindersStreamProvider);
  final now = DateTime.now();
  final in7Days = now.add(const Duration(days: 7));
  return remindersAsync.when(
    data: (reminders) => reminders
        .where((r) =>
            !r.isCompleted &&
            r.effectiveDateTime.isAfter(now) &&
            r.effectiveDateTime.isBefore(in7Days))
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final monthlyTotalProvider = FutureProvider<double>((ref) async {
  ref.watch(remindersStreamProvider);
  return sl<GetUpcomingFinancialTotal>().call(days: 30);
});

final selectedTypeFilterProvider = StateProvider<ReminderType?>((ref) => null);

final filteredRemindersProvider = Provider<List<Reminder>>((ref) {
  final all = ref.watch(upcomingRemindersProvider);
  final filter = ref.watch(selectedTypeFilterProvider);
  if (filter == null) return all;
  return all.where((r) => r.type == filter).toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Reminder>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  return sl<SearchReminders>().call(query);
});

// ── Calendar Providers ─────────────────────────────────────────────────────────

final selectedCalendarDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final remindersForSelectedDayProvider =
    FutureProvider<List<Reminder>>((ref) async {
  final day = ref.watch(selectedCalendarDateProvider);
  ref.watch(remindersStreamProvider); // re-run when reminders change
  return sl<GetRemindersForDay>().call(day);
});
