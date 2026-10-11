import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../../data/program_repository.dart';
import '../../services/app_settings.dart';
import '../../services/export_service.dart';
import '../../services/notification_service.dart';
import '../../services/progression_service.dart';
import '../../services/reschedule_engine.dart';
import '../../services/session_store.dart';
import '../dashboard/dashboard_screen.dart';
import '../progress/progress_screen.dart';
import '../schedule/schedule_screen.dart';
import '../settings/settings_screen.dart';

/// Three-tab shell (Home · Progress · Schedule). Tabs stay alive in an
/// [IndexedStack]; [_refresh] ticks whenever a tab is shown so each screen can
/// reload its data without being rebuilt from scratch.
class HomeShell extends StatefulWidget {
  final AppDatabase db;
  final ProgramRepository programRepo;
  final RescheduleEngine rescheduleEngine;
  final ProgressionService progression;
  final NotificationService notifications;
  final SessionStore sessionStore;
  final AppSettings settings;
  final ExportService exportService;

  const HomeShell({
    super.key,
    required this.db,
    required this.programRepo,
    required this.rescheduleEngine,
    required this.progression,
    required this.notifications,
    required this.sessionStore,
    required this.settings,
    required this.exportService,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final ValueNotifier<int> _refresh = ValueNotifier<int>(0);

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    _refresh.value++;
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          db: widget.db,
          programRepo: widget.programRepo,
          settings: widget.settings,
          progression: widget.progression,
          exportService: widget.exportService,
          sessionStore: widget.sessionStore,
          notifications: widget.notifications,
        ),
      ),
    );
    _refresh.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            db: widget.db,
            programRepo: widget.programRepo,
            rescheduleEngine: widget.rescheduleEngine,
            sessionStore: widget.sessionStore,
            refresh: _refresh,
            onOpenSettings: _openSettings,
          ),
          ProgressScreen(db: widget.db, refresh: _refresh),
          ScheduleScreen(
            db: widget.db,
            rescheduleEngine: widget.rescheduleEngine,
            notifications: widget.notifications,
            refresh: _refresh,
            onSaved: () => _select(0),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Progress'),
          NavigationDestination(
              icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Schedule'),
        ],
      ),
    );
  }
}
