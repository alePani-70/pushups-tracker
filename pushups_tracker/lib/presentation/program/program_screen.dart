import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../../data/program_repository.dart';
import '../preview/workout_preview_screen.dart';

/// Spec §3.9 — browse the whole program: every week, day and column, the
/// test gates with their routing thresholds, and the rank table.
class ProgramScreen extends StatefulWidget {
  final ProgramRepository programRepo;

  /// Optional: used to mark completed days and highlight the next due day.
  final AppDatabase? db;
  final int initialWeek;
  final int initialColumn;

  const ProgramScreen({
    super.key,
    required this.programRepo,
    this.db,
    this.initialWeek = 1,
    this.initialColumn = 1,
  });

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  late int _week;
  late int _column;
  Set<String> _completed = const {};
  User? _user;

  @override
  void initState() {
    super.initState();
    _week = widget.initialWeek.clamp(1, 6);
    _column = widget.initialColumn.clamp(1, 3);
    _load();
  }

  Future<void> _load() async {
    final db = widget.db;
    if (db == null) return;
    final completed = await db.getCompletedDayKeys();
    final user = await db.getUser();
    if (!mounted) return;
    setState(() {
      _completed = completed;
      _user = user;
    });
  }

  bool _isNextDue(int week, int day) =>
      _user != null && _user!.pendingTest == null && _user!.currentWeek == week && _user!.currentDay == day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = widget.programRepo;
    final daysInWeek = repo.daysInWeek(_week);
    final test = repo.getExhaustionTestAfterWeek(_week);

    return Scaffold(
      appBar: AppBar(title: const Text('Program')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Week', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              for (var w = 1; w <= 6; w++)
                ChoiceChip(
                  label: Text('$w'),
                  selected: _week == w,
                  onSelected: (_) => setState(() => _week = w),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Column', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          SegmentedButton<int>(
            segments: [
              for (var c = 1; c <= 3; c++)
                ButtonSegment(value: c, label: Text('$c · ${repo.columnLabel(_week, c)}')),
            ],
            selected: {_column},
            onSelectionChanged: (s) => setState(() => _column = s.first),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.currentColumn == _column
                ? 'This is your current column.'
                : 'Column labels are the test results that lead to each column.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 16),
          for (var d = 0; d < daysInWeek; d++) _dayCard(theme, d),
          if (test != null) _testCard(theme, test),
          if (_week == 6) _finalCard(theme),
          const SizedBox(height: 24),
          _initialRoutingCard(theme),
          const SizedBox(height: 12),
          _rankTable(theme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _dayCard(ThemeData theme, int day) {
    final plan = widget.programRepo.planFor(week: _week, day: day, column: _column);
    if (plan == null) return const SizedBox.shrink();
    final done = _completed.contains('$_week:$day');
    final next = _isNextDue(_week, day);
    final scheme = theme.colorScheme;

    return Card(
      color: next ? scheme.primaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          done ? Icons.check_circle : (next ? Icons.play_circle_outline : Icons.circle_outlined),
          color: done ? Colors.green : (next ? scheme.primary : scheme.outline),
        ),
        title: Text('Day ${day + 1}${next ? ' · next up' : done ? ' · done' : ''}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.summary, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('Rest ${plan.restSeconds} s · min ${plan.totalMinReps} reps · ~${plan.estimatedMinutes} min',
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutPreviewScreen(
              plan: plan,
              canStart: false,
              unavailableReason: next
                  ? 'This is your next workout — start it from Home.'
                  : 'Workouts are started from Home when they come up in your schedule.',
            ),
          ),
        ),
      ),
    );
  }

  Widget _testCard(ThemeData theme, Map<String, dynamic> test) {
    final routing = (test['routing'] as List).cast<Map<String, dynamic>>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Exhaustion test (${test['id']}) after Week $_week', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Max good-form pushups, ideally within ${test['windowDays']} days of finishing the week. '
              'The result picks your column for Week ${_week + 1}:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(widget.programRepo.describeRouting(routing),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _finalCard(ThemeData theme) {
    final ft = widget.programRepo.finalTest;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Text('Final test after Week 6', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rest ${ft?['restDaysBefore'] ?? 2} days, then go for ${ft?['goal'] ?? 100} consecutive pushups. '
              '${ft?['advice'] ?? ''}\n\nNot there yet? ${ft?['onFail'] ?? 'Repeat Week 5 or 6, then retest.'}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialRoutingCard(ThemeData theme) {
    final routing =
        (widget.programRepo.initialTest?['startRouting'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Initial test → starting point', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(widget.programRepo.describeRouting(routing), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _rankTable(ThemeData theme) {
    final ranks = widget.programRepo.ranks;
    if (ranks.isEmpty) return const SizedBox.shrink();
    final age = _user?.age;
    final myBand = age == null ? null : ProgramRepository.ageBandKey(age);
    final scheme = theme.colorScheme;

    TextStyle? style(String key) => theme.textTheme.bodySmall?.copyWith(
          fontWeight: key == myBand ? FontWeight.bold : null,
          color: key == myBand ? scheme.primary : null,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fitness rank by age (context only)', style: theme.textTheme.titleMedium),
            if (age != null)
              Text('Your band: ${ProgramRepository.ageBandLabel(age)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline)),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {0: FixedColumnWidth(52)},
              children: [
                TableRow(children: [
                  Text('Rank', style: theme.textTheme.labelSmall),
                  Text('<40', style: style('age_lt40')),
                  Text('40–55', style: style('age_40_55')),
                  Text('>55', style: style('age_gt55')),
                ]),
                for (final r in ranks)
                  TableRow(children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('${r['rank']}')),
                    Text('${r['age_lt40']}', style: style('age_lt40')),
                    Text('${r['age_40_55']}', style: style('age_40_55')),
                    Text('${r['age_gt55']}', style: style('age_gt55')),
                  ]),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Rank 1: consider knee or incline pushups first. Rank 6–7: you may want a tougher plan.',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
