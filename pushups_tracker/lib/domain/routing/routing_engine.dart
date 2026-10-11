import '../../data/program_repository.dart';

/// Outcome of a routing decision.
///
/// `action` is one of:
/// - `advance`         → go to `week` / `column` (test routing)
/// - `repeat`          → repeat `targetWeek` (test routing)
/// - `next_day`        → same week, `day` is the next 0-based day
/// - `next_week`       → `week` is the next week, day 0, same column
/// - `exhaustion_test` → week finished; `testId` must be taken before `week`
/// - `final_test`      → Week 6 finished; final test due
class RoutingResult {
  final String action;
  final int? week;
  final int? day;
  final int? column;
  final int? targetWeek;
  final String? testId;
  final String? message;

  const RoutingResult({
    required this.action,
    this.week,
    this.day,
    this.column,
    this.targetWeek,
    this.testId,
    this.message,
  });

  bool get isRepeat => action == 'repeat';
}

class RoutingEngine {
  final ProgramRepository _program;

  RoutingEngine(this._program);

  RoutingResult routeInitialTest(int result) {
    final route = _program.routeInitialTest(result);
    return RoutingResult(
      action: 'advance',
      week: route['week'],
      column: route['column'],
      message: 'Start at Week ${route['week']}, Column ${route['column']}',
    );
  }

  RoutingResult routeExhaustionTest(String testId, int result) {
    final route = _program.routeExhaustionTest(testId, result);
    if (route['action'] == 'repeat') {
      return RoutingResult(
        action: 'repeat',
        targetWeek: route['targetWeek'] as int,
        testId: testId,
        message: 'You did $result. Repeat Week ${route['targetWeek']} before moving on.',
      );
    }
    return RoutingResult(
      action: 'advance',
      week: route['week'] as int,
      column: route['column'] as int,
      testId: testId,
      message: 'You did $result → Week ${route['week']}, Column ${route['column']}',
    );
  }

  /// Whether a final-test result passes the program goal.
  bool finalTestPassed(int result) {
    final goal = _program.finalTest?['goal'] as int? ?? 100;
    return result >= goal;
  }

  /// After completing a workout day, determine what comes next.
  RoutingResult routeWorkoutCompletion(int currentWeek, int currentDay, int currentColumn) {
    final weekData = _program.getWeek(currentWeek);
    if (weekData == null) {
      return const RoutingResult(action: 'repeat', message: 'Invalid week');
    }

    final days = weekData['days'] as List;
    final nextDay = currentDay + 1;

    if (nextDay < days.length) {
      return RoutingResult(
        action: 'next_day',
        week: currentWeek,
        day: nextDay,
        column: currentColumn,
        message: 'Next: Week $currentWeek, Day ${nextDay + 1}',
      );
    }

    final exhaustionTest = _program.getExhaustionTestAfterWeek(currentWeek);
    if (exhaustionTest != null) {
      return RoutingResult(
        action: 'exhaustion_test',
        week: currentWeek + 1,
        day: 0,
        column: currentColumn,
        testId: exhaustionTest['id'] as String,
        message: 'Week $currentWeek complete! Take the exhaustion test to unlock Week ${currentWeek + 1}.',
      );
    }

    if (currentWeek >= 6) {
      return const RoutingResult(
        action: 'final_test',
        message: 'Week 6 complete! Rest 1–2 days, then take the final 100-pushup test.',
      );
    }

    return RoutingResult(
      action: 'next_week',
      week: currentWeek + 1,
      day: 0,
      column: currentColumn,
      message: 'Week $currentWeek complete! Next: Week ${currentWeek + 1}, Day 1',
    );
  }
}
