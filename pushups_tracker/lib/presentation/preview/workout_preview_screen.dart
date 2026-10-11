import 'package:flutter/material.dart';
import '../../domain/models/workout_plan.dart';
import '../widgets/workout_plan_card.dart';

/// Spec §3.8 — what the workout contains, before it is started.
///
/// Pops with `true` when the user taps START; the caller launches the session.
class WorkoutPreviewScreen extends StatelessWidget {
  final WorkoutPlan plan;

  /// Reps already performed per set when previewing a resume slot.
  final List<int?>? performed;

  /// Only the next pending slot (or a resume slot) may be started.
  final bool canStart;

  /// Shown instead of the start button when [canStart] is false.
  final String unavailableReason;

  const WorkoutPreviewScreen({
    super.key,
    required this.plan,
    this.performed,
    this.canStart = false,
    this.unavailableReason = 'You can start this workout from Home once it is your next due slot.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isResume = performed != null && performed!.any((p) => p != null);
    final done = performed?.where((p) => p != null).length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout preview')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  WorkoutPlanCard(plan: plan, performed: performed),
                  if (isResume) ...[
                    const SizedBox(height: 12),
                    Card(
                      color: theme.colorScheme.tertiaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.pause_circle_outline),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('$done of ${plan.setCount} sets already done. '
                                  'Resuming continues from set ${done + 1}.'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How to read this', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          const _Tip(
                            icon: Icons.add,
                            text: 'A "+" set means do at least that many reps, then as many more good-form '
                                'reps as you comfortably can. Don\'t push so hard that you damage muscle tissue.',
                          ),
                          _Tip(
                            icon: Icons.timer_outlined,
                            text: 'Rest ${plan.restSeconds} seconds between sets — longer if required. '
                                'The timer lets you add +15 s as often as you need.',
                          ),
                          const _Tip(
                            icon: Icons.view_column_outlined,
                            text: 'Your column is set by your last test and stays the same for the whole week.',
                          ),
                          const _Tip(
                            icon: Icons.water_drop_outlined,
                            text: 'Be well hydrated before you start.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: canStart
                  ? SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(isResume ? 'RESUME WORKOUT' : 'START WORKOUT'),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    )
                  : Text(
                      unavailableReason,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
