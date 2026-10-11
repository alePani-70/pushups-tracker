import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../../data/program_repository.dart';
import '../../domain/routing/routing_engine.dart';
import '../../services/notification_service.dart';
import '../../services/reschedule_engine.dart';
import '../program/program_screen.dart';
import '../widgets/profile_form.dart';
import '../widgets/rep_counter.dart';
import '../widgets/workout_plan_card.dart';

/// Spec §3.1: disclaimer → registration → initial test → schedule → summary.
class OnboardingScreen extends StatefulWidget {
  final AppDatabase db;
  final ProgramRepository programRepo;
  final RoutingEngine routingEngine;
  final RescheduleEngine rescheduleEngine;
  final NotificationService notifications;

  const OnboardingScreen({
    super.key,
    required this.db,
    required this.programRepo,
    required this.routingEngine,
    required this.rescheduleEngine,
    required this.notifications,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  ProfileData? _profile;
  int _testResult = 0;
  final Set<int> _selectedDays = {1, 3, 5};
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  bool _notificationsEnabled = true;
  bool _finishing = false;

  static const _stepCount = 5;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) setState(() => _step--);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _stepCount,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStep(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _DisclaimerStep(key: const ValueKey('disclaimer'), onNext: () => setState(() => _step = 1));
      case 1:
        return ProfileForm(
          key: const ValueKey('profile'),
          initial: _profile,
          submitLabel: 'CONTINUE TO INITIAL TEST',
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About you', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'A few details before your first test. Your age picks the rank band used to put your results in context.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          onSubmit: (data) => setState(() {
            _profile = data;
            _step = 2;
          }),
        );
      case 2:
        return RepCounter(
          key: const ValueKey('initial-test'),
          title: 'Initial Test',
          instruction: widget.programRepo.initialTest?['instruction'] as String? ??
              'Do as many good-form pushups as you can in one go. Stop when you physically cannot do another rep.',
          onFinish: (result) => setState(() {
            _testResult = result;
            _step = 3;
          }),
        );
      case 3:
        return _ScheduleStep(
          key: const ValueKey('schedule'),
          selectedDays: _selectedDays,
          selectedTime: _selectedTime,
          notificationsEnabled: _notificationsEnabled,
          onDaysChanged: (days) => setState(() => _selectedDays
            ..clear()
            ..addAll(days)),
          onTimeChanged: (time) => setState(() => _selectedTime = time),
          onNotifChanged: (val) => setState(() => _notificationsEnabled = val),
          onNext: () => setState(() => _step = 4),
        );
      case 4:
        return _SummaryStep(
          key: const ValueKey('summary'),
          profile: _profile!,
          testResult: _testResult,
          programRepo: widget.programRepo,
          routingEngine: widget.routingEngine,
          busy: _finishing,
          onFinish: _finishOnboarding,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _finishOnboarding() async {
    if (_finishing) return;
    setState(() => _finishing = true);

    try {
      final profile = _profile!;
      final route = widget.routingEngine.routeInitialTest(_testResult);
      final sortedDays = _selectedDays.toList()..sort();
      final timeString =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      // Ask the OS for permission now, and only persist "enabled" if granted.
      var notifEnabled = _notificationsEnabled;
      if (notifEnabled) {
        notifEnabled = await widget.notifications.requestPermission();
      }

      await widget.db.createUser(UsersCompanion(
        name: Value(profile.name),
        age: Value(profile.age),
        weightKg: Value(profile.weightKg),
        sex: Value(profile.sex),
        daysOfWeek: Value(RescheduleEngine.encodeDays(sortedDays)),
        timeOfDay: Value(timeString),
        notifEnabled: Value(notifEnabled),
        onboardingComplete: const Value(true),
        currentWeek: Value(route.week ?? 1),
        currentDay: const Value(0),
        currentColumn: Value(route.column ?? 1),
      ));

      await widget.db.insertTest(TestsCompanion(
        kind: const Value('initial'),
        result: Value(_testResult),
        takenAt: Value(DateTime.now()),
        routing: Value('{"week": ${route.week}, "column": ${route.column}}'),
      ));

      // Two rest days after the initial test before the first workout.
      await widget.rescheduleEngine.rebuildSchedule(
        from: RescheduleEngine.startOfDay(DateTime.now().add(const Duration(days: 2))),
      );

      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (!mounted) return;
      setState(() => _finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not start program: $e')));
    }
  }
}

class _DisclaimerStep extends StatelessWidget {
  final VoidCallback onNext;
  const _DisclaimerStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 16),
        Text(
          'The One Hundred Pushups program is a 6-week training plan to build up to 100 consecutive pushups.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️ Important', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Before starting any exercise program, obtain medical advice and clearance from your doctor. Do not push beyond safe limits.'),
              ],
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onNext,
            child: const Text('I UNDERSTAND — CONTINUE'),
          ),
        ),
      ],
    );
  }
}

