import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../../services/notification_service.dart';
import '../../services/reschedule_engine.dart';

class ScheduleScreen extends StatefulWidget {
  final AppDatabase db;
  final RescheduleEngine rescheduleEngine;
  final NotificationService notifications;

  /// Ticks when the shell wants this tab to reload.
  final Listenable? refresh;

  /// Called after a successful save. When null the screen pops itself.
  final VoidCallback? onSaved;

  const ScheduleScreen({
    super.key,
    required this.db,
    required this.rescheduleEngine,
    required this.notifications,
    this.refresh,
    this.onSaved,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final Set<int> _selectedDays = {1, 3, 5}; // Mon, Wed, Fri
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  bool _notificationsEnabled = true;
  bool _dayBefore = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.refresh?.addListener(_loadCurrentSchedule);
    _loadCurrentSchedule();
  }

  @override
  void dispose() {
    widget.refresh?.removeListener(_loadCurrentSchedule);
    super.dispose();
  }

  Future<void> _loadCurrentSchedule() async {
    final user = await widget.db.getUser();
    if (user == null || !mounted) return;
    final timeParts = user.timeOfDay.split(':');
    setState(() {
      _selectedDays
        ..clear()
        ..addAll(RescheduleEngine.parseDays(user.daysOfWeek));
      _selectedTime = TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 18,
        minute: timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0,
      );
      _notificationsEnabled = user.notifEnabled;
      _dayBefore = user.notifDayBefore;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final consecutive = RescheduleEngine.hasConsecutiveDays(_selectedDays);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Workout Days', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final day = index + 1;
              return FilterChip(
                label: Text(weekdays[index]),
                selected: _selectedDays.contains(day),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          if (_selectedDays.length != 3)
            Text(
              'Please select exactly 3 days.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
            )
          else if (consecutive)
            Text(
              'Two of your days are back-to-back. The program recommends at least one rest day between workouts.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
            ),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Workout Time'),
            subtitle: Text(_selectedTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _selectedTime);
              if (time != null) setState(() => _selectedTime = time);
            },
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Workout Reminders'),
            subtitle: const Text('Get notified when a workout or test is due'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              if (value) {
                final messenger = ScaffoldMessenger.of(context);
                final granted = await widget.notifications.requestPermission();
                if (!mounted) return;
                setState(() => _notificationsEnabled = granted);
                if (!granted) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Notification permission was not granted')),
                  );
                }
              } else {
                setState(() => _notificationsEnabled = false);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Day-before Reminder'),
            subtitle: const Text('Heads-up at ${RescheduleEngine.dayBeforeHour}:00 the evening before'),
            value: _dayBefore && _notificationsEnabled,
            onChanged: _notificationsEnabled ? (value) => setState(() => _dayBefore = value) : null,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _saveSchedule,
            child: _saving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('SAVE SCHEDULE'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (_selectedDays.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select exactly 3 days')));
      return;
    }

    final user = await widget.db.getUser();
    if (user == null) return;

    setState(() => _saving = true);
    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    try {
      await widget.db.updateUser(UsersCompanion(
        id: Value(user.id),
        daysOfWeek: Value(RescheduleEngine.encodeDays(_selectedDays)),
        timeOfDay: Value(timeString),
        notifEnabled: Value(_notificationsEnabled),
        notifDayBefore: Value(_dayBefore && _notificationsEnabled),
      ));
      // Position is unchanged; only the calendar moves to the new days/time.
      await widget.rescheduleEngine.rebuildSchedule(from: DateTime.now());

      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved and notifications updated')),
      );
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save schedule: $e')));
    }
  }
}
