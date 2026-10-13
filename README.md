# 100 Pushups Tracker

A Flutter mobile app for the [hundredpushups.com](https://hundredpushups.com) 6-week training program. Offline-first, no account required, with local notifications, rest timer, progress tracking, and charts.

## Features

- **Complete program data** bundled: initial test, 6 weeks × 3 days × 3 columns, 3 exhaustion-test gates, final test
- **Smart routing**: test results automatically determine your week/column; repeat weeks when needed
- **Workout session**: large tap-to-count rep counter, haptic feedback, rest timer with +15s / skip, screen wake-lock
- **Schedule & notifications**: pick 3 days/week + time; local push notifications for upcoming workouts/tests (no server)
- **Missed / incomplete handling**: unfinished work is automatically reprogrammed to the next workout slot; catch-up cards on Home
- **Progress tracking**: SQLite database stores every rep, set, and test; line chart of max reps over time + weekly volume bar chart
- **Onboarding**: disclaimer → registration (name, age, weight, sex) → initial test → schedule picker → summary with your first workout's sets
- **Workout preview**: see every set, the rest time and an estimated duration before starting; upcoming slots open a read-only preview
- **Program browser**: all 6 weeks × 3 days × 3 columns, test gates with routing thresholds, rank table with your age band highlighted
- **Profile**: editable in Settings; only age is used (rank band), weight and sex are stored for your records and export

## Tech Stack

| Layer | Package |
|---|---|
| Framework | Flutter 3.16+ |
| State management | `flutter_bloc` |
| Database | `drift` (SQLite) |
| Notifications | `flutter_local_notifications` (scheduled via `zonedSchedule`, exact alarms) |
| Rest-end alert | `flutter_local_notifications` (scheduled at rest end; no foreground service) |
| Charts | `fl_chart` |
| Utilities | `wakelock_plus`, `vibration`, `shared_preferences` (settings + crash-recovery snapshot), `share_plus` (export), `intl` |

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
│   ├── notification_service.dart  # Local notifications: slot reminders, day-before, rest-end alert
│   ├── progression_service.dart   # Advances week/day/column; applies test routing
│   ├── app_settings.dart          # Haptics / sound / keep-awake / rest-alert prefs
│   ├── export_service.dart        # CSV + JSON export via share sheet
│   ├── session_store.dart         # Crash-recovery snapshot of the live session
│   └── reschedule_engine.dart     # Generates slots, handles missed/incomplete reprogramming
├── presentation/
│   ├── home/
│   │   └── home_shell.dart        # 3-tab IndexedStack shell (Home · Progress · Schedule)
│   ├── preview/
│   │   └── workout_preview_screen.dart # Sets/rest/duration before starting (spec §3.8)
│   ├── program/
│   │   └── program_screen.dart    # Browse all weeks/days/columns + test gates (spec §3.9)
│   ├── settings/
│   │   ├── settings_screen.dart   # Profile, toggles, column override, repeat week, export, reset
│   │   └── profile_edit_screen.dart
│   ├── test/
│   │   └── test_screen.dart       # Exhaustion / final test with routing confirmation
│   ├── widgets/
│   │   ├── rep_counter.dart       # Shared tap-to-count widget
│   │   ├── profile_form.dart      # Name/age/weight/sex form (registration + edit)
│   │   └── workout_plan_card.dart # Set table used by preview, onboarding, program
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

The Flutter project lives in `pushups_tracker/`; run all commands from there.

```bash
cd pushups_tracker

# 1. Get dependencies
flutter pub get

# 2. Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# 3. Run on your device
flutter run
```

### Run on the Android emulator

```bash
flutter emulators                                   # list AVDs (e.g. Medium_Phone_API_37.0)
flutter emulators --launch Medium_Phone_API_37.0    # boot it (first boot can take a few minutes)
flutter run -d emulator-5554                        # build, install, launch with hot reload
```

Notes:
- `android/app/build.gradle.kts` enables core-library desugaring (needed by `flutter_local_notifications`) and sets `minSdk = 26`.
- The first Gradle build downloads Gradle, AGP and SDK platforms; expect 5–10 minutes. Later builds take about a minute.
- Application id: `com.apanizza.pushups_tracker`.

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
- `RECEIVE_BOOT_COMPLETED` to reschedule alarms after reboot
- `POST_NOTIFICATIONS` runtime permission (Android 13+)


### iOS

The Info.plist declares:
- No background modes: the rest timer is wall-clock based and uses a scheduled local notification as the screen-off cue
- `flutter_local_notifications` handles `UNUserNotificationCenter` authorization

## Database Schema

| Table | Purpose |
|---|---|
| `users` | Profile (name, age, weight, sex), schedule days/time, current week/day/column, pending test, onboarding flag — schema v2 |
| `scheduled_slots` | Calendar of upcoming workouts/tests with status (pending/done/missed/...) |
| `workouts` | Record of each workout session: week, day, column, status, timestamps |
| `workout_sets` | Individual sets within a workout: prescribed, performed, isPlus, rest extension |
| `tests` | Initial, exhaustion, and final test results with routing metadata |

## Program Data

All workout data lives in `assets/program_v1.json`. To modify the program (e.g., different column thresholds), edit the JSON and bump `version`. The app reads this at launch — no code changes needed for data updates.

## Key Implementation Details

1. **Rest timer**: wall-clock based — the BLoC stores `restEndsAt` and derives the countdown from it on each tick, so backgrounding does not drift the timer. Every state change is snapshotted to `shared_preferences` (`SessionStore`) so an interrupted session can be resumed from the dashboard.
2. **Reprogramming**: the user position (`users.currentWeek/currentDay/pendingTest`) is the source of truth. `RescheduleEngine.rebuildSchedule` drops all *pending* slots and regenerates them from that position (backlog resume slots first, then the pending test, then remaining days). Missed slots (12 h grace) are detected on dashboard load. History rows are immutable.
3. **Notification IDs**: use the `scheduled_slot.id` as the notification ID, so canceling/rescheduling is trivial.
4. **BLoC state machine**: `idle → active → resting → active → ... → complete → saved`. The rest timer ticks via `RestTicked` events.

## Next Steps / TODOs

- [x] Rest timer survives screen-off via a scheduled local notification (no foreground service needed)
- [ ] Add Android battery-optimization whitelist prompt
- [ ] Implement volume-button rep counting (native method channel)
- [x] Add CSV/JSON export in Settings
- [ ] Add dark/light theme toggle
- [x] Add sound effects for rest timer countdown
- [x] Implement "undo rep" in BLoC
- [x] Add unit tests for `RoutingEngine` and `RescheduleEngine` (pure logic; DB-backed tests still TODO)

## License

Program data compiled from [hundredpushups.com](https://hundredpushups.com). App code is scaffolded for personal use.
