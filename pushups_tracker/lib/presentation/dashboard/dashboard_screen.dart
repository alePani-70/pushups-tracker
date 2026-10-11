import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';
import '../../data/program_repository.dart';
import '../../domain/models/workout_plan.dart';
import '../../services/reschedule_engine.dart';
import '../../services/session_store.dart';
import '../preview/workout_preview_screen.dart';
import '../program/program_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AppDatabase db;
  final ProgramRepository programRepo;
  final RescheduleEngine rescheduleEngine;
  final SessionStore sessionStore;

  /// Ticks when the shell wants this tab to reload.
  final Listenable? refresh;
  final VoidCallback? onOpenSettings;

  const DashboardScreen({
    super.key,
    required this.db,
    required this.programRepo,
    required this.rescheduleEngine,
    required this.sessionStore,
    this.refresh,
    this.onOpenSettings,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  User? _user;
  List<ScheduledSlot> _pending = const [];
  int _totalPushups = 0;
  int _completedWorkouts = 0;
  int _bestSet = 0;
  Map<String, dynamic>? _interrupted; // SessionStore snapshot
  int? _resumeDone;
  int? _resumeTotal;
  bool _loading = true;
  bool _notificationsRefreshed = false;
  DateTime _now = DateTime.now();
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.refresh?.addListener(_loadData);
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadData();
  }

  @override
  void dispose() {
    _clock?.cancel();
    widget.refresh?.removeListener(_loadData);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check for overdue slots and re-register reminders (time zone may have
  // changed) whenever the app comes back to the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notificationsRefreshed = false;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final missed = await widget.rescheduleEngine.processOverdueSlots();
    if (!_notificationsRefreshed) {
      _notificationsRefreshed = true;
      if (missed == 0) await widget.rescheduleEngine.refreshNotifications();
    }

    final user = await widget.db.getUser();
    final pending = await widget.db.getPendingSlots(limit: 6);
    final total = await widget.db.getTotalPushups();
    final completed = await widget.db.getCompletedWorkoutCount();
    final best = await widget.db.getBestSet();
    final snapshot = await widget.sessionStore.load();

    int? resumeDone;
    int? resumeTotal;
    if (pending.isNotEmpty && pending.first.resumeWorkoutId != null) {
      final sets = await widget.db.getSetsForWorkout(pending.first.resumeWorkoutId!);
      resumeTotal = sets.length;
      resumeDone = sets.where((s) => s.performed != null).length;
    }

    if (!mounted) return;
    setState(() {
      _user = user;
      _pending = pending;
      _totalPushups = total;
      _completedWorkouts = completed;
      _bestSet = best;
      _interrupted = snapshot;
      _resumeDone = resumeDone;
      _resumeTotal = resumeTotal;
      _loading = false;
      _now = DateTime.now();
    });

    if (missed > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(missed == 1
            ? 'A missed workout was moved to your next slot.'
            : '$missed missed slots were moved forward.'),
      ));
    }
  }

  // ------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('100 Pushups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'View program',
            onPressed: _openProgram,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: widget.onOpenSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_interrupted != null) ...[
                    _buildInterruptedCard(theme),
                    const SizedBox(height: 16),
                  ],
                  if (user?.programCompletedAt != null) ...[
                    _buildCompletedCard(theme),
                    const SizedBox(height: 16),
                  ],
                  if (user != null) ...[
                    _buildPositionCard(theme, user),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      _StatCard(label: 'Total Reps', value: '$_totalPushups'),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Workouts', value: '$_completedWorkouts'),
                      const SizedBox(width: 12),
                      _StatCard(label: 'Best Set', value: '$_bestSet'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_pending.isNotEmpty) ...[
                    _buildNextUpCard(theme, _pending.first),
                    const SizedBox(height: 16),
                  ],
                  if (_pending.length > 1) ...[
                    Text('Upcoming', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    // Only the first pending slot can be started: later ones
                    // depend on the outcome of the earlier workouts/tests, so
                    // tapping them opens a read-only preview.
                    ..._pending.skip(1).take(4).map((slot) {
                      final plan = _planFor(slot);
                      return ListTile(
                        leading: Icon(_slotIcon(slot.kind)),
                        title: Text(_slotLabel(slot)),
                        subtitle: Text(plan == null
                            ? _formatDue(slot.dueAt)
                            : '${_formatDue(slot.dueAt)} · ${plan.summary}'),
                        trailing: plan == null ? null : const Icon(Icons.chevron_right),
                        onTap: plan == null ? null : () => _openPreview(slot, canStart: false),
                      );
                    }),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildInterruptedCard(ThemeData theme) {
    final ws = _interrupted?['workout'] as Map?;
    final week = ws?['week'];
    final day = ws?['day'];
    final setIdx = ws?['currentSetIndex'] as int? ?? 0;
    final sets = ws?['sets'] as List? ?? const [];
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Interrupted workout', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Week $week · Day ${day is int ? day + 1 : '-'} — set ${setIdx + 1} of ${sets.length}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _openRoute('/workout', {'restore': _interrupted}),
                    child: const Text('RESUME'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () async {
                    await widget.sessionStore.clear();
                    await _loadData();
                  },
                  child: const Text('DISCARD'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.emoji_events, size: 40),
            SizedBox(width: 16),
            Expanded(child: Text('Program complete — 100 pushups reached! 🎉')),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCard(ThemeData theme, User user) {
    final pendingTest = user.pendingTest;
    final String position;
    if (pendingTest == 'final') {
      position = 'Week 6 complete · Final test due';
    } else if (pendingTest != null) {
      position = 'Week ${(user.currentWeek ?? 1) - 1} complete · Exhaustion test due';
    } else {
      position = 'Week ${user.currentWeek ?? '-'} · Day ${user.currentDay != null ? user.currentDay! + 1 : '-'}'
          ' · Column ${user.currentColumn ?? '-'}';
    }

    final totalDays = widget.programRepo.totalWorkoutDays;
    final fraction = totalDays == 0 ? 0.0 : (_completedWorkouts / totalDays).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name.trim().isEmpty ? 'Current Position' : 'Hi ${user.name.trim()} · current position',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(position, style: theme.textTheme.headlineSmall),
            if (pendingTest == null && user.currentColumn != null)
              Text(
                'Column ${user.currentColumn}: test result ${widget.programRepo.columnLabel(user.currentWeek ?? 1, user.currentColumn!)}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: fraction, minHeight: 8, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 4),
            Text('${(fraction * 100).round()}% of program workouts completed', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildNextUpCard(ThemeData theme, ScheduledSlot slot) {
    final isResume = slot.resumeWorkoutId != null;
    final isTest = slot.kind != 'workout';
    final overdue = slot.dueAt.isBefore(_now);
    final plan = _planFor(slot);

    return Card(
      color: overdue ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(overdue ? 'Due now' : 'Next Up', style: theme.textTheme.titleMedium)),
                Text(_countdown(slot.dueAt), style: theme.textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 8),
            Text(_slotLabel(slot), style: theme.textTheme.headlineSmall),
            Text(_formatDue(slot.dueAt), style: theme.textTheme.bodyMedium),
            if (plan != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _openPreview(slot, canStart: true),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.summary,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        '${plan.columnTitle} · rest ${plan.restSeconds} s · min ${plan.totalMinReps} reps · ~${plan.estimatedMinutes} min',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (isResume && _resumeTotal != null) ...[
              const SizedBox(height: 8),
              Text('Resume incomplete workout — $_resumeDone of $_resumeTotal sets done',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            ] else if (slot.notes != null) ...[
              const SizedBox(height: 8),
              Text(slot.notes!, style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _openSlot(slot),
                    child: Text(isResume
                        ? 'RESUME WORKOUT'
                        : isTest
                            ? 'TAKE TEST'
                            : 'START WORKOUT'),
                  ),
                ),
                if (plan != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('DETAILS'),
                    onPressed: () => _openPreview(slot, canStart: true),
                  ),
                ],
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => _skipSlot(slot),
                  child: const Text('SKIP'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  WorkoutPlan? _planFor(ScheduledSlot slot) {
    if (slot.kind != 'workout' || slot.week == null) return null;
    return widget.programRepo.planFor(
      week: slot.week!,
      day: slot.day ?? 0,
      column: _user?.currentColumn ?? 1,
    );
  }

  /// Spec §3.8: show the sets before starting. Only the first pending slot can
  /// be started from the preview; later slots are read-only.
  Future<void> _openPreview(ScheduledSlot slot, {required bool canStart}) async {
    final plan = _planFor(slot);
    if (plan == null) return;

    List<int?>? performed;
    if (slot.resumeWorkoutId != null) {
      final sets = await widget.db.getSetsForWorkout(slot.resumeWorkoutId!);
      if (sets.length == plan.setCount) performed = sets.map((s) => s.performed).toList();
    }
    if (!mounted) return;

    final start = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutPreviewScreen(
          plan: plan,
          performed: performed,
          canStart: canStart,
          unavailableReason: 'Workouts are started in order. This one becomes available after '
              '${_pending.isNotEmpty ? _slotLabel(_pending.first) : 'the previous slot'}.',
        ),
      ),
    );
    if (start == true && mounted) await _openSlot(slot);
  }

  Future<void> _openProgram() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramScreen(
          programRepo: widget.programRepo,
          db: widget.db,
          initialWeek: (_user?.currentWeek ?? 1).clamp(1, 6),
          initialColumn: _user?.currentColumn ?? 1,
        ),
      ),
    );
  }

  // ------------------------------------------------------------ actions

  Future<void> _skipSlot(ScheduledSlot slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Skip this slot?'),
        content: Text('${_slotLabel(slot)} will move to your next workout day. '
            'Everything after it shifts along.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SKIP')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    await widget.rescheduleEngine.handleMissedSlot(slot.id, status: 'skipped');
    await _loadData();
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text('${_slotLabel(slot)} skipped'),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () async {
          await widget.rescheduleEngine.undoSkip(slot.id);
          await _loadData();
        },
      ),
    ));
  }

  Future<void> _openSlot(ScheduledSlot slot) async {
    switch (slot.kind) {
      case 'exhaustion':
        await _openRoute('/test', {'kind': 'exhaustion', 'slotId': slot.id});
        break;
      case 'final_test':
        await _openRoute('/test', {'kind': 'final', 'slotId': slot.id});
        break;
      default:
        await _openRoute('/workout', {
          'week': slot.week ?? _user?.currentWeek ?? 1,
          'day': slot.day ?? 0,
          'column': _user?.currentColumn ?? 1,
          'slotId': slot.id,
          'resumeWorkoutId': slot.resumeWorkoutId,
        });
    }
  }

  Future<void> _openRoute(String route, Map<String, dynamic> args) async {
    final result = await Navigator.pushNamed(context, route, arguments: args);
    if (!mounted) return;
    await _loadData();
    if (result is String && result.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  // ------------------------------------------------------------ formatting

  String _slotLabel(ScheduledSlot slot) {
    switch (slot.kind) {
      case 'workout':
        return 'Week ${slot.week} · Day ${slot.day != null ? slot.day! + 1 : ''}';
      case 'exhaustion':
        return 'Exhaustion Test (after Week ${slot.week})';
      case 'final_test':
        return 'Final Test: 100 Pushups';
      default:
        return 'Workout';
    }
  }

  IconData _slotIcon(String kind) {
    switch (kind) {
      case 'exhaustion':
      case 'final_test':
        return Icons.fitness_center;
      default:
        return Icons.sports_gymnastics;
    }
  }

  String _countdown(DateTime dt) {
    final diff = dt.difference(_now);
    if (diff.isNegative) return 'now';
    if (diff.inDays >= 1) return 'in ${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours >= 1) return 'in ${diff.inHours}h ${diff.inMinutes % 60}m';
    return 'in ${math.max(1, diff.inMinutes)} min';
  }

  String _formatDue(DateTime dt) {
    final time = DateFormat.Hm().format(dt);

    if (dt.isBefore(_now)) {
      final late = _now.difference(dt);
      return late < RescheduleEngine.grace ? 'Due now (scheduled $time)' : 'Overdue';
    }

    final days = RescheduleEngine.startOfDay(dt).difference(RescheduleEngine.startOfDay(_now)).inDays;
    if (days == 0) return 'Today at $time';
    if (days == 1) return 'Tomorrow at $time';
    return '${DateFormat('EEE d MMM').format(dt)} at $time';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(value, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
