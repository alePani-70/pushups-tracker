import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';

class ProgressScreen extends StatefulWidget {
  final AppDatabase db;

  /// Ticks when the shell wants this tab to reload.
  final Listenable? refresh;

  const ProgressScreen({super.key, required this.db, this.refresh});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _totalPushups = 0;
  int _completedWorkouts = 0;
  int _bestSet = 0;
  int _bestTest = 0;
  List<Test> _tests = const [];
  List<PlusSetPoint> _plusSets = const [];
  List<WorkoutSummary> _workouts = const [];
  List<ScheduledSlot> _slotHistory = const [];
  List<Map<String, dynamic>> _weekly = const [];

  @override
  void initState() {
    super.initState();
    widget.refresh?.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    widget.refresh?.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final total = await widget.db.getTotalPushups();
    final completed = await widget.db.getCompletedWorkoutCount();
    final best = await widget.db.getBestSet();
    final bestTest = await widget.db.getBestTest();
    final tests = await widget.db.getAllTests();
    final plus = await widget.db.getPlusSetHistory();
    final workouts = await widget.db.getWorkoutSummaries();
    final slotHistory = await widget.db.getSlotHistory();
    final weekly = await widget.db.getWeeklyVolume();

    if (!mounted) return;
    setState(() {
      _totalPushups = total;
      _completedWorkouts = completed;
      _bestSet = best;
      _bestTest = bestTest;
      _tests = tests;
      _plusSets = plus;
      _workouts = workouts;
      _slotHistory = slotHistory;
      _weekly = weekly;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _StatCard(label: 'Total Reps', value: '$_totalPushups'),
                const SizedBox(width: 8),
                _StatCard(label: 'Workouts', value: '$_completedWorkouts'),
                const SizedBox(width: 8),
                _StatCard(label: 'Best Set', value: '$_bestSet'),
                const SizedBox(width: 8),
                _StatCard(label: 'Best Test', value: '$_bestTest'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Max Reps Over Time', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                _LegendDot(color: theme.colorScheme.primary, label: 'Tests'),
                const SizedBox(width: 16),
                _LegendDot(color: theme.colorScheme.secondary, label: 'Best + set per workout'),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: _tests.isEmpty && _plusSets.isEmpty
                  ? const Center(child: Text('No test data yet'))
                  : _MaxRepsChart(tests: _tests, plusSets: _plusSets),
            ),
            const SizedBox(height: 24),
            Text('Reps per Week', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: _weekly.isEmpty ? const Center(child: Text('No workouts yet')) : _buildWeeklyChart(theme),
            ),
            const SizedBox(height: 24),
            Text('History', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(ThemeData theme) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _weekly.length) return const SizedBox.shrink();
                final label = (_weekly[index]['week'] as String).split('-').last; // week number
                return Text('W$label', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (var i = 0; i < _weekly.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (_weekly[i]['total'] as int).toDouble(),
                  color: theme.colorScheme.secondary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeline() {
    final items = <_TimelineItem>[
      for (final test in _tests)
        _TimelineItem(
          date: test.takenAt,
          tile: ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.orange),
            title: Text('${test.kind.toUpperCase()} TEST'),
            subtitle: Text('${test.result} reps'),
            trailing: Text(_formatDate(test.takenAt)),
          ),
        ),
      for (final w in _workouts)
        _TimelineItem(
          date: w.date ?? DateTime.fromMillisecondsSinceEpoch(0),
          tile: ListTile(
            leading: Icon(
              w.status == 'completed' ? Icons.check_circle : Icons.pause_circle_outline,
              color: w.status == 'completed' ? Colors.green : Colors.amber,
            ),
            title: Text('Week ${w.week} · Day ${w.day + 1}${w.repeatFlag ? ' · repeat' : ''}'),
            subtitle: Text(w.status == 'completed'
                ? 'Column ${w.column} · ${w.totalReps} reps'
                : 'Incomplete — ${w.doneSets}/${w.totalSets} sets · ${w.totalReps} reps'),
            trailing: Text(w.date == null ? '' : _formatDate(w.date!)),
          ),
        ),
      for (final s in _slotHistory)
        _TimelineItem(
          date: s.dueAt,
          tile: ListTile(
            leading: Icon(
              s.status == 'skipped' ? Icons.skip_next : Icons.event_busy,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(_slotLabel(s)),
            subtitle: Text(s.status == 'skipped' ? 'Skipped — moved forward' : 'Missed — moved forward'),
            trailing: Text(_formatDate(s.dueAt)),
          ),
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (items.isEmpty) {
      return const [ListTile(title: Text('No history yet. Complete your first workout!'))];
    }
    return items.map((i) => i.tile).toList();
  }

  String _slotLabel(ScheduledSlot slot) {
    switch (slot.kind) {
      case 'workout':
        return 'Week ${slot.week} · Day ${slot.day != null ? slot.day! + 1 : ''}';
      case 'exhaustion':
        return 'Exhaustion Test (after Week ${slot.week})';
      case 'final_test':
        return 'Final Test';
      default:
        return 'Workout';
    }
  }

  String _formatDate(DateTime dt) => DateFormat('d MMM yyyy').format(dt);
}

/// Line of test results over real dates, with each workout's best `+` set as
/// secondary dots. Tap a point for details.
class _MaxRepsChart extends StatelessWidget {
  final List<Test> tests;
  final List<PlusSetPoint> plusSets;

  const _MaxRepsChart({required this.tests, required this.plusSets});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allDates = [...tests.map((t) => t.takenAt), ...plusSets.map((p) => p.date)];
    final earliest = allDates.reduce((a, b) => a.isBefore(b) ? a : b);
    final origin = DateTime(earliest.year, earliest.month, earliest.day);
    double x(DateTime d) => d.difference(origin).inMinutes / 1440.0;

    final testSpots = [for (final t in tests) FlSpot(x(t.takenAt), t.result.toDouble())];
    final plusSpots = [for (final p in plusSets) FlSpot(x(p.date), p.best.toDouble())];
    final allSpots = [...testSpots, ...plusSpots];
    final maxX = allSpots.fold<double>(0, (m, s) => math.max(m, s.x));
    final maxY = allSpots.fold<double>(0, (m, s) => math.max(m, s.y));
    final interval = math.max(1.0, (maxX / 4).ceilToDouble());

    // Series are added only when non-empty; remember which bar index is which.
    final series = <String>[];
    final bars = <LineChartBarData>[];
    if (testSpots.isNotEmpty) {
      series.add('test');
      bars.add(LineChartBarData(
        spots: testSpots,
        isCurved: false,
        barWidth: 3,
        color: theme.colorScheme.primary,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: true, color: theme.colorScheme.primary.withValues(alpha: 0.15)),
      ));
    }
    if (plusSpots.isNotEmpty) {
      series.add('plus');
      bars.add(LineChartBarData(
        spots: plusSpots,
        barWidth: 0,
        color: Colors.transparent,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
            radius: 3.5,
            color: theme.colorScheme.secondary,
            strokeWidth: 0,
          ),
        ),
      ));
    }

    return LineChart(
      LineChartData(
        minX: -0.5,
        maxX: maxX + 0.5,
        minY: 0,
        maxY: math.max(10, (maxY * 1.15).ceilToDouble()),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > maxX + 0.5) return const SizedBox.shrink();
                final date = origin.add(Duration(days: value.round()));
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat('d MMM').format(date), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => touched.map((spot) {
              final kind = series[spot.barIndex];
              final style = TextStyle(color: theme.colorScheme.onInverseSurface, fontSize: 12);
              if (kind == 'test') {
                final t = tests[spot.spotIndex];
                return LineTooltipItem(
                  '${t.kind[0].toUpperCase()}${t.kind.substring(1)} test · ${t.result} reps\n'
                  '${DateFormat('d MMM yyyy').format(t.takenAt)}',
                  style,
                );
              }
              final p = plusSets[spot.spotIndex];
              return LineTooltipItem(
                'W${p.week} D${p.day + 1} · ${p.prescribed}+ set: ${p.best} reps\n'
                '${DateFormat('d MMM yyyy').format(p.date)}',
                style,
              );
            }).toList(),
          ),
        ),
        lineBarsData: bars,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _TimelineItem {
  final DateTime date;
  final Widget tile;
  const _TimelineItem({required this.date, required this.tile});
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            children: [
              Text(value, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
