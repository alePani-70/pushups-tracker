import 'dart:convert';

import '../data/database.dart';
import '../data/program_repository.dart';
import '../domain/routing/routing_engine.dart';
import 'reschedule_engine.dart';

/// Applies program progression rules to the persisted user position and keeps
/// the schedule in sync. This is the only place that mutates
/// `users.currentWeek / currentDay / currentColumn / pendingTest`.
class ProgressionService {
  final AppDatabase _db;
  final ProgramRepository _program;
  final RoutingEngine _routing;
  final RescheduleEngine _schedule;

  ProgressionService(this._db, this._program, this._routing, this._schedule);

  // ------------------------------------------------------------ workouts

  /// Called after a workout is saved as completed. Advances the position and
  /// regenerates the schedule starting tomorrow.
  Future<RoutingResult> onWorkoutCompleted({
    required int week,
    required int day,
    required int column,
  }) async {
    final user = await _db.getUser();
    if (user == null) throw StateError('No user');

    final route = _routing.routeWorkoutCompletion(week, day, column);
    var companion = UsersCompanion(id: Value(user.id));

    switch (route.action) {
      case 'next_day':
        companion = companion.copyWith(
          currentWeek: Value(week),
          currentDay: Value(route.day!),
        );
        break;
      case 'next_week':
        companion = companion.copyWith(
          currentWeek: Value(route.week!),
          currentDay: const Value(0),
        );
        break;
      case 'exhaustion_test':
        companion = companion.copyWith(
          currentWeek: Value(route.week!),
          currentDay: const Value(0),
          pendingTest: Value(route.testId),
        );
        break;
      case 'final_test':
        companion = companion.copyWith(
          currentWeek: const Value(7),
          currentDay: const Value(0),
          pendingTest: const Value('final'),
        );
        break;
      default:
        break;
    }

    await _db.updateUser(companion);
    await _schedule.rebuildSchedule(from: RescheduleEngine.startOfTomorrow());
    return route;
  }

  /// Called after a workout is saved as incomplete. The slot is marked
  /// `rescheduled`; the rebuilt schedule puts a resume slot first.
  Future<void> onWorkoutIncomplete({required int slotId}) async {
    await _db.updateSlotStatus(slotId, 'rescheduled');
    await _schedule.rebuildSchedule(from: RescheduleEngine.startOfTomorrow());
  }

  // ------------------------------------------------------------ tests

  /// Which exhaustion test is due for this user (`ET1`..`ET3`), or null when
  /// none is due. Deliberately strict (spec §7): a test can only be taken
  /// once the preceding week has been completed.
  String? pendingExhaustionTestId(User user) {
    final pending = user.pendingTest;
    if (pending != null && pending != 'final') return pending;
    return null;
  }

  Map<String, dynamic>? exhaustionTestData(String testId) {
    try {
      return _program.exhaustionTests.firstWhere((t) => t['id'] == testId);
    } catch (_) {
      return null;
    }
  }

  RoutingResult previewExhaustionRouting(String testId, int result) =>
      _routing.routeExhaustionTest(testId, result);

  bool finalTestPassed(int result) => _routing.finalTestPassed(result);

  /// Records an exhaustion test, applies its routing, and rebuilds the plan.
  Future<RoutingResult> recordExhaustionTest({
    required String testId,
    required int result,
    int? slotId,
  }) async {
    final user = await _db.getUser();
    if (user == null) throw StateError('No user');

    final route = _routing.routeExhaustionTest(testId, result);

    await _db.insertTest(TestsCompanion(
      kind: const Value('exhaustion'),
      scheduledSlotId: Value(slotId),
      result: Value(result),
      takenAt: Value(DateTime.now()),
      routing: Value(json.encode({
        'testId': testId,
        'action': route.action,
        'week': route.week ?? route.targetWeek,
        'column': route.column,
      })),
    ));
    if (slotId != null) await _db.updateSlotStatus(slotId, 'done');

    if (route.isRepeat) {
      await _db.flagRepeatWeek(route.targetWeek!);
      await _db.updateUser(UsersCompanion(
        id: Value(user.id),
        currentWeek: Value(route.targetWeek!),
        currentDay: const Value(0),
        pendingTest: const Value(null),
      ));
    } else {
      await _db.updateUser(UsersCompanion(
        id: Value(user.id),
        currentWeek: Value(route.week!),
        currentDay: const Value(0),
        currentColumn: Value(route.column!),
        pendingTest: const Value(null),
      ));
    }
    await _schedule.rebuildSchedule(from: RescheduleEngine.startOfTomorrow());
    return route;
  }

  /// Records the final test. Returns true when the goal was reached, in which
  /// case the program is marked complete and all pending slots are removed.
  /// On failure the caller decides via [repeatWeek] or [deferFinalTest].
  Future<bool> recordFinalTest({required int result, int? slotId}) async {
    final user = await _db.getUser();
    if (user == null) throw StateError('No user');

    final passed = _routing.finalTestPassed(result);
    await _db.insertTest(TestsCompanion(
      kind: const Value('final'),
      scheduledSlotId: Value(slotId),
      result: Value(result),
      takenAt: Value(DateTime.now()),
      routing: Value(json.encode({'passed': passed})),
    ));
    if (slotId != null) await _db.updateSlotStatus(slotId, 'done');

    if (passed) {
      await _db.updateUser(UsersCompanion(
        id: Value(user.id),
        pendingTest: const Value(null),
        programCompletedAt: Value(DateTime.now()),
      ));
      await _schedule.rebuildSchedule(); // clears pending slots + notifications
    }
    return passed;
  }

  /// Restart at Day 1 of [week] with the current column (used after a failed
  /// gate or final test, or when the user chooses to repeat a week).
  Future<void> repeatWeek(int week) async {
    final user = await _db.getUser();
    if (user == null) return;
    await _db.flagRepeatWeek(week);
    await _db.updateUser(UsersCompanion(
      id: Value(user.id),
      currentWeek: Value(week),
      currentDay: const Value(0),
      pendingTest: const Value(null),
      programCompletedAt: const Value(null),
    ));
    await _schedule.rebuildSchedule(from: RescheduleEngine.startOfTomorrow());
  }

  /// Keep the final test pending and move it to the next slot.
  Future<void> deferFinalTest() async {
    await _schedule.rebuildSchedule(from: RescheduleEngine.startOfTomorrow());
  }

  // ------------------------------------------------------------ settings

  /// Manual column override (spec §3.7, advanced). Applies to the next
  /// workout; the schedule itself does not change.
  Future<void> overrideColumn(int column) async {
    final user = await _db.getUser();
    if (user == null) return;
    await _db.updateUser(UsersCompanion(
      id: Value(user.id),
      currentColumn: Value(column.clamp(1, 3)),
    ));
  }
}
