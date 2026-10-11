import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../../data/program_repository.dart';
import '../../services/progression_service.dart';
import '../widgets/rep_counter.dart';

/// Exhaustion and final test screen.
///
/// Route arguments: `kind` ('exhaustion' | 'final') and optional `slotId`.
/// Pops with `true` once a result has been recorded.
class TestScreen extends StatefulWidget {
  final AppDatabase db;
  final ProgramRepository programRepo;
  final ProgressionService progression;

  const TestScreen({
    super.key,
    required this.db,
    required this.programRepo,
    required this.progression,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _argsRead = false;
  bool _busy = false;
  String _kind = 'exhaustion';
  int? _slotId;
  String? _testId; // ET1..ET3 for exhaustion tests
  String? _loadError;
  String? _windowHint;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _kind = (args?['kind'] as String?) ?? 'exhaustion';
    _slotId = args?['slotId'] as int?;
    if (_kind == 'exhaustion') _resolveTestId();
  }

  Future<void> _resolveTestId() async {
    final user = await widget.db.getUser();
    final id = user == null ? null : widget.progression.pendingExhaustionTestId(user);

    // Spec §8: results map best within the test window after the week ends.
    String? hint;
    if (id != null) {
      final windowDays = widget.progression.exhaustionTestData(id)?['windowDays'] as int? ?? 2;
      final lastWorkout = await widget.db.getLastCompletedWorkoutDate();
      if (lastWorkout != null) {
        final daysSince = DateTime.now().difference(lastWorkout).inDays;
        if (daysSince > windowDays) {
          hint = 'Your last workout was $daysSince days ago. Results map best within '
              '$windowDays days of finishing the week — expect a slightly lower count after a longer break.';
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _testId = id;
      _windowHint = hint;
      if (id == null) _loadError = 'No exhaustion test is due right now.';
    });
  }

  bool get _isFinal => _kind == 'final';

  String get _instruction {
    if (_isFinal) {
      final ft = widget.programRepo.finalTest;
      return '${ft?['instruction'] ?? 'Perform as many good-form pushups as you can.'}\n\n'
          '${ft?['advice'] ?? ''}';
    }
    final data = _testId == null ? null : widget.progression.exhaustionTestData(_testId!);
    return data?['instruction'] as String? ??
        'Perform as many good-form pushups as you can. Stop when you physically cannot do another rep.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = _isFinal || _testId != null;
    return Scaffold(
      appBar: AppBar(title: Text(_isFinal ? 'Final Test' : 'Exhaustion Test')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loadError != null
              ? Center(child: Text(_loadError!))
              : !ready
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        if (_windowHint != null) ...[
                          Card(
                            color: theme.colorScheme.secondaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(_windowHint!, style: theme.textTheme.bodySmall)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Expanded(
                          child: RepCounter(
                            title: _isFinal ? '100 Pushups' : 'Max Reps',
                            instruction: _instruction,
                            enabled: !_busy,
                            onFinish: _onFinish,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Future<void> _onFinish(int result) async {
    if (_busy) return;
    if (_isFinal) {
      await _handleFinal(result);
    } else {
      await _handleExhaustion(result);
    }
  }

  // ------------------------------------------------------------ exhaustion

  Future<void> _handleExhaustion(int result) async {
    final route = widget.progression.previewExhaustionRouting(_testId!, result);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Result: $result pushups'),
        content: Text(route.message ?? ''),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('RETAKE')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('CONFIRM')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await widget.progression.recordExhaustionTest(testId: _testId!, result: result, slotId: _slotId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save test: $e')));
    }
  }

  // ------------------------------------------------------------ final

  Future<void> _handleFinal(int result) async {
    setState(() => _busy = true);
    final bool passed;
    try {
      passed = await widget.progression.recordFinalTest(result: result, slotId: _slotId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save test: $e')));
      return;
    }
    if (!mounted) return;

    if (passed) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('🏆 You did it!'),
          content: Text('$result consecutive good-form pushups. Program complete!'),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('AWESOME')),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
      return;
    }

    final goal = widget.programRepo.finalTest?['goal'] ?? 100;
    final onFail = widget.programRepo.finalTest?['onFail'] as String? ?? 'Repeat Week 5 or 6, then retest.';
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('$result / $goal — not yet'),
        content: Text("$onFail\n\nYou're closer than you think."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'retest'), child: const Text('RETEST LATER')),
          TextButton(onPressed: () => Navigator.pop(ctx, 'w5'), child: const Text('REPEAT WEEK 5')),
          FilledButton(onPressed: () => Navigator.pop(ctx, 'w6'), child: const Text('REPEAT WEEK 6')),
        ],
      ),
    );
    if (!mounted) return;

    switch (choice) {
      case 'w5':
        await widget.progression.repeatWeek(5);
        break;
      case 'w6':
        await widget.progression.repeatWeek(6);
        break;
      default:
        await widget.progression.deferFinalTest();
    }
    if (mounted) Navigator.pop(context, true);
  }
}
