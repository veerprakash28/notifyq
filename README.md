# NotifyQ 🔔

> **Intelligent Reminder & Alert System** — Never miss a bill, birthday, or subscription again.

NotifyQ is a production-ready Flutter application that proactively notifies you before financial deductions, life events, and custom reminders — with configurable alert timing, a beautiful Material 3 UI, and full offline support.

---

## 📱 Screenshots & Features

| Home Dashboard | Calendar | Add Reminder | Settings |
|---|---|---|---|
| Gradient header, financial summary, filter chips | Monthly calendar with color-coded event dots | Type selector, date/time picker, recurrence & offset | Theme, currency, notification controls |

### Core Features
- ✅ **5 Reminder Types**: Expense · Subscription · Birthday · Insurance · Custom
- 🔔 **Smart Notifications**: Fires X days before the event (configurable)
- 📅 **Recurrence**: One-time · Daily · Weekly · Monthly · Yearly
- 💰 **Monthly Outflow Tracker**: Auto-sums upcoming financial reminders
- 🗓 **Calendar View**: Color-coded dots per type, tap a date to see reminders
- 🔍 **Search & Filter**: Real-time search + type-based filtering
- 🌙 **Dark/Light/System Theme**: Persisted across restarts
- 📴 **Fully Offline**: No internet required

---

## 🏗 Architecture

The project strictly follows **Clean Architecture** with three layers:

```
lib/
├── core/                       # Framework-agnostic utilities
│   ├── constants/              # AppConstants — no magic strings
│   ├── di/                     # ServiceLocator (GetIt)
│   ├── theme/                  # AppTheme + AppColors (Material 3)
│   └── utils/                  # SeedData
│
├── domain/                     # ⭐ Pure Dart — zero framework deps
│   ├── entities/               # Reminder, ReminderType, RecurrenceRule
│   ├── repositories/           # Abstract ReminderRepository (interface)
│   └── usecases/               # Single-responsibility use cases
│
├── data/                       # Framework implementations
│   ├── datasources/            # HiveReminderRepository, NotificationService
│   └── models/                 # ReminderModel (Hive) + generated adapter
│
└── presentation/               # Flutter UI
    ├── providers/              # Riverpod providers (state, streams)
    ├── pages/                  # home/, calendar/, add_reminder/, settings/
    └── widgets/                # ReminderCard + shared widgets
```

### Key Architecture Decisions

| Decision | Rationale |
|---|---|
| **Riverpod** (not Bloc) | Less boilerplate, supports sync/async/stream providers natively |
| **Hive** (not SQLite) | Binary serialization, 10x faster reads for small datasets |
| **GetIt** service locator | Lightweight, no code generation needed |
| **Use Cases** as first-class objects | Testable in isolation, single responsibility |
| **Abstract Repository** | Swap Hive → Cloud without touching UI or domain |

---

## 🚀 Running Locally

### Prerequisites

```bash
# Install Flutter (if not already)
# https://docs.flutter.dev/get-started/install/macos

flutter --version   # Should be >= 3.19.0
dart --version      # Should be >= 3.0.0

# Verify setup
flutter doctor
```

### Run on Android Device / Emulator

```bash
cd ~/Documents/projects/notifyq

# Install dependencies
flutter pub get

# Connect your Android device (enable USB debugging)
# OR start an emulator from Android Studio

# Run in debug mode
flutter run

# Run on a specific device
flutter devices          # list available devices
flutter run -d <device-id>
```

### Run on Physical Device (USB)

1. Enable **Developer Options** on your Android phone
2. Enable **USB Debugging**
3. Connect via USB
4. Run `flutter run`

---

## 📦 Build APK (Install on Phone)

```bash
# Debug APK (for testing, no signing required)
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Release APK (optimized, signed with debug key for now)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# App Bundle (for Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Install APK on Phone via ADB

```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Install via File Transfer

1. Build the debug APK
2. Copy `app-debug.apk` to your phone
3. Open it from the Files app (allow "Install from unknown sources" if prompted)

---

## 🧪 Sample Data

On first launch, NotifyQ automatically seeds 8 realistic reminders:

| Title | Type | Amount | Due |
|---|---|---|---|
| Netflix Subscription | Subscription | ₹649 | In 3 days |
| House Rent | Expense | ₹18,000 | In 1 day |
| Mom's Birthday | Birthday | — | In 5 days |
| Car Insurance Renewal | Insurance | ₹12,500 | In 14 days |
| Spotify Premium | Subscription | ₹119 | In 7 days |
| Home Loan EMI | Expense | ₹35,000 | In 10 days |
| Wedding Anniversary | Birthday | — | In 21 days |
| Domain Renewal | Custom | ₹999 | In 30 days |

To re-seed: Clear app data from Android Settings → Apps → NotifyQ → Clear Data.

---

## 🔮 Extending with Backend (Future)

The architecture is designed for zero-friction backend integration.

### Step 1: Create Cloud Repository

```dart
// lib/data/datasources/firebase_reminder_repository.dart
class FirebaseReminderRepository implements ReminderRepository {
  final FirebaseFirestore _firestore;
  
  @override
  Future<void> addReminder(Reminder reminder) async {
    await _firestore
        .collection('users/${userId}/reminders')
        .doc(reminder.id)
        .set(reminder.toJson());
  }
  // ... implement all other methods
}
```

### Step 2: Swap in ServiceLocator

```dart
// lib/core/di/service_locator.dart — change just this line:
sl.registerSingleton<ReminderRepository>(
  // HiveReminderRepository(box, notificationService), // OLD
  FirebaseReminderRepository(FirebaseFirestore.instance), // NEW
);
```

**Zero changes needed in domain, presentation, or providers.**

### Planned Future Features

- 🔐 **Firebase Auth** — Google Sign-In placeholder in Settings
- ☁️ **Cloud Sync** — Firestore real-time sync across devices  
- 🤖 **AI Spending Insights** — Pattern detection on expense data
- 📊 **Analytics Dashboard** — Monthly/yearly spending charts
- 🔄 **Auto-Subscription Detection** — SMS/email parsing (future)

---

## 📚 Tech Stack

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.5.1 | State management |
| hive_flutter | ^1.1.0 | Local database |
| flutter_local_notifications | ^17.2.2 | Push notifications |
| get_it | ^7.7.0 | Dependency injection |
| uuid | ^4.4.2 | UUID generation |
| intl | ^0.19.0 | Date formatting |
| timezone | ^0.9.4 | Timezone-aware notifications |
| table_calendar | ^3.1.2 | Calendar UI |
| shared_preferences | ^2.3.2 | Settings persistence |
| permission_handler | ^11.3.1 | Runtime permissions |

---

## 🧰 Development Commands

```bash
# Run code generation (Hive adapters, Riverpod generators)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/

# Check for outdated packages
flutter pub outdated
```

---

## ⚠️ Known Considerations

1. **Exact Alarms (Android 12+)**: The app requests `SCHEDULE_EXACT_ALARM` permission. On Android 13+, users may need to manually allow this in Settings → Apps → Special app access → Alarms & reminders.

2. **Notification Permission (Android 13+)**: The app requests runtime notification permission on first launch.

3. **Battery Optimization**: For reliable notifications, advise users to exclude NotifyQ from battery optimization (Settings → Battery → Battery Optimization → NotifyQ → Don't optimize).

4. **Leap Year / Month-End**: The `Reminder.nextOccurrence` method handles month-end edge cases (e.g., Jan 31 + 1 month = Feb 28/29) and leap years correctly.

---

## 📄 License

MIT © 2024 NotifyQ
