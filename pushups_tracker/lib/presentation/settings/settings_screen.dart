import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../../data/program_repository.dart';
import '../../services/app_settings.dart';
import '../../services/export_service.dart';
import '../../services/notification_service.dart';
import '../../services/progression_service.dart';
import '../../services/session_store.dart';
import '../program/program_screen.dart';
import '../widgets/profile_form.dart';
import 'profile_edit_screen.dart';

/// Spec §3.7: profile, sound/haptics, keep-awake, manual column override,
/// repeat a week, export, reset program.
class SettingsScreen extends StatefulWidget {
  final AppDatabase db;
  final ProgramRepository programRepo;
  final AppSettings settings;
  final ProgressionService progression;
  final ExportService exportService;
  final SessionStore sessionStore;
  final NotificationService notifications;

  const SettingsScreen({
    super.key,
    required this.db,
    required this.programRepo,
    required this.settings,
    required this.progression,
    required this.exportService,
    required this.sessionStore,
    required this.notifications,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await widget.db.getUser();
    if (mounted) setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: widget.settings,
        builder: (context, _) {
          final s = widget.settings;
          return ListView(
            children: [
              const _SectionHeader('Profile'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(_user == null || _user!.name.trim().isEmpty ? 'Your profile' : _user!.name),
                subtitle: Text(_profileSummary()),
                trailing: const Icon(Icons.chevron_right),
                enabled: _user != null && !_busy,
                onTap: _editProfile,
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('View program'),
                subtitle: const Text('Every week, day and column, plus the test gates'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProgramScreen(
                      programRepo: widget.programRepo,
                      db: widget.db,
                      initialWeek: (_user?.currentWeek ?? 1).clamp(1, 6),
                      initialColumn: _user?.currentColumn ?? 1,
                    ),
                  ),
                ),
              ),
              const Divider(),
              const _SectionHeader('Workout session'),
              SwitchListTile(
                title: const Text('Haptic feedback'),
                subtitle: const Text('Vibrate on each rep and when a rest ends'),
                value: s.haptics,
                onChanged: s.setHaptics,
              ),
              SwitchListTile(
                title: const Text('Countdown sound'),
                subtitle: const Text('Tick during the last 3 seconds of a rest'),
                value: s.sound,
                onChanged: s.setSound,
              ),
              SwitchListTile(
                title: const Text('Keep screen awake'),
                subtitle: const Text('Prevent the screen from locking during a workout'),
                value: s.keepAwake,
                onChanged: s.setKeepAwake,
              ),
              SwitchListTile(
                title: const Text('Rest-over alert'),
                subtitle: const Text('Notification when a rest ends while the screen is off'),
                value: s.restEndAlert,
                onChanged: s.setRestEndAlert,
              ),
              const Divider(),
              const _SectionHeader('Program (advanced)'),
              ListTile(
                leading: const Icon(Icons.view_column_outlined),
                title: const Text('Column override'),
                subtitle: Text(_user == null
                    ? '—'
                    : 'Currently Column ${_user!.currentColumn ?? '-'}. Normally set by test results only.'),
                enabled: _user != null && !_busy,
                onTap: _overrideColumn,
              ),
              ListTile(
                leading: const Icon(Icons.replay),
                title: const Text('Repeat a week'),
                subtitle: const Text('Go back to Day 1 of an earlier week'),
                enabled: _user != null && !_busy,
                onTap: _repeatWeek,
              ),
              const Divider(),
              const _SectionHeader('Data'),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Export data'),
                subtitle: const Text('CSV per table + JSON backup via the share sheet'),
                enabled: !_busy,
                onTap: _export,
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                title: Text('Reset program', style: TextStyle(color: theme.colorScheme.error)),
                subtitle: const Text('Deletes all history and starts onboarding again'),
                enabled: !_busy,
                onTap: _resetProgram,
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Program data v${widget.programRepo.program?['version'] ?? '?'} · hundredpushups.com',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------ actions

  String _profileSummary() {
    final u = _user;
    if (u == null) return '—';
    final parts = <String>[
      if (u.age != null) '${u.age} years',
      if (u.weightKg != null) '${u.weightKg!.toStringAsFixed(u.weightKg! % 1 == 0 ? 0 : 1)} kg',
      ProfileData.sexLabel(u.sex),
    ];
    return parts.join(' · ');
  }

  Future<void> _editProfile() async {
    final user = _user;
    if (user == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProfileEditScreen(db: widget.db, user: user)),
    );
    if (saved == true) await _loadUser();
  }

  Future<void> _overrideColumn() async {
    final current = _user?.currentColumn ?? 1;
    final chosen = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Column override'),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              'Columns are meant to change only at week boundaries, based on test results. '
              'Overriding applies from your next workout. Use this if a column feels clearly too easy or too hard.',
            ),
          ),
          for (var c = 1; c <= 3; c++)
            ListTile(
              leading: Icon(c == current ? Icons.radio_button_checked : Icons.radio_button_off),
              title: Text('Column $c'),
              onTap: () => Navigator.pop(ctx, c),
            ),
        ],
      ),
    );
    if (chosen == null || chosen == current) return;
    await _run(() => widget.progression.overrideColumn(chosen), 'Column set to $chosen for your next workout');
  }

  Future<void> _repeatWeek() async {
    final user = _user;
    if (user == null) return;
    final maxWeek = (user.pendingTest != null ? (user.currentWeek ?? 1) - 1 : (user.currentWeek ?? 1)).clamp(1, 6);
    final chosen = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Repeat which week?'),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text('Your schedule restarts at Day 1 of the chosen week, tomorrow or later. '
                'Completed workouts stay in your history.'),
          ),
          for (var w = 1; w <= maxWeek; w++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, w),
              child: Text('Week $w'),
            ),
        ],
      ),
    );
    if (chosen == null) return;
    await _run(() => widget.progression.repeatWeek(chosen), 'Schedule rebuilt from Week $chosen, Day 1');
  }

  Future<void> _export() async {
    await _run(() async {
      final n = await widget.exportService.shareExport();
      return '$n files exported';
    }, null);
  }

  Future<void> _resetProgram() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset program?'),
        content: const Text(
          'This permanently deletes your schedule, all workouts and all test results on this device. '
          'Consider exporting your data first.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE EVERYTHING'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await widget.notifications.cancelAll();
      await widget.sessionStore.clear();
      await widget.settings.reset();
      await widget.db.resetAll();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset failed: $e')));
    }
  }

  /// Runs an async action with a busy guard and surfaces the outcome.
  Future<void> _run(Future<Object?> Function() action, String? successMessage) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await action();
      final text = successMessage ?? (result is String ? result : null);
      if (text != null) messenger.showSnackBar(SnackBar(content: Text(text)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      await _loadUser();
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}