class _ScheduleStep extends StatelessWidget {
  final Set<int> selectedDays;
  final TimeOfDay selectedTime;
  final bool notificationsEnabled;
  final ValueChanged<Set<int>> onDaysChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<bool> onNotifChanged;
  final VoidCallback onNext;

  const _ScheduleStep({
    super.key,
    required this.selectedDays,
    required this.selectedTime,
    required this.notificationsEnabled,
    required this.onDaysChanged,
    required this.onTimeChanged,
    required this.onNotifChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final consecutive = RescheduleEngine.hasConsecutiveDays(selectedDays);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Schedule', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 16),
        Text('Pick 3 workout days per week:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final day = index + 1;
            return FilterChip(
              label: Text(weekdays[index]),
              selected: selectedDays.contains(day),
              onSelected: (value) {
                final newSet = Set<int>.from(selectedDays);
                if (value) {
                  newSet.add(day);
                } else {
                  newSet.remove(day);
                }
                onDaysChanged(newSet);
              },
            );
          }),
        ),
        if (selectedDays.length != 3)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Select exactly 3 days', style: TextStyle(color: Colors.orange)),
          )
        else if (consecutive)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Two days are back-to-back. At least one rest day between workouts is recommended.',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        const SizedBox(height: 24),
        ListTile(
          title: const Text('Workout Time'),
          subtitle: Text(selectedTime.format(context)),
          trailing: const Icon(Icons.access_time),
          onTap: () async {
            final time = await showTimePicker(context: context, initialTime: selectedTime);
            if (time != null) onTimeChanged(time);
          },
        ),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Reminders when a workout or test is due'),
          value: notificationsEnabled,
          onChanged: onNotifChanged,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: selectedDays.length == 3 ? onNext : null,
            child: const Text('CONTINUE'),
          ),
        ),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  final ProfileData profile;
  final int testResult;
  final ProgramRepository programRepo;
  final RoutingEngine routingEngine;
  final bool busy;
  final VoidCallback onFinish;

  const _SummaryStep({
    super.key,
    required this.profile,
    required this.testResult,
    required this.programRepo,
    required this.routingEngine,
    required this.busy,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final route = routingEngine.routeInitialTest(testResult);
    final week = route.week ?? 1;
    final column = route.column ?? 1;
    final rank = programRepo.rankFor(age: profile.age, result: testResult);
    final plan = programRepo.planFor(week: week, day: 0, column: column);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Text('All set, ${profile.name}!', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Initial Test Result', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('$testResult', style: theme.textTheme.displayMedium),
                      const Text('pushups'),
                      const SizedBox(height: 8),
                      Text(
                        rank == null
                            ? 'Outside the rank table for your age band.'
                            : 'Rank $rank of 7 for ages ${ProgramRepository.ageBandLabel(profile.age)}'
                                '${rank <= 3 ? ' — a great starting point.' : rank == 1 ? '' : ' — strong start!'}',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (rank == 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Tip: knee or incline pushups are a good way to build up if full pushups are too hard right now.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const Divider(height: 24),
                      Text('Starting point', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Week $week · Column $column', style: theme.textTheme.headlineSmall),
                      Text(
                        'Column $column: test result ${programRepo.columnLabel(week, column)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Your first workout', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (plan != null) WorkoutPlanCard(plan: plan),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('VIEW FULL PROGRAM'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProgramScreen(
                        programRepo: programRepo,
                        initialWeek: week,
                        initialColumn: column,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: Text('Rest 2 days, then your first workout begins!')),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: busy ? null : onFinish,
          child: busy
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('START PROGRAM'),
        ),
      ],
    );
  }
}
