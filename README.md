# 100 Pushups Tracker

A Flutter mobile app for the pushups 6-week training program. Offline-first, no account required, with local notifications, rest timer, progress tracking, and charts.

## Features

- **Complete program data** bundled: initial test, 6 weeks × 3 days × 3 columns, 3 exhaustion-test gates, final test
- **Smart routing**: test results automatically determine your week/column; repeat weeks when needed
- **Workout session**: large tap-to-count rep counter, haptic feedback, rest timer with +15s / skip, screen wake-lock
- **Schedule & notifications**: pick 3 days/week + time; local push notifications for upcoming workouts/tests (no server)
- **Missed / incomplete handling**: unfinished work is automatically reprogrammed to the next workout slot; catch-up cards on Home
- **Progress tracking**: SQLite database stores every rep, set, and test; line chart of max reps over time + weekly volume bar chart
- **Onboarding**: disclaimer → initial test → schedule picker → program start

## Tech Stack

| Layer | Package |
|---|---|
| Framework | Flutter 3.16+ |
| State management | `flutter_bloc` |
| Database | `drift` (SQLite) |
| Notifications | `flutter_local_notifications` + `android_alarm_manager_plus` |
| Foreground timer | `flutter_foreground_task` |
| Charts | `fl_chart` |
| Utilities | `wakelock_plus`, `vibration`, `shared_preferences` |

## Project Structure

```
lib/
├── data/
│   ├── database.dart              # Drift schema (users, slots, workouts, sets, tests)
│   └── program_repository.dart    # Loads program_v1.json, provides routing lookups
├── domain/
│   ├── models/
│   │   └── workout_state.dart     # WorkoutState, SetState, WorkoutStatus
│   └── routing/
│       └── routing_engine.dart    # Initial test & exhaustion test routing logic
├── services/
│   ├── notification_service.dart  # Local notification scheduling (iOS + Android)
│   └── reschedule_engine.dart     # Generates slots, handles missed/incomplete reprogramming
├── presentation/
│   ├── dashboard/
│   │   └── dashboard_screen.dart  # Home: current position, next workout, stats, catch-up cards
│   ├── workout_session/
│   │   ├── bloc/
│   │   │   ├── workout_bloc.dart      # BLoC: rep counting, rest timer, save/complete
│   │   │   ├── workout_event.dart
│   │   │   └── workout_state_bloc.dart
│   │   └── workout_session_screen.dart # UI: tap zone, countdown ring, set preview
│   ├── schedule/
│   │   └── schedule_screen.dart   # 3-day picker, time picker, notification toggle
│   ├── progress/
│   │   └── progress_screen.dart   # Stats cards, fl_chart line chart, history timeline
│   └── onboarding/
│       └── onboarding_screen.dart # 4-step onboarding flow
└── main.dart

assets/
└── program_v1.json                # Canonical 100-pushups program data
```

## Getting Started

### Prerequisites

- Flutter SDK 3.16 or newer
- Android Studio / Xcode for emulators
- For Android: API 33+ device or emulator for notification permission testing

### Setup

```bash
# 1. Get dependencies
flutter pub get

# 2. Generate Drift database code
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run on your device
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Platform-specific Notes

### Android

The manifest already declares:
- `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` for precise workout reminders
- `FOREGROUND_SERVICE_HEALTH` / `DATA_SYNC` for the rest timer foreground service
- `RECEIVE_BOOT_COMPLETED` to reschedule alarms after reboot
- `POST_NOTIFICATIONS` runtime permission (Android 13+)

**Important:** The app must be whitelisted from battery optimization for the foreground rest timer to survive reliably. The spec includes a one-time user prompt for this after onboarding.

### iOS

The Info.plist declares:
- `UIBackgroundModes`: `fetch` and `processing` for extended runtime sessions
- `flutter_local_notifications` handles `UNUserNotificationCenter` authorization

## Database Schema

| Table | Purpose |
|---|---|
| `users` | Profile: schedule days/time, current week/day/column, onboarding flag |
| `scheduled_slots` | Calendar of upcoming workouts/tests with status (pending/done/missed/...) |
| `workouts` | Record of each workout session: week, day, column, status, timestamps |
| `workout_sets` | Individual sets within a workout: prescribed, performed, isPlus, rest extension |
| `tests` | Initial, exhaustion, and final test results with routing metadata |

## Program Data

All workout data lives in `assets/program_v1.json`. To modify the program (e.g., different column thresholds), edit the JSON and bump `version`. The app reads this at launch — no code changes needed for data updates.

## Key Implementation Details

1. **Rest timer**: implemented as a `Timer.periodic` inside the BLoC; the UI shows a `CircularProgressIndicator`. For production, wrap this in `flutter_foreground_task` so it survives screen-off.
2. **Reprogramming**: when a slot is missed or a workout abandoned, `RescheduleEngine` inserts the same week/day into the next available slot and shifts future slots forward. History rows are immutable.
3. **Notification IDs**: use the `scheduled_slot.id` as the notification ID, so canceling/rescheduling is trivial.
4. **BLoC state machine**: `idle → active → resting → active → ... → complete → saved`. The rest timer ticks via `RestTicked` events.

## Next Steps / TODOs

- [ ] Add `flutter_foreground_task` integration in `WorkoutSessionScreen` for background rest timer
- [ ] Add Android battery-optimization whitelist prompt
- [ ] Implement volume-button rep counting (native method channel)
- [ ] Add CSV/JSON export in Settings
- [ ] Add dark/light theme toggle
- [ ] Add sound effects for rest timer countdown
- [ ] Implement "undo rep" in BLoC
- [ ] Add unit tests for `RoutingEngine` and `RescheduleEngine`
