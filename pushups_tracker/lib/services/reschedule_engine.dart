import 'dart:convert';

import '../data/database.dart';
import '../data/program_repository.dart';
import 'notification_service.dart';

/// Optional annotation attached to the first regenerated slot that matches
/// (kind, week, day). Used for the Home catch-up card.
class SlotNote {
  final String kind;
  final int? week;
  final int? day;
  final String text;
  const SlotNote({required this.kind, required this.week, required this.day, required this.text});
}

/// Owns the user's calendar of slots.
///
/// The user's *position* (`users.currentWeek/currentDay/pendingTest`) is the
/// source of truth. [rebuildSchedule] regenerates every pending slot from that
/// position, so missed or incomplete work automatically shifts the whole plan
/// (spec §10.2 rule 3) without ever producing duplicate slots.
class RescheduleEngine {
  final AppDatabase _db;
  final NotificationService _notifications;
  final ProgramRepository _program;

  /// A pending slot becomes "missed" this long after its due time.
  static const Duration grace = Duration(hours: 12);

  /// How many slot reminders to keep registered (iOS caps pending
  /// notifications at 64; day-before reminders double the count).
  static const int maxNotifications = 10;

  /// Hour of the evening reminder on the day before a slot.
  static const int dayBeforeHour = 20;

  RescheduleEngine(this._db, this._notifications, this._program);

  // ------------------------------------------------------------ helpers

