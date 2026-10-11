import 'dart:convert';
import 'package:flutter/services.dart';

import '../domain/models/workout_plan.dart';

class ProgramRepository {
  Map<String, dynamic>? _program;

  Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/program_v1.json');
    _program = json.decode(jsonString) as Map<String, dynamic>;
  }

  Map<String, dynamic>? get program => _program;

  List<Map<String, dynamic>> get weeks {
    if (_program == null) return [];
    return (_program!['weeks'] as List).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic>? getWeek(int weekNumber) {
    try {
      return weeks.firstWhere((w) => w['week'] == weekNumber);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? getDay(int weekNumber, int dayIndex) {
    final week = getWeek(weekNumber);
    if (week == null) return null;
    final days = week['days'] as List;
    if (dayIndex < 0 || dayIndex >= days.length) return null;
    return days[dayIndex] as Map<String, dynamic>;
  }

  int daysInWeek(int weekNumber) => (getWeek(weekNumber)?['days'] as List?)?.length ?? 3;

  List<Map<String, dynamic>> get exhaustionTests {
    if (_program == null) return [];
    return (_program!['exhaustionTests'] as List).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic>? getExhaustionTestAfterWeek(int week) {
    try {
      return exhaustionTests.firstWhere((t) => t['afterWeek'] == week);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? get finalTest {
    return _program?['finalTest'] as Map<String, dynamic>?;
  }

  Map<String, dynamic>? get initialTest {
    return _program?['initialTest'] as Map<String, dynamic>?;
  }

  // ------------------------------------------------------------ plans

  /// Test-result label of a column for a week, e.g. "6-10". Empty if unknown.
  String columnLabel(int week, int column) {
    final labels = (getWeek(week)?['columnLabels'] as List?)?.cast<String>();
    if (labels == null || column < 1 || column > labels.length) return '';
    return labels[column - 1];
  }

  /// The sets, rest and derived numbers for one workout day in one column.
  WorkoutPlan? planFor({required int week, required int day, required int column}) {
    final dayData = getDay(week, day);
    if (dayData == null) return null;
    final setsData = (dayData['sets'] as List).cast<List>();
    final isPlusList = (dayData['isPlus'] as List).cast<bool>();
    final col = (column - 1).clamp(0, 2);
    return WorkoutPlan(
      week: week,
      day: day,
      column: col + 1,
      columnLabel: columnLabel(week, col + 1),
      restSeconds: dayData['restSeconds'] as int? ?? 60,
      sets: [
        for (var i = 0; i < setsData.length; i++)
          PlannedSet(
            index: i,
            reps: setsData[i][col] as int,
            isPlus: i < isPlusList.length && isPlusList[i],
          ),
      ],
    );
  }

  // ------------------------------------------------------------ ranks

  List<Map<String, dynamic>> get ranks =>
      (initialTest?['ranks'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

  /// Rank-table column for an age (spec §2: <40 / 40–55 / >55).
  static String ageBandKey(int age) => age < 40 ? 'age_lt40' : (age <= 55 ? 'age_40_55' : 'age_gt55');

  static String ageBandLabel(int age) => age < 40 ? 'under 40' : (age <= 55 ? '40–55' : 'over 55');

  /// Rank (1–7) for [result] pushups at [age], or null if not in the table.
  int? rankFor({required int age, required int result}) {
    final key = ageBandKey(age);
    for (final row in ranks) {
      final range = row[key] as String?;
      if (range != null && inRange(range, result)) return row['rank'] as int?;
    }
    return null;
  }

  /// Parses "6-14" and ">150" style ranges from the rank table.
  static bool inRange(String range, int value) {
    final s = range.trim();
    if (s.startsWith('>')) return value > (int.tryParse(s.substring(1).trim()) ?? 0);
    final parts = s.split('-');
    if (parts.length == 2) {
      final lo = int.tryParse(parts[0].trim());
      final hi = int.tryParse(parts[1].trim());
      return lo != null && hi != null && value >= lo && value <= hi;
    }
    return false;
  }

  // ------------------------------------------------------------ routing

  /// Determine starting position from initial test result
  Map<String, int> routeInitialTest(int result) {
    final routing = (initialTest?['startRouting'] as List?)?.cast<Map<String, dynamic>>();
    if (routing == null) return {'week': 1, 'column': 1};
    for (final rule in routing) {
      if (result <= (rule['max'] as int)) {
        final goto = rule['goto'] as Map<String, dynamic>;
        return {
          'week': goto['week'] as int,
          'column': goto['column'] as int,
        };
      }
    }
    return {'week': 1, 'column': 1};
  }

  /// Route an exhaustion test result to next week/column or repeat
  Map<String, dynamic> routeExhaustionTest(String testId, int result) {
    final test = exhaustionTests.firstWhere((t) => t['id'] == testId);
    final routing = (test['routing'] as List).cast<Map<String, dynamic>>();
    for (final rule in routing) {
      if (result <= (rule['max'] as int)) {
        if (rule['action'] == 'repeat') {
          return {
            'action': 'repeat',
            'targetWeek': rule['targetWeek'] as int,
          };
        } else {
          final goto = rule['goto'] as Map<String, dynamic>;
          return {
            'action': 'advance',
            'week': goto['week'] as int,
            'column': goto['column'] as int,
          };
        }
      }
    }
    return {'action': 'repeat', 'targetWeek': test['afterWeek'] as int};
  }

  /// Human-readable routing rules of a test, e.g. "<16 repeat · 16–20 → Col 1 · …".
  String describeRouting(List<Map<String, dynamic>> routing) {
    final parts = <String>[];
    var lower = 0;
    for (final rule in routing) {
      final max = rule['max'] as int;
      final String range;
      if (max >= 99999) {
        range = '>${lower - 1}';
      } else if (lower == 0) {
        range = '≤$max';
      } else if (lower == max) {
        range = '$max';
      } else {
        range = '$lower–$max';
      }
      if (rule['action'] == 'repeat') {
        parts.add('$range repeat Week ${rule['targetWeek']}');
      } else {
        final goto = rule['goto'] as Map<String, dynamic>;
        parts.add('$range → Week ${goto['week']} Col ${goto['column']}');
      }
      lower = max + 1;
    }
    return parts.join(' · ');
  }

  int get totalWorkoutDays {
    return weeks.fold<int>(0, (sum, w) {
      final days = (w['days'] as List).length;
      return sum + days;
    });
  }
}
