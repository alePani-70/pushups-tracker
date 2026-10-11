import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushups_tracker/data/database.dart';
import 'package:pushups_tracker/data/program_repository.dart';
import 'package:pushups_tracker/services/export_service.dart';
import 'package:pushups_tracker/services/notification_service.dart';
import 'package:pushups_tracker/services/reschedule_engine.dart';

/// Pure-logic tests for the parts of the engine that do not touch the DB.
/// The database is constructed lazily and never opened here.
void main() {
  late RescheduleEngine engine;

  setUpAll(() {
    engine = RescheduleEngine(
      AppDatabase.withExecutor(NativeDatabase.memory()),
      NotificationService(),
      ProgramRepository(),
    );
  });

  group('parseDays / encodeDays', () {
    test('round-trips and sorts', () {
      expect(RescheduleEngine.parseDays('[5,1,3]'), [1, 3, 5]);
      expect(RescheduleEngine.encodeDays([5, 1, 3]), '[1,3,5]');
      expect(RescheduleEngine.parseDays(RescheduleEngine.encodeDays({2, 4, 6})), [2, 4, 6]);
    });

    test('falls back to Mon/Wed/Fri on garbage', () {
      expect(RescheduleEngine.parseDays(''), [1, 3, 5]);
      expect(RescheduleEngine.parseDays('not json'), [1, 3, 5]);
      expect(RescheduleEngine.parseDays('[]'), [1, 3, 5]);
      expect(RescheduleEngine.parseDays('[0, 8]'), [1, 3, 5]);
    });

    test('drops duplicates and out-of-range days', () {
      expect(RescheduleEngine.parseDays('[1,1,7,9]'), [1, 7]);
    });
  });

  group('hasConsecutiveDays', () {
    test('Mon/Wed/Fri has none', () {
      expect(RescheduleEngine.hasConsecutiveDays([1, 3, 5]), isFalse);
    });
    test('Tue/Thu/Sat has none', () {
      expect(RescheduleEngine.hasConsecutiveDays([2, 4, 6]), isFalse);
    });
    test('Mon/Tue is consecutive', () {
      expect(RescheduleEngine.hasConsecutiveDays([1, 2, 5]), isTrue);
    });
    test('Sun/Mon wraps around the week', () {
      expect(RescheduleEngine.hasConsecutiveDays([7, 1, 4]), isTrue);
    });
  });

  group('generateSlots', () {
    test('returns the requested number of slots on chosen weekdays at the chosen time', () {
      final from = DateTime(2026, 10, 12, 9); // Monday 09:00
      final slots = engine.generateSlots(daysOfWeek: [1, 3, 5], timeOfDay: '18:30', from: from, count: 6);
      expect(slots.length, 6);
      for (final s in slots) {
        expect([1, 3, 5], contains(s.weekday));
        expect(s.hour, 18);
        expect(s.minute, 30);
      }
      expect(slots.first, DateTime(2026, 10, 12, 18, 30)); // same Monday, time not yet passed
      expect(slots[1], DateTime(2026, 10, 14, 18, 30));
      expect(slots[2], DateTime(2026, 10, 16, 18, 30));
      expect(slots[3], DateTime(2026, 10, 19, 18, 30));
    });

    test('skips today when the slot time has already passed', () {
      final from = DateTime(2026, 10, 12, 19); // Monday 19:00, after 18:00 slot
      final slots = engine.generateSlots(daysOfWeek: [1, 3, 5], timeOfDay: '18:00', from: from, count: 1);
      expect(slots.single, DateTime(2026, 10, 14, 18)); // Wednesday
    });

    test('a slot exactly at `from` is included', () {
      final from = DateTime(2026, 10, 12, 18);
      final slots = engine.generateSlots(daysOfWeek: [1], timeOfDay: '18:00', from: from, count: 1);
      expect(slots.single, from);
    });

    test('is sorted ascending and spans month boundaries', () {
      final from = DateTime(2026, 10, 30);
      final slots = engine.generateSlots(daysOfWeek: [1, 3, 5], timeOfDay: '07:00', from: from, count: 10);
      for (var i = 1; i < slots.length; i++) {
        expect(slots[i].isAfter(slots[i - 1]), isTrue);
      }
      expect(slots.any((s) => s.month == 11), isTrue);
    });

    test('handles empty input', () {
      expect(engine.generateSlots(daysOfWeek: [], timeOfDay: '18:00', from: DateTime.now(), count: 3), isEmpty);
      expect(engine.generateSlots(daysOfWeek: [1], timeOfDay: '18:00', from: DateTime.now(), count: 0), isEmpty);
    });

    test('tolerates a malformed time string', () {
      final slots = engine.generateSlots(daysOfWeek: [1], timeOfDay: 'nope', from: DateTime(2026, 10, 12), count: 1);
      expect(slots.single.hour, 18);
      expect(slots.single.minute, 0);
    });
  });

  group('date helpers', () {
    test('startOfDay / startOfTomorrow', () {
      final t = DateTime(2026, 10, 11, 23, 59);
      expect(RescheduleEngine.startOfDay(t), DateTime(2026, 10, 11));
      expect(RescheduleEngine.startOfTomorrow(t), DateTime(2026, 10, 12));
    });
  });

  group('csv export', () {
    test('escapes commas, quotes and newlines', () {
      final csv = ExportService.toCsv([
        {'id': 1, 'notes': 'plain', 'when': null},
        {'id': 2, 'notes': 'has, comma and "quotes"\nand newline', 'when': '2026-10-11'},
      ]);
      final lines = csv.trim().split('\n');
      expect(lines.first, 'id,notes,when');
      expect(lines[1], '1,plain,');
      expect(csv, contains('"has, comma and ""quotes""\nand newline"'));
    });

    test('empty input yields empty string', () {
      expect(ExportService.toCsv(const []), '');
    });
  });
}
