import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/seed_data.dart';
import 'presentation/pages/app_shell.dart';
import 'presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for Android MVP.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize all dependencies (Hive, Notifications, DI).
  await ServiceLocator.init();

  // Seed sample data on first launch only.
  await _seedIfFirstLaunch();

  // Transparent status bar for edge-to-edge UI.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    const ProviderScope(
      child: NotifyQApp(),
    ),
  );
}

Future<void> _seedIfFirstLaunch() async {
  final prefs = sl<SharedPreferences>();
  final isFirstLaunch = prefs.getBool('first_launch') ?? true;
  if (isFirstLaunch) {
    await SeedData.seed();
    await prefs.setBool('first_launch', false);
  }
}

/// Root MaterialApp — theme-aware via Riverpod.
class NotifyQApp extends ConsumerWidget {
  const NotifyQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'NotifyQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const AppShell(),
    );
  }
}
