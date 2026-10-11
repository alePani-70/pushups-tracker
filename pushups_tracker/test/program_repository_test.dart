import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushups_tracker/data/program_repository.dart';

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
  late ProgramRepository repo;

  setUpAll(() async {
    repo = await loadProgram();
  });

  group('planFor', () {
    test('Week 1 Day 1 Column 3 matches the program table', () {
      final plan = repo.planFor(week: 1, day: 0, column: 3)!;
      expect(plan.summary, '10 · 12 · 7 · 7 · 9+');
      expect(plan.restSeconds, 60);
      expect(plan.totalMinReps, 45);
      expect(plan.columnLabel, '11-20');
      expect(plan.sets.last.isPlus, isTrue);
      // 45 reps × 2 s + 4 rests × 60 s = 330 s → 6 min
      expect(plan.estimatedMinutes, 6);
    });

    test('Week 5 Day 2 has 8 sets with 45 s rest', () {
      final plan = repo.planFor(week: 5, day: 1, column: 1)!;
      expect(plan.setCount, 8);
      expect(plan.restSeconds, 45);
      expect(plan.sets.where((s) => s.isPlus).length, 1);
    });

    test('out-of-range column is clamped and invalid day is null', () {
      expect(repo.planFor(week: 1, day: 0, column: 9)!.column, 3);
      expect(repo.planFor(week: 1, day: 0, column: 0)!.column, 1);
      expect(repo.planFor(week: 1, day: 3, column: 1), isNull);
      expect(repo.planFor(week: 7, day: 0, column: 1), isNull);
    });
  });

  group('rank table', () {
    test('age bands', () {
      expect(ProgramRepository.ageBandKey(25), 'age_lt40');
      expect(ProgramRepository.ageBandKey(39), 'age_lt40');
      expect(ProgramRepository.ageBandKey(40), 'age_40_55');
      expect(ProgramRepository.ageBandKey(55), 'age_40_55');
      expect(ProgramRepository.ageBandKey(56), 'age_gt55');
    });

    test('ranks per band from the program table', () {
      expect(repo.rankFor(age: 30, result: 4), 1);
      expect(repo.rankFor(age: 30, result: 14), 2);
      expect(repo.rankFor(age: 30, result: 15), 3);
      expect(repo.rankFor(age: 45, result: 13), 3);
      expect(repo.rankFor(age: 60, result: 11), 3);
      expect(repo.rankFor(age: 60, result: 101), 7);
      expect(repo.rankFor(age: 30, result: 151), 7);
    });

    test('inRange parses both range styles', () {
      expect(ProgramRepository.inRange('6-14', 6), isTrue);
      expect(ProgramRepository.inRange('6-14', 14), isTrue);
      expect(ProgramRepository.inRange('6-14', 15), isFalse);
      expect(ProgramRepository.inRange('>150', 150), isFalse);
      expect(ProgramRepository.inRange('>150', 151), isTrue);
      expect(ProgramRepository.inRange('garbage', 1), isFalse);
    });
  });

  group('describeRouting', () {
    test('initial routing reads naturally', () {
      final routing = (repo.initialTest!['startRouting'] as List).cast<Map<String, dynamic>>();
      expect(
        repo.describeRouting(routing),
        '≤5 → Week 1 Col 1 · 6–10 → Week 1 Col 2 · 11–20 → Week 1 Col 3 · 21–30 → Week 3 Col 2 · >30 → Week 3 Col 3',
      );
    });

    test('exhaustion test routing includes the repeat rule', () {
      final et1 = repo.getExhaustionTestAfterWeek(2)!;
      final text = repo.describeRouting((et1['routing'] as List).cast<Map<String, dynamic>>());
      expect(text, startsWith('≤15 repeat Week 2 · 16–20 → Week 3 Col 1'));
      expect(text, endsWith('>25 → Week 3 Col 3'));
    });
  });
}
