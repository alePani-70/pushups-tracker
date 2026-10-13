import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/models/workout_state.dart';
import '../../services/app_settings.dart';
import 'bloc/workout_bloc.dart';

/// Route arguments (all optional except week/day/column for a fresh start):
/// `week`, `day` (0-based), `column`, `slotId`, `resumeWorkoutId`,
/// or `restore` (a SessionStore snapshot map) to continue an interrupted session.
class WorkoutSessionScreen extends StatefulWidget {
  final AppSettings settings;

  const WorkoutSessionScreen({super.key, required this.settings});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  bool _started = false;
  bool _saving = false;
  bool _completeDialogShown = false;
  WorkoutBlocState? _previous;
  static Future<bool>? _hasVibrator;

  @override
  void initState() {
    super.initState();
    if (widget.settings.keepAwake) WakelockPlus.enable();
    _hasVibrator ??= Vibration.hasVibrator();
  }

  // ModalRoute.of() is an inherited lookup and must not run in initState.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bloc = context.read<WorkoutBloc>();
    if (args == null) return;

    final restore = args['restore'];
    if (restore is Map) {
      bloc.add(WorkoutRestored(Map<String, dynamic>.from(restore)));
    } else {
      bloc.add(WorkoutStarted(
        week: args['week'] as int,
        day: args['day'] as int,
        column: args['column'] as int,
        slotId: args['slotId'] as int?,
        resumeWorkoutId: args['resumeWorkoutId'] as int?,
      ));
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  // ------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Leave workout',
            onPressed: _handleBack,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save & exit',
              onPressed: _saving ? null : _saveAndExit,
            ),
          ],
        ),
        body: BlocConsumer<WorkoutBloc, WorkoutBlocState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status ||
              prev.error != curr.error ||
              prev.workout?.restSecondsRemaining != curr.workout?.restSecondsRemaining,
          listener: _onStateChanged,
          builder: (context, state) {
            if (state.status == WorkoutBlocStatus.error && state.workout == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.error ?? 'Something went wrong', textAlign: TextAlign.center),
                ),
              );
            }
            if (state.workout == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final ws = state.workout!;
            return SafeArea(
              child: Column(
                children: [
                  _buildHeader(ws, state.status),
                  const Divider(),
                  Expanded(child: _buildMainContent(ws, state.status)),
                  _buildControls(ws, state.status),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, WorkoutBlocState state) {
    final prev = _previous;
    _previous = state;

    // Ticking during the last 3 seconds of a rest.
    if (state.status == WorkoutBlocStatus.resting && prev?.status == WorkoutBlocStatus.resting) {
      final remaining = state.workout?.restSecondsRemaining ?? 0;
      if (remaining > 0 && remaining <= 3 && remaining != prev?.workout?.restSecondsRemaining) {
        if (widget.settings.sound) SystemSound.play(SystemSoundType.click);
        _vibrate(15);
      }
    }

    if (prev?.status == state.status && prev?.error == state.error) return;

    switch (state.status) {
      case WorkoutBlocStatus.resting:
        _vibrate(30);
        break;
      case WorkoutBlocStatus.active:
        // Rest ran out on its own (not skipped): strong buzz, as per spec §6.
        if (prev?.status == WorkoutBlocStatus.resting && (prev?.workout?.restSecondsRemaining ?? 99) <= 1) {
          _vibrate(400);
        }
        if (state.error != null) _showError(state.error!);
        break;
      case WorkoutBlocStatus.complete:
        _vibrate(200);
        if (!_completeDialogShown) {
          _completeDialogShown = true;
          _showCompleteDialog(state);
        }
        break;
      case WorkoutBlocStatus.error:
        if (state.error != null) _showError(state.error!);
        break;
      default:
        if (state.error != null) _showError(state.error!);
    }
  }

  Widget _buildHeader(WorkoutState ws, WorkoutBlocStatus status) {
    final theme = Theme.of(context);
    final setLabel = status == WorkoutBlocStatus.resting
        ? 'Set ${ws.currentSetIndex + 1} done · resting'
        : status == WorkoutBlocStatus.complete
            ? 'All ${ws.totalSets} sets done'
            : 'Set ${ws.currentSetIndex + 1} / ${ws.totalSets}';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Week ${ws.week}', style: theme.textTheme.titleMedium),
              const SizedBox(width: 16),
              Text('Day ${ws.day + 1}', style: theme.textTheme.titleMedium),
              const SizedBox(width: 16),
              Text('Col ${ws.column}', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(setLabel, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildMainContent(WorkoutState ws, WorkoutBlocStatus status) {
    final theme = Theme.of(context);

    if (status == WorkoutBlocStatus.resting) {
      return _RestTimer(
        secondsRemaining: ws.restSecondsRemaining,
        totalSeconds: ws.restDurationSeconds,
        nextSet: ws.nextSet,
      );
    }

    if (status == WorkoutBlocStatus.complete || status == WorkoutBlocStatus.saving || status == WorkoutBlocStatus.saved) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 72),
            const SizedBox(height: 16),
            Text('Workout complete!', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('${ws.totalReps} reps across ${ws.totalSets} sets', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            _setChips(ws),
          ],
        ),
      );
    }

    final currentSet = ws.currentSet;
    if (currentSet == null) {
      return const Center(child: Text('Workout complete!'));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentSet.label,
          style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 120),
        ),
        const SizedBox(height: 8),
        Text(
          currentSet.isPlus ? 'Minimum reps, then as many as you can' : 'Good-form pushups',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        Text(
          '${currentSet.performed ?? 0}',
          style: theme.textTheme.displayMedium?.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 16),
        _setChips(ws),
      ],
    );
  }

  Widget _setChips(WorkoutState ws) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: ws.sets.map((set) {
        final isCurrent = set.index == ws.currentSetIndex && ws.status == WorkoutStatus.active;
        final isDone = set.performed != null && !isCurrent;
        return Chip(
          label: Text(isDone ? '${set.label} → ${set.performed}' : set.label),
          labelStyle: isCurrent ? TextStyle(color: scheme.onPrimary) : null,
          backgroundColor: isCurrent
              ? scheme.primary
              : isDone
                  ? AppColors.of(context).successContainer
                  : null,
        );
      }).toList(),
    );
  }

  Widget _buildControls(WorkoutState ws, WorkoutBlocStatus status) {
    final bloc = context.read<WorkoutBloc>();

    if (status == WorkoutBlocStatus.resting) {
      // Skip is only allowed once the prescribed rest has elapsed; remaining
      // time at or below the total extension means the base rest is over.
      final extension = ws.currentSet?.restExtendedSec ?? 0;
      final canSkip = ws.restSecondsRemaining <= extension;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => bloc.add(const RestExtended(15)),
                child: const Text('+15 s'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: canSkip ? () => bloc.add(const RestSkipped()) : null,
                child: Text(canSkip ? 'NEXT SET' : 'REST…'),
              ),
            ),
          ],
        ),
      );
    }

    if (status == WorkoutBlocStatus.complete || status == WorkoutBlocStatus.saving || status == WorkoutBlocStatus.saved) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _saveAndExit,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('SAVE & FINISH'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 96,
            child: GestureDetector(
              onTap: () {
                _vibrate(30);
                bloc.add(const RepAdded());
              },
              child: Card(
                color: Theme.of(context).colorScheme.primary,
                child: const Center(
                  child: Text('TAP FOR REP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: (ws.currentSet?.performed ?? 0) > 0 ? () => bloc.add(const RepRemoved()) : null,
                  child: const Text('UNDO'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => _onSetDone(ws),
                  child: Text(ws.isLastSet ? 'FINISH' : 'SET DONE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ actions

  Future<void> _onSetDone(WorkoutState ws) async {
    final bloc = context.read<WorkoutBloc>();
    if ((ws.currentSet?.performed ?? 0) == 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No reps counted'),
          content: const Text('End this set with 0 reps?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('END SET')),
          ],
        ),
      );
      if (ok != true) return;
    }
    bloc.add(const SetCompleted());
  }

  Future<void> _saveAndExit() async {
    if (_saving) return;
    setState(() => _saving = true);

    final bloc = context.read<WorkoutBloc>();
    // Subscribe before dispatching so the terminal state cannot be missed.
    final done = bloc.stream.firstWhere(
      (s) => s.status == WorkoutBlocStatus.saved || s.error != null,
    );
    bloc.add(const WorkoutSaved());
    final result = await done;

    if (!mounted) return;
    if (result.status != WorkoutBlocStatus.saved) {
      setState(() => _saving = false);
      return; // error already surfaced by the listener
    }
    Navigator.pop(context, result.message);
  }

  Future<void> _handleBack() async {
    if (_saving) return;
    final bloc = context.read<WorkoutBloc>();
    final state = bloc.state;

    if (state.status == WorkoutBlocStatus.saved || state.workout == null) {
      Navigator.pop(context);
      return;
    }
    if (!state.workout!.hasAnyReps) {
      bloc.add(const WorkoutDiscarded());
      Navigator.pop(context);
      return;
    }

    final ws = state.workout!;
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave workout?'),
        content: Text(
          '${ws.completedSets} of ${ws.totalSets} sets done (${ws.totalReps} reps). '
          'Save to resume from this point at your next workout slot.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'stay'), child: const Text('KEEP GOING')),
          TextButton(onPressed: () => Navigator.pop(ctx, 'discard'), child: const Text('DISCARD')),
          FilledButton(onPressed: () => Navigator.pop(ctx, 'save'), child: const Text('SAVE & EXIT')),
        ],
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'save':
        await _saveAndExit();
        break;
      case 'discard':
        bloc.add(const WorkoutDiscarded());
        Navigator.pop(context);
        break;
      default:
        break;
    }
  }

  void _showCompleteDialog(WorkoutBlocState state) {
    final ws = state.workout;
    final extra = _extraReps(ws);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Workout complete! 💪'),
        content: Text(
          'Total reps: ${ws?.totalReps ?? 0}\n'
          'Best set: ${_bestSet(ws)}\n'
          'Extra reps on the + set: ${extra >= 0 ? '+$extra' : '$extra (below minimum)'}',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveAndExit();
            },
            child: const Text('SAVE & FINISH'),
          ),
        ],
      ),
    );
  }

  int _bestSet(WorkoutState? ws) {
    if (ws == null) return 0;
    return ws.sets.fold<int>(0, (best, s) => (s.performed ?? 0) > best ? s.performed! : best);
  }

  /// Reps beyond the prescribed minimum on the `+` set (negative if under).
  int _extraReps(WorkoutState? ws) {
    if (ws == null) return 0;
    return ws.sets.where((s) => s.isPlus).fold<int>(0, (sum, s) => sum + ((s.performed ?? 0) - s.prescribed));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _vibrate(int ms) async {
    if (!widget.settings.haptics) return;
    if (await (_hasVibrator ?? Future.value(false))) {
      Vibration.vibrate(duration: ms);
    }
  }
}

class _RestTimer extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final SetState? nextSet;

  const _RestTimer({
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.nextSet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalSeconds <= 0 ? 0.0 : (secondsRemaining / totalSeconds).clamp(0.0, 1.0);
    final minutes = secondsRemaining ~/ 60;
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    final urgent = secondsRemaining <= 3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                color: urgent ? theme.colorScheme.error : null,
              ),
              Text(
                '$minutes:$seconds',
                style: theme.textTheme.displayMedium?.copyWith(color: urgent ? theme.colorScheme.error : null),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Rest between sets'),
        if (nextSet != null) ...[
          const SizedBox(height: 8),
          Text(
            'Next: Set ${nextSet!.index + 1} — ${nextSet!.label} reps',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ],
    );
  }
}
