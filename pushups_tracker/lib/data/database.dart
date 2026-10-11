import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Re-export the drift symbols that callers need to build companions and
// ordering terms, so presentation code does not have to import drift directly.
export 'package:drift/drift.dart' show Value, OrderingTerm;

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Profile (spec §3.1 step 2). Only `age` influences anything (rank band).
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get age => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get sex => text().withDefault(const Constant('unspecified'))(); // female | male | other | unspecified

  TextColumn get daysOfWeek => text()(); // JSON e.g. "[1,3,5]"
  TextColumn get timeOfDay => text()(); // "18:00"
  BoolColumn get notifEnabled => boolean().withDefault(const Constant(false))();

  /// Extra reminder the evening before each slot.
  BoolColumn get notifDayBefore => boolean().withDefault(const Constant(false))();
  BoolColumn get onboardingComplete => boolean().withDefault(const Constant(false))();

  /// Next workout to do. `currentDay` is 0-based (0..2).
  IntColumn get currentWeek => integer().nullable()();
  IntColumn get currentDay => integer().nullable()();
  IntColumn get currentColumn => integer().nullable()();

  /// Test that must be recorded before the next workout can start:
  /// `ET1` | `ET2` | `ET3` | `final`, or null when no test is due.
  TextColumn get pendingTest => text().nullable()();

  /// Set when the final test has been passed.
  DateTimeColumn get programCompletedAt => dateTime().nullable()();
}