  static List<int> parseDays(String raw) {
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        final days = decoded.map((e) => (e as num).toInt()).where((d) => d >= 1 && d <= 7).toSet().toList()..sort();
        if (days.isNotEmpty) return days;
      }
    } catch (_) {}
    return const [1, 3, 5];
  }

  static String encodeDays(Iterable<int> days) => json.encode(days.toSet().toList()..sort());

  /// True when two chosen weekdays are adjacent (Sunday→Monday counts).
  static bool hasConsecutiveDays(Iterable<int> days) {
    final set = days.toSet();
    for (final d in set) {
      final next = d == 7 ? 1 : d + 1;
      if (set.contains(next)) return true;
    }
    return false;
  }

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime startOfTomorrow([DateTime? now]) => startOfDay((now ?? DateTime.now()).add(const Duration(days: 1)));

  /// Next [count] occurrences of the user's weekday slots at or after [from].
  List<DateTime> generateSlots({
    required List<int> daysOfWeek, // 1=Mon ... 7=Sun
    required String timeOfDay, // "HH:MM"
    required DateTime from,
    required int count,
  }) {
    if (daysOfWeek.isEmpty || count <= 0) return const [];
    final parts = timeOfDay.split(':');
    final hour = int.tryParse(parts[0]) ?? 18;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final slots = <DateTime>[];
    var candidate = DateTime(from.year, from.month, from.day, hour, minute);
    var guard = 0;
    while (slots.length < count && guard < 400) {
      if (!candidate.isBefore(from) && daysOfWeek.contains(candidate.weekday)) {
        slots.add(candidate);
      }
      candidate = DateTime(candidate.year, candidate.month, candidate.day + 1, hour, minute);
      guard++;
    }
    return slots;
  }

  // ------------------------------------------------------------ rebuild

  /// Drops all pending slots and regenerates them from the user's position.
  ///
  /// Order of generated slots:
  /// 1. backlog: one resume slot per incomplete workout (oldest first)
  /// 2. the pending test, if one is due
  /// 3. remaining workout days, with exhaustion-test slots after Week 2/4/5
  /// 4. the final test after Week 6
  Future<void> rebuildSchedule({DateTime? from, SlotNote? note}) async {
    final user = await _db.getUser();
    if (user == null) return;

    await _db.clearPendingSlots();

    if (user.programCompletedAt != null) {
      await _notifications.cancelAll();
      return;
    }

    final daysOfWeek = parseDays(user.daysOfWeek);
    final slots = generateSlots(
      daysOfWeek: daysOfWeek,
      timeOfDay: user.timeOfDay,
      from: from ?? DateTime.now(),
      count: 40,
    );
    var idx = 0;
    var noteUsed = false;

    Value<String?> noteFor(String kind, int? week, int? day, [String? fallback]) {
      if (note != null && !noteUsed && note.kind == kind && note.week == week && note.day == day) {
        noteUsed = true;
        return Value(note.text);
      }
      return fallback == null ? const Value.absent() : Value(fallback);
    }

    // 1. Backlog — incomplete workouts come first.
    final backlogKeys = <String>{};
    for (final w in await _db.getIncompleteWorkouts()) {
      if (idx >= slots.length) break;
      await _db.insertSlot(ScheduledSlotsCompanion(
        dueAt: Value(slots[idx++]),
        week: Value(w.week),
        day: Value(w.day),
        kind: const Value('workout'),
        status: const Value('pending'),
        resumeWorkoutId: Value(w.id),
        notes: noteFor('workout', w.week, w.day, 'Resume incomplete workout'),
      ));
      backlogKeys.add('${w.week}:${w.day}');
    }

    var week = user.currentWeek ?? 1;
    var day = user.currentDay ?? 0;

    // 2. Pending test.
    final pendingTest = user.pendingTest;
    if (pendingTest != null && idx < slots.length) {
      final isFinal = pendingTest == 'final';
      final testWeek = week - 1;
      await _db.insertSlot(ScheduledSlotsCompanion(
        dueAt: Value(slots[idx++]),
        week: Value(testWeek),
        kind: Value(isFinal ? 'final_test' : 'exhaustion'),
        status: const Value('pending'),
        notes: noteFor(isFinal ? 'final_test' : 'exhaustion', testWeek, null),
      ));
    }

    // 3. Workout days.
    while (week <= 6 && idx < slots.length) {
      final weekData = _program.getWeek(week);
      final daysInWeek = weekData == null ? 3 : (weekData['days'] as List).length;

      if (!backlogKeys.contains('$week:$day')) {
        await _db.insertSlot(ScheduledSlotsCompanion(
          dueAt: Value(slots[idx++]),
          week: Value(week),
          day: Value(day),
          kind: const Value('workout'),
          status: const Value('pending'),
          notes: noteFor('workout', week, day),
        ));
      }

      final isLastDay = day >= daysInWeek - 1;
      if (isLastDay && _program.getExhaustionTestAfterWeek(week) != null && idx < slots.length) {
        await _db.insertSlot(ScheduledSlotsCompanion(
          dueAt: Value(slots[idx++]),
          week: Value(week),
          kind: const Value('exhaustion'),
          status: const Value('pending'),
          notes: noteFor('exhaustion', week, null),
        ));
      }

      day++;
      if (day >= daysInWeek) {
        day = 0;
        week++;
      }
    }

    // 4. Final test (unless it is already the pending test emitted above).
    if (week > 6 && pendingTest != 'final' && idx < slots.length) {
      await _db.insertSlot(ScheduledSlotsCompanion(
        dueAt: Value(slots[idx++]),
        week: const Value(6),
        kind: const Value('final_test'),
        status: const Value('pending'),
        notes: noteFor('final_test', 6, null),
      ));
    }

    await refreshNotifications(user: user);
  }

  // ------------------------------------------------------------ missed / skipped

  /// Marks every pending slot older than the grace period as missed and
  /// shifts the plan. Returns the number of slots that were missed.
  Future<int> processOverdueSlots({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final overdue = await _db.getOverdueSlots(at.subtract(grace));
    if (overdue.isEmpty) return 0;

    for (final slot in overdue) {
      await _db.updateSlotStatus(slot.id, 'missed');
    }
    final first = overdue.first;
    await rebuildSchedule(
      from: at,
      note: SlotNote(
        kind: first.kind,
        week: first.week,
        day: first.day,
        text: 'Missed on ${_fmt(first.dueAt)} — moved to this slot',
      ),
    );
    return overdue.length;
  }

  /// Explicitly mark one slot as missed (or skipped) and shift the plan.
  Future<void> handleMissedSlot(int slotId, {String status = 'missed'}) async {
    final slot = await _db.getSlot(slotId);
    if (slot == null || slot.status != 'pending') return;
    await _db.updateSlotStatus(slotId, status);
    await rebuildSchedule(
      from: status == 'skipped' ? startOfTomorrow() : DateTime.now(),
      note: SlotNote(
        kind: slot.kind,
        week: slot.week,
        day: slot.day,
        text: '${status == 'skipped' ? 'Skipped' : 'Missed'} on ${_fmt(slot.dueAt)} — moved to this slot',
      ),
    );
  }

  /// Reverts a skip: the skipped record is dropped and the plan is rebuilt
  /// from now, which puts the work back on the earliest available slot.
  Future<void> undoSkip(int slotId) async {
    final slot = await _db.getSlot(slotId);
    if (slot == null || slot.status != 'skipped') return;
    await _db.updateSlotStatus(slotId, 'pending'); // cleared by rebuild
    await rebuildSchedule(from: DateTime.now());
  }

  // ------------------------------------------------------------ notifications

  /// Cancels and re-registers reminders for the next pending slots. Honors
  /// the user's notification preferences and never schedules in the past.
  Future<void> refreshNotifications({User? user}) async {
    final u = user ?? await _db.getUser();
    await _notifications.cancelAll();
    if (u == null || !u.notifEnabled) return;

    final now = DateTime.now();
    final pending = (await _db.getPendingSlots()).where((s) => s.dueAt.isAfter(now)).take(maxNotifications);

    for (final slot in pending) {
      final (title, body) = _reminderText(slot, u.currentColumn ?? 1);
      await _notifications.scheduleWorkoutReminder(
        id: slot.id,
        scheduledDate: slot.dueAt,
        title: title,
        body: body,
        payload: '${slot.kind}:${slot.id}',
      );

      if (u.notifDayBefore) {
        final eve = DateTime(slot.dueAt.year, slot.dueAt.month, slot.dueAt.day - 1, dayBeforeHour);
        if (eve.isAfter(now)) {
          await _notifications.scheduleWorkoutReminder(
            id: NotificationService.dayBeforeIdBase + slot.id,
            scheduledDate: eve,
            title: 'Tomorrow: ${_slotTitle(slot)}',
            body: 'Scheduled for ${_time(slot.dueAt)}. Hydrate and rest well tonight.',
            payload: '${slot.kind}:${slot.id}',
          );
        }
      }
    }
  }

  /// Spec §5 content example: "Workout due: Week 3 · Day 2 — 14 minutes estimated."
  (String, String) _reminderText(ScheduledSlot slot, int column) {
    switch (slot.kind) {
      case 'workout':
        final plan = slot.week == null
            ? null
            : _program.planFor(week: slot.week!, day: slot.day ?? 0, column: column);
        final detail = plan == null ? 'tap to start' : '${plan.summary} · ~${plan.estimatedMinutes} min';
        return ('💪 Workout due', '${_slotTitle(slot)} — $detail');
      case 'exhaustion':
        return ('📊 Exhaustion test due', 'It decides your column for Week ${(slot.week ?? 0) + 1}');
      case 'final_test':
        return ('🏆 Final test!', 'Time for 100 pushups. You got this!');
      default:
        return ('Pushups reminder', 'Your workout is waiting');
    }
  }

  String _slotTitle(ScheduledSlot slot) {
    switch (slot.kind) {
      case 'workout':
        return 'Week ${slot.week} · Day ${(slot.day ?? 0) + 1}';
      case 'exhaustion':
        return 'Exhaustion test (after Week ${slot.week})';
      case 'final_test':
        return 'Final test';
      default:
        return 'Workout';
    }
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  static String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
