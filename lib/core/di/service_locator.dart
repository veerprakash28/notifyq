import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/datasources/hive_reminder_repository.dart';
import '../../data/datasources/notification_service.dart';
import '../../data/models/reminder_model.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/usecases/reminder_usecases.dart';

/// Service Locator — single entry point for dependency resolution.
/// Call [ServiceLocator.init] once at app startup.
///
/// Future: Swap [HiveReminderRepository] for [CloudReminderRepository]
/// here without touching any other code.
final sl = GetIt.instance;

class ServiceLocator {
  ServiceLocator._();

  static Future<void> init() async {
    // ── External Services ──────────────────────────────────────────────────
    await Hive.initFlutter();
    Hive.registerAdapter(ReminderModelAdapter());
    final box = await Hive.openBox<ReminderModel>(AppConstants.remindersBoxName);
    final prefs = await SharedPreferences.getInstance();

    sl.registerSingleton<SharedPreferences>(prefs);
    sl.registerSingleton<Box<ReminderModel>>(box);

    // ── Notification Service ───────────────────────────────────────────────
    final notificationService = NotificationService();
    await notificationService.initialize();
    sl.registerSingleton<NotificationService>(notificationService);

    // ── Repository ─────────────────────────────────────────────────────────
    sl.registerSingleton<ReminderRepository>(
      HiveReminderRepository(box, notificationService),
    );

    // ── Use Cases ──────────────────────────────────────────────────────────
    sl.registerFactory(() => GetAllReminders(sl<ReminderRepository>()));
    sl.registerFactory(() => WatchAllReminders(sl<ReminderRepository>()));
    sl.registerFactory(() => AddReminder(sl<ReminderRepository>()));
    sl.registerFactory(() => UpdateReminder(sl<ReminderRepository>()));
    sl.registerFactory(() => DeleteReminder(sl<ReminderRepository>()));
    sl.registerFactory(() => ToggleReminderComplete(sl<ReminderRepository>()));
    sl.registerFactory(() => SearchReminders(sl<ReminderRepository>()));
    sl.registerFactory(() => FilterRemindersByType(sl<ReminderRepository>()));
    sl.registerFactory(() => GetRemindersForDay(sl<ReminderRepository>()));
    sl.registerFactory(() => GetUpcomingFinancialTotal(sl<ReminderRepository>()));
  }
}
