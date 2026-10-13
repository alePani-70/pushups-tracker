import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/database.dart';
import 'data/program_repository.dart';
import 'domain/routing/routing_engine.dart';
import 'services/app_settings.dart';
import 'services/export_service.dart';
import 'services/notification_service.dart';
import 'services/progression_service.dart';
import 'services/reschedule_engine.dart';
import 'services/session_store.dart';
import 'presentation/home/home_shell.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/test/test_screen.dart';
import 'presentation/workout_session/bloc/workout_bloc.dart';
import 'presentation/workout_session/workout_session_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final programRepo = ProgramRepository();
  await programRepo.load();

  final notifications = NotificationService();
  await notifications.init();

  final settings = AppSettings();
  await settings.load();

  final routingEngine = RoutingEngine(programRepo);
  final rescheduleEngine = RescheduleEngine(db, notifications, programRepo);
  final progression = ProgressionService(db, programRepo, routingEngine, rescheduleEngine);
  final sessionStore = SessionStore();
  final exportService = ExportService(db);

  final user = await db.getUser();
  final hasCompletedOnboarding = user?.onboardingComplete ?? false;

  runApp(PushupsApp(
    db: db,
    programRepo: programRepo,
    routingEngine: routingEngine,
    rescheduleEngine: rescheduleEngine,
    progression: progression,
    notifications: notifications,
    sessionStore: sessionStore,
    settings: settings,
    exportService: exportService,
    initialRoute: hasCompletedOnboarding ? '/dashboard' : '/onboarding',
  ));
}

class PushupsApp extends StatelessWidget {
  final AppDatabase db;
  final ProgramRepository programRepo;
  final RoutingEngine routingEngine;
  final RescheduleEngine rescheduleEngine;
  final ProgressionService progression;
  final NotificationService notifications;
  final SessionStore sessionStore;
  final AppSettings settings;
  final ExportService exportService;
  final String initialRoute;

  const PushupsApp({
    super.key,
    required this.db,
    required this.programRepo,
    required this.routingEngine,
    required this.rescheduleEngine,
    required this.progression,
    required this.notifications,
    required this.sessionStore,
    required this.settings,
    required this.exportService,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '100 Pushups',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      routes: {
        '/onboarding': (context) => OnboardingScreen(
              db: db,
              programRepo: programRepo,
              routingEngine: routingEngine,
              rescheduleEngine: rescheduleEngine,
              notifications: notifications,
            ),
        '/dashboard': (context) => HomeShell(
              db: db,
              programRepo: programRepo,
              rescheduleEngine: rescheduleEngine,
              progression: progression,
              notifications: notifications,
              sessionStore: sessionStore,
              settings: settings,
              exportService: exportService,
            ),
        '/workout': (context) => BlocProvider(
              create: (_) => WorkoutBloc(db, programRepo, progression, sessionStore, notifications, settings),
              child: WorkoutSessionScreen(settings: settings),
            ),
        '/test': (context) => TestScreen(
              db: db,
              programRepo: programRepo,
              progression: progression,
            ),
      },
    );
  }
}
