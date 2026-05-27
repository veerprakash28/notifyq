/// App-wide constants. Centralizing values here prevents magic strings/numbers
/// and makes future refactoring trivial.
class AppConstants {
  AppConstants._();

  // ── App Identity ────────────────────────────────────────────────────────────
  static const String appName = 'NotifyQ';
  static const String appVersion = '1.0.0';

  // ── Hive Box Names ──────────────────────────────────────────────────────────
  static const String remindersBoxName = 'reminders_box';
  static const String settingsBoxName = 'settings_box';

  // ── Settings Keys ───────────────────────────────────────────────────────────
  static const String keyDefaultOffset = 'default_offset';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrency = 'currency';

  // ── Notification Channel ─────────────────────────────────────────────────────
  static const String notificationChannelId = 'notifyq_channel';
  static const String notificationChannelName = 'NotifyQ Reminders';
  static const String notificationChannelDesc =
      'Alerts for upcoming reminders and financial deductions';

  // ── Default Settings ─────────────────────────────────────────────────────────
  static const int defaultReminderOffsetDays = 1;
  static const String defaultCurrency = '₹';

  // ── UI Constants ─────────────────────────────────────────────────────────────
  static const double cardBorderRadius = 16.0;
  static const double pagePadding = 16.0;
  static const double fabSize = 56.0;

  // ── Future: Cloud Sync (placeholder) ─────────────────────────────────────────
  // static const String firebaseProjectId = 'notifyq-app';
  // static const String apiBaseUrl = 'https://api.notifyq.app/v1';

  // ── Future: AI Insights (placeholder) ────────────────────────────────────────
  // static const String aiInsightsEndpoint = '/insights';
}
