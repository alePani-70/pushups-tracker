import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushups_tracker/data/program_repository.dart';
import 'package:pushups_tracker/domain/routing/routing_engine.dart';

/// Loads the real program asset into a ProgramRepository without a Flutter
/// engine, by answering rootBundle requests from the file system.
Future<ProgramRepository> loadProgram() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = File('assets/program_v1.json').readAsBytesSync();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (message) async => ByteData.view(Uint8List.fromList(bytes).buffer),
  );
  final repo = ProgramRepository();
  await repo.load();
  return repo;
}

void main() {
  late RoutingEngine engine;
  late ProgramRepository program;

  setUpAll(() async {
    program = await loadProgram();
    engine = RoutingEngine(program);
  });

  group('program data', () {
    test('has 6 weeks × 3 days and 18 total workout days', () {
      expect(program.weeks.length, 6);
      expect(program.totalWorkoutDays, 18);
      for (final w in program.weeks) {
        expect((w['days'] as List).length, 3, reason: 'week ${w['week']}');
      }
    });

    test('plus set is always the last set of a day', () {
      for (final w in program.weeks) {
        for (final d in (w['days'] as List).cast<Map<String, dynamic>>()) {
          final isPlus = (d['isPlus'] as List).cast<bool>();
          expect(isPlus.last, isTrue);
          expect(isPlus.where((p) => p).length, 1);
          expect((d['sets'] as List).length, isPlus.length);
        }
      }
    });
  });

  group('initial test routing', () {
    final cases = <int, (int, int)>{
      0: (1, 1),
      5: (1, 1),
      6: (1, 2),
      10: (1, 2),
      11: (1, 3),
      20: (1, 3),
      21: (3, 2),
      30: (3, 2),
      31: (3, 3),
      150: (3, 3),
    };
    cases.forEach((result, expected) {
      test('$result reps → week ${expected.$1} column ${expected.$2}', () {
        final r = engine.routeInitialTest(result);
        expect(r.action, 'advance');
        expect((r.week, r.column), expected);
      });
    });
  });

  group('exhaustion test routing', () {
    test('ET1 thresholds', () {
      expect(engine.routeExhaustionTest('ET1', 15).isRepeat, isTrue);
      expect(engine.routeExhaustionTest('ET1', 15).targetWeek, 2);
      expect((engine.routeExhaustionTest('ET1', 16).week, engine.routeExhaustionTest('ET1', 16).column), (3, 1));
      expect((engine.routeExhaustionTest('ET1', 20).week, engine.routeExhaustionTest('ET1', 20).column), (3, 1));
      expect((engine.routeExhaustionTest('ET1', 21).week, engine.routeExhaustionTest('ET1', 21).column), (3, 2));
      expect((engine.routeExhaustionTest('ET1', 25).week, engine.routeExhaustionTest('ET1', 25).column), (3, 2));
      expect((engine.routeExhaustionTest('ET1', 26).week, engine.routeExhaustionTest('ET1', 26).column), (3, 3));
    });

    test('ET2 thresholds', () {
      expect(engine.routeExhaustionTest('ET2', 30).isRepeat, isTrue);
      expect(engine.routeExhaustionTest('ET2', 30).targetWeek, 4);
      expect((engine.routeExhaustionTest('ET2', 31).week, engine.routeExhaustionTest('ET2', 31).column), (5, 1));
      expect((engine.routeExhaustionTest('ET2', 35).week, engine.routeExhaustionTest('ET2', 35).column), (5, 1));
      expect((engine.routeExhaustionTest('ET2', 36).week, engine.routeExhaustionTest('ET2', 36).column), (5, 2));
      expect((engine.routeExhaustionTest('ET2', 40).week, engine.routeExhaustionTest('ET2', 40).column), (5, 2));
      expect((engine.routeExhaustionTest('ET2', 41).week, engine.routeExhaustionTest('ET2', 41).column), (5, 3));
    });

    test('ET3 thresholds (gate to Week 6)', () {
      expect(engine.routeExhaustionTest('ET3', 45).isRepeat, isTrue);
      expect(engine.routeExhaustionTest('ET3', 45).targetWeek, 5);
      expect((engine.routeExhaustionTest('ET3', 46).week, engine.routeExhaustionTest('ET3', 46).column), (6, 1));
      expect((engine.routeExhaustionTest('ET3', 50).week, engine.routeExhaustionTest('ET3', 50).column), (6, 1));
      expect((engine.routeExhaustionTest('ET3', 51).week, engine.routeExhaustionTest('ET3', 51).column), (6, 2));
      expect((engine.routeExhaustionTest('ET3', 60).week, engine.routeExhaustionTest('ET3', 60).column), (6, 2));
      expect((engine.routeExhaustionTest('ET3', 61).week, engine.routeExhaustionTest('ET3', 61).column), (6, 3));
    });
  });

  group('final test', () {
    test('passes at 100, fails at 99', () {
      expect(engine.finalTestPassed(99), isFalse);
      expect(engine.finalTestPassed(100), isTrue);
      expect(engine.finalTestPassed(120), isTrue);
    });
  });

  group('workout completion routing', () {
    test('mid-week advances to the next day', () {
      final r = engine.routeWorkoutCompletion(1, 0, 2);
      expect(r.action, 'next_day');
      expect((r.week, r.day, r.column), (1, 1, 2));
    });

    test('weeks without a test gate advance to the next week', () {
      expect(engine.routeWorkoutCompletion(1, 2, 2).action, 'next_week');
      expect(engine.routeWorkoutCompletion(1, 2, 2).week, 2);
      expect(engine.routeWorkoutCompletion(3, 2, 1).action, 'next_week');
      expect(engine.routeWorkoutCompletion(3, 2, 1).week, 4);
    });

    test('weeks 2, 4 and 5 require an exhaustion test', () {
      for (final (week, testId) in [(2, 'ET1'), (4, 'ET2'), (5, 'ET3')]) {
        final r = engine.routeWorkoutCompletion(week, 2, 3);
        expect(r.action, 'exhaustion_test', reason: 'week $week');
        expect(r.testId, testId);
        expect(r.week, week + 1);
      }
    });

    test('week 6 leads to the final test', () {
      expect(engine.routeWorkoutCompletion(6, 2, 1).action, 'final_test');
    });

    test('routing json in the asset is well-formed', () {
      final raw = json.decode(File('assets/program_v1.json').readAsStringSync()) as Map<String, dynamic>;
      expect(raw['version'], 1);
      expect((raw['exhaustionTests'] as List).length, 3);
    });
  });
}