@TableIndex(name: 'scheduled_slots_status_due', columns: {#status, #dueAt})
class ScheduledSlots extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get dueAt => dateTime()();
  IntColumn get week => integer().nullable()();
  IntColumn get day => integer().nullable()(); // 0-based
  TextColumn get kind => text()(); // workout | exhaustion | final_test
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending | done | missed | rescheduled | skipped
  IntColumn get attemptOfDay => integer().withDefault(const Constant(1))();
  IntColumn get backlogCount => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();

  /// When set, this slot resumes an existing incomplete workout.
  IntColumn get resumeWorkoutId => integer().nullable()();
}

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scheduledSlotId => integer().references(ScheduledSlots, #id)();
  IntColumn get week => integer()();
  IntColumn get day => integer()(); // 0-based
  IntColumn get column => integer()();
  TextColumn get status => text().withDefault(const Constant('incomplete'))(); // completed | incomplete | abandoned
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  BoolColumn get repeatFlag => boolean().withDefault(const Constant(false))();
}

@TableIndex(name: 'workout_sets_workout', columns: {#workoutId})
class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId => integer().references(Workouts, #id)();
  IntColumn get setIndex => integer()();
  IntColumn get prescribed => integer()();
  BoolColumn get isPlus => boolean().withDefault(const Constant(false))();
  IntColumn get performed => integer().nullable()(); // null = not attempted
  IntColumn get restExtendedSec => integer().withDefault(const Constant(0))();
}

class Tests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()(); // initial | exhaustion | final
  IntColumn get scheduledSlotId => integer().nullable().references(ScheduledSlots, #id)();
  IntColumn get result => integer()();
  DateTimeColumn get takenAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get routing => text().nullable()(); // JSON: computed next week/column or repeat
}

/// Read model for the history timeline (one row per workout with set counts).
class WorkoutSummary {
  final int id;
  final int week;
  final int day;
  final int column;
  final String status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int totalSets;
  final int doneSets;
  final int totalReps;
  final bool repeatFlag;

  const WorkoutSummary({
    required this.id,
    required this.week,
    required this.day,
    required this.column,
    required this.status,
    required this.startedAt,
    required this.finishedAt,
    required this.totalSets,
    required this.doneSets,
    required this.totalReps,
    required this.repeatFlag,
  });

  DateTime? get date => finishedAt ?? startedAt;
}

/// Best `+` set of one workout, for the progress chart's secondary dots.
class PlusSetPoint {
  final int workoutId;
  final int week;
  final int day;
  final DateTime date;
  final int best;
  final int prescribed;

  const PlusSetPoint({
    required this.workoutId,
    required this.week,
    required this.day,
    required this.date,
    required this.best,
    required this.prescribed,
  });
}

@DriftDatabase(tables: [Users, ScheduledSlots, Workouts, WorkoutSets, Tests])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For tests: run against an in-memory or custom executor.
  AppDatabase.withExecutor(super.executor);

  /// v1: initial schema. v2: profile columns on `users` (name, age, weightKg, sex).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(users, users.name);
            await m.addColumn(users, users.age);
            await m.addColumn(users, users.weightKg);
            await m.addColumn(users, users.sex);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'pushups.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // ---------------------------------------------------------------- Users

  Future<User?> getUser() async {
    final results = await (select(users)..limit(1)).get();
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> createUser(UsersCompanion user) => into(users).insert(user);

  /// Updates the row identified by `user.id`. The companion must carry an id.
  Future<int> updateUser(UsersCompanion user) {
    assert(user.id.present, 'updateUser requires an id');
    return (update(users)..where((u) => u.id.equals(user.id.value))).write(user);
  }

  // ------------------------------------------------------- Scheduled slots

  Future<List<ScheduledSlot>> getPendingSlots({int? limit}) {
    final q = select(scheduledSlots)
      ..where((s) => s.status.equals('pending'))
      ..orderBy([(s) => OrderingTerm.asc(s.dueAt), (s) => OrderingTerm.asc(s.id)]);
    if (limit != null) q.limit(limit);
    return q.get();
  }

  Future<ScheduledSlot?> getSlot(int id) {
    return (select(scheduledSlots)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// Pending slots whose due time is earlier than [before].
  Future<List<ScheduledSlot>> getOverdueSlots(DateTime before) {
    return (select(scheduledSlots)
          ..where((s) => s.status.equals('pending') & s.dueAt.isSmallerThanValue(before))
          ..orderBy([(s) => OrderingTerm.asc(s.dueAt)]))
        .get();
  }

  /// Missed and skipped slots, newest first (for the history timeline).
  Future<List<ScheduledSlot>> getSlotHistory() {
    return (select(scheduledSlots)
          ..where((s) => s.status.isIn(['missed', 'skipped']))
          ..orderBy([(s) => OrderingTerm.desc(s.dueAt)]))
        .get();
  }

  Future<int> insertSlot(ScheduledSlotsCompanion slot) => into(scheduledSlots).insert(slot);

  Future<int> updateSlotStatus(int id, String status) {
    return (update(scheduledSlots)..where((s) => s.id.equals(id)))
        .write(ScheduledSlotsCompanion(status: Value(status)));
  }

  /// Removes every slot that has not been acted on yet. Slots with history
  /// (done / missed / rescheduled / skipped) are never touched.
  Future<int> clearPendingSlots() {
    return (delete(scheduledSlots)..where((s) => s.status.equals('pending'))).go();
  }

  // -------------------------------------------------------------- Workouts

  Future<int> insertWorkout(WorkoutsCompanion workout) => into(workouts).insert(workout);

  Future<Workout?> getWorkout(int id) {
    return (select(workouts)..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  Future<int> updateWorkoutStatus(int id, String status, {DateTime? finishedAt}) {
    return (update(workouts)..where((w) => w.id.equals(id))).write(WorkoutsCompanion(
      status: Value(status),
      finishedAt: finishedAt == null ? const Value.absent() : Value(finishedAt),
    ));
  }

  Future<List<Workout>> getIncompleteWorkouts() {
    return (select(workouts)
          ..where((w) => w.status.equals('incomplete'))
          ..orderBy([(w) => OrderingTerm.asc(w.startedAt), (w) => OrderingTerm.asc(w.id)]))
        .get();
  }

  /// `"week:day"` keys of every completed workout (for program-browser marks).
  Future<Set<String>> getCompletedDayKeys() async {
    final rows = await customSelect(
      "SELECT DISTINCT week || ':' || day AS k FROM workouts WHERE status = 'completed'",
    ).get();
    return rows.map((r) => r.read<String>('k')).toSet();
  }

  /// Marks every completed workout of [week] as part of a repeated attempt.
  Future<int> flagRepeatWeek(int week) {
    return (update(workouts)..where((w) => w.week.equals(week) & w.status.equals('completed')))
        .write(const WorkoutsCompanion(repeatFlag: Value(true)));
  }

  Future<DateTime?> getLastCompletedWorkoutDate() async {
    final row = await (select(workouts)
          ..where((w) => w.status.equals('completed'))
          ..orderBy([(w) => OrderingTerm.desc(w.finishedAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.finishedAt ?? row?.startedAt;
  }

  // ---------------------------------------------------------- Workout sets

  Future<int> insertSet(WorkoutSetsCompanion set) => into(workoutSets).insert(set);

  Future<List<WorkoutSet>> getSetsForWorkout(int workoutId) {
    return (select(workoutSets)
          ..where((s) => s.workoutId.equals(workoutId))
          ..orderBy([(s) => OrderingTerm.asc(s.setIndex)]))
        .get();
  }

  Future<int> updateSetResult(int setId, {required int? performed, required int restExtendedSec}) {
    return (update(workoutSets)..where((s) => s.id.equals(setId))).write(WorkoutSetsCompanion(
      performed: Value(performed),
      restExtendedSec: Value(restExtendedSec),
    ));
  }

  // ----------------------------------------------------------------- Tests

  Future<int> insertTest(TestsCompanion test) => into(tests).insert(test);

  Future<List<Test>> getAllTests() {
    return (select(tests)..orderBy([(t) => OrderingTerm.asc(t.takenAt)])).get();
  }

  Future<Test?> getLatestTest() {
    return (select(tests)
          ..orderBy([(t) => OrderingTerm.desc(t.takenAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  // ----------------------------------------------------------------- Stats

  Future<int> getTotalPushups() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(performed), 0) AS total FROM workout_sets WHERE performed IS NOT NULL',
    ).getSingle();
    return result.read<int>('total');
  }

  Future<int> getBestSet() async {
    final result = await customSelect(
      'SELECT COALESCE(MAX(performed), 0) AS best FROM workout_sets WHERE performed IS NOT NULL',
    ).getSingle();
    return result.read<int>('best');
  }

  Future<int> getBestTest() async {
    final result = await customSelect('SELECT COALESCE(MAX(result), 0) AS best FROM tests').getSingle();
    return result.read<int>('best');
  }

  Future<int> getCompletedWorkoutCount() async {
    final result = await customSelect(
      "SELECT COUNT(*) AS cnt FROM workouts WHERE status = 'completed'",
    ).getSingle();
    return result.read<int>('cnt');
  }

  /// Total reps per week ("YYYY-WW"), from every set actually performed.
  /// Drift stores DateTime as Unix seconds, hence the 'unixepoch' modifier.
  Future<List<Map<String, dynamic>>> getWeeklyVolume() async {
    final results = await customSelect(
      "SELECT strftime('%Y-%W', w.started_at, 'unixepoch', 'localtime') AS week, "
      'COALESCE(SUM(ws.performed), 0) AS total '
      'FROM workouts w '
      'JOIN workout_sets ws ON ws.workout_id = w.id '
      'WHERE ws.performed IS NOT NULL AND w.started_at IS NOT NULL '
      'GROUP BY week '
      'ORDER BY week',
    ).get();
    return results
        .map((r) => {
              'week': r.read<String>('week'),
              'total': r.read<int>('total'),
            })
        .toList();
  }

  /// Every workout (any status) with set counts, newest first.
  Future<List<WorkoutSummary>> getWorkoutSummaries() async {
    final rows = await customSelect(
      'SELECT w.id, w.week, w.day, w."column" AS col, w.status, w.started_at, w.finished_at, w.repeat_flag, '
      'COUNT(ws.id) AS total_sets, '
      'COUNT(ws.performed) AS done_sets, '
      'COALESCE(SUM(ws.performed), 0) AS total_reps '
      'FROM workouts w '
      'LEFT JOIN workout_sets ws ON ws.workout_id = w.id '
      'GROUP BY w.id '
      'ORDER BY COALESCE(w.finished_at, w.started_at) DESC, w.id DESC',
    ).get();
    return rows
        .map((r) => WorkoutSummary(
              id: r.read<int>('id'),
              week: r.read<int>('week'),
              day: r.read<int>('day'),
              column: r.read<int>('col'),
              status: r.read<String>('status'),
              startedAt: r.readNullable<DateTime>('started_at'),
              finishedAt: r.readNullable<DateTime>('finished_at'),
              totalSets: r.read<int>('total_sets'),
              doneSets: r.read<int>('done_sets'),
              totalReps: r.read<int>('total_reps'),
              repeatFlag: r.read<bool>('repeat_flag'),
            ))
        .toList();
  }

  /// Best performed `+` set per workout, oldest first.
  Future<List<PlusSetPoint>> getPlusSetHistory() async {
    final rows = await customSelect(
      'SELECT w.id, w.week, w.day, COALESCE(w.finished_at, w.started_at) AS at, '
      'MAX(ws.performed) AS best, ws.prescribed AS prescribed '
      'FROM workouts w '
      'JOIN workout_sets ws ON ws.workout_id = w.id '
      'WHERE ws.is_plus = 1 AND ws.performed IS NOT NULL AND COALESCE(w.finished_at, w.started_at) IS NOT NULL '
      'GROUP BY w.id '
      'ORDER BY at',
    ).get();
    return rows
        .map((r) => PlusSetPoint(
              workoutId: r.read<int>('id'),
              week: r.read<int>('week'),
              day: r.read<int>('day'),
              date: r.read<DateTime>('at'),
              best: r.read<int>('best'),
              prescribed: r.read<int>('prescribed'),
            ))
        .toList();
  }

  // ---------------------------------------------------------------- Admin

  /// Deletes every row in every table (child tables first for FK safety).
  Future<void> resetAll() => transaction(() async {
        await delete(tests).go();
        await delete(workoutSets).go();
        await delete(workouts).go();
        await delete(scheduledSlots).go();
        await delete(users).go();
      });
}
