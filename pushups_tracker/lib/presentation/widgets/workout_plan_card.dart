import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../domain/models/workout_plan.dart';

/// Set table for one workout day (spec §3.8): set number, prescribed reps,
/// optionally the reps already performed, plus rest and estimated duration.
class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlan plan;

  /// Reps already performed per set (null = not attempted). Same length as
  /// `plan.sets` when provided.
  final List<int?>? performed;

  /// Whether to show the Week/Day/Column header inside the card.
  final bool showHeader;

  const WorkoutPlanCard({
    super.key,
    required this.plan,
    this.performed,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasPerformed = performed != null && performed!.length == plan.sets.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              Text(plan.title, style: theme.textTheme.titleLarge),
              Text(plan.columnTitle, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.outline)),
              const SizedBox(height: 12),
            ],
            Table(
              columnWidths: const {
                0: FixedColumnWidth(64),
                1: FlexColumnWidth(),
                2: FixedColumnWidth(72),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    _cell(context, 'SET', muted: true),
                    _cell(context, 'REPS', muted: true),
                    _cell(context, hasPerformed ? 'DONE' : '', muted: true, right: true),
                  ],
                ),
                for (final set in plan.sets)
                  TableRow(
                    decoration: hasPerformed && performed![set.index] != null
                        ? BoxDecoration(color: AppColors.of(context).success.withValues(alpha: 0.12))
                        : null,
                    children: [
                      _cell(context, '${set.index + 1}'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Text(
                              set.label,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (set.isPlus) ...[
                              const SizedBox(width: 8),
                              Text('at least, then as many as you can',
                                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline)),
                            ],
                          ],
                        ),
                      ),
                      _cell(
                        context,
                        hasPerformed ? (performed![set.index]?.toString() ?? '—') : '',
                        right: true,
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _fact(context, Icons.timer_outlined, 'Rest ${plan.restSeconds} s between sets'),
                _fact(context, Icons.fitness_center, 'Min ${plan.totalMinReps} reps'),
                _fact(context, Icons.schedule, '~${plan.estimatedMinutes} min'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, String text, {bool muted = false, bool right = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: muted
            ? theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, letterSpacing: 1)
            : theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _fact(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
