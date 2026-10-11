// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unspecified'));
  static const VerificationMeta _daysOfWeekMeta =
      const VerificationMeta('daysOfWeek');
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
      'days_of_week', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeOfDayMeta =
      const VerificationMeta('timeOfDay');
  @override
  late final GeneratedColumn<String> timeOfDay = GeneratedColumn<String>(
      'time_of_day', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notifEnabledMeta =
      const VerificationMeta('notifEnabled');
  @override
  late final GeneratedColumn<bool> notifEnabled = GeneratedColumn<bool>(
      'notif_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notif_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notifDayBeforeMeta =
      const VerificationMeta('notifDayBefore');
  @override
  late final GeneratedColumn<bool> notifDayBefore = GeneratedColumn<bool>(
      'notif_day_before', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notif_day_before" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
      'onboarding_complete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_complete" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _currentWeekMeta =
      const VerificationMeta('currentWeek');
  @override
  late final GeneratedColumn<int> currentWeek = GeneratedColumn<int>(
      'current_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currentDayMeta =
      const VerificationMeta('currentDay');
  @override
  late final GeneratedColumn<int> currentDay = GeneratedColumn<int>(
      'current_day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currentColumnMeta =
      const VerificationMeta('currentColumn');
  @override
  late final GeneratedColumn<int> currentColumn = GeneratedColumn<int>(
      'current_column', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pendingTestMeta =
      const VerificationMeta('pendingTest');
  @override
  late final GeneratedColumn<String> pendingTest = GeneratedColumn<String>(
      'pending_test', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _programCompletedAtMeta =
      const VerificationMeta('programCompletedAt');
  @override
  late final GeneratedColumn<DateTime> programCompletedAt =
      GeneratedColumn<DateTime>('program_completed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        name,
        age,
        weightKg,
        sex,
        daysOfWeek,
        timeOfDay,
        notifEnabled,
        notifDayBefore,
        onboardingComplete,
        currentWeek,
        currentDay,
        currentColumn,
        pendingTest,
        programCompletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
          _daysOfWeekMeta,
          daysOfWeek.isAcceptableOrUnknown(
              data['days_of_week']!, _daysOfWeekMeta));
    } else if (isInserting) {
      context.missing(_daysOfWeekMeta);
    }
    if (data.containsKey('time_of_day')) {
      context.handle(
          _timeOfDayMeta,
          timeOfDay.isAcceptableOrUnknown(
              data['time_of_day']!, _timeOfDayMeta));
    } else if (isInserting) {
      context.missing(_timeOfDayMeta);
    }
    if (data.containsKey('notif_enabled')) {
      context.handle(
          _notifEnabledMeta,
          notifEnabled.isAcceptableOrUnknown(
              data['notif_enabled']!, _notifEnabledMeta));
    }
    if (data.containsKey('notif_day_before')) {
      context.handle(
          _notifDayBeforeMeta,
          notifDayBefore.isAcceptableOrUnknown(
              data['notif_day_before']!, _notifDayBeforeMeta));
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
          _onboardingCompleteMeta,
          onboardingComplete.isAcceptableOrUnknown(
              data['onboarding_complete']!, _onboardingCompleteMeta));
    }
    if (data.containsKey('current_week')) {
      context.handle(
          _currentWeekMeta,
          currentWeek.isAcceptableOrUnknown(
              data['current_week']!, _currentWeekMeta));
    }
    if (data.containsKey('current_day')) {
      context.handle(
          _currentDayMeta,
          currentDay.isAcceptableOrUnknown(
              data['current_day']!, _currentDayMeta));
    }
    if (data.containsKey('current_column')) {
      context.handle(
          _currentColumnMeta,
          currentColumn.isAcceptableOrUnknown(
              data['current_column']!, _currentColumnMeta));
    }
    if (data.containsKey('pending_test')) {
      context.handle(
          _pendingTestMeta,
          pendingTest.isAcceptableOrUnknown(
              data['pending_test']!, _pendingTestMeta));
    }
    if (data.containsKey('program_completed_at')) {
      context.handle(
          _programCompletedAtMeta,
          programCompletedAt.isAcceptableOrUnknown(
              data['program_completed_at']!, _programCompletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex'])!,
      daysOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}days_of_week'])!,
      timeOfDay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_of_day'])!,
      notifEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}notif_enabled'])!,
      notifDayBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}notif_day_before'])!,
      onboardingComplete: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_complete'])!,
      currentWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_week']),
      currentDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_day']),
      currentColumn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_column']),
      pendingTest: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pending_test']),
      programCompletedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}program_completed_at']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final DateTime createdAt;
  final String name;
  final int? age;
  final double? weightKg;
  final String sex;
  final String daysOfWeek;
  final String timeOfDay;
  final bool notifEnabled;

  /// Extra reminder the evening before each slot.
  final bool notifDayBefore;
  final bool onboardingComplete;

  /// Next workout to do. `currentDay` is 0-based (0..2).
  final int? currentWeek;
  final int? currentDay;
  final int? currentColumn;

  /// Test that must be recorded before the next workout can start:
  /// `ET1` | `ET2` | `ET3` | `final`, or null when no test is due.
  final String? pendingTest;

  /// Set when the final test has been passed.
  final DateTime? programCompletedAt;
  const User(
      {required this.id,
      required this.createdAt,
      required this.name,
      this.age,
      this.weightKg,
      required this.sex,
      required this.daysOfWeek,
      required this.timeOfDay,
      required this.notifEnabled,
      required this.notifDayBefore,
      required this.onboardingComplete,
      this.currentWeek,
      this.currentDay,
      this.currentColumn,
      this.pendingTest,
      this.programCompletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    map['sex'] = Variable<String>(sex);
    map['days_of_week'] = Variable<String>(daysOfWeek);
    map['time_of_day'] = Variable<String>(timeOfDay);
    map['notif_enabled'] = Variable<bool>(notifEnabled);
    map['notif_day_before'] = Variable<bool>(notifDayBefore);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    if (!nullToAbsent || currentWeek != null) {
      map['current_week'] = Variable<int>(currentWeek);
    }
    if (!nullToAbsent || currentDay != null) {
      map['current_day'] = Variable<int>(currentDay);
    }
    if (!nullToAbsent || currentColumn != null) {
      map['current_column'] = Variable<int>(currentColumn);
    }
    if (!nullToAbsent || pendingTest != null) {
      map['pending_test'] = Variable<String>(pendingTest);
    }
    if (!nullToAbsent || programCompletedAt != null) {
      map['program_completed_at'] = Variable<DateTime>(programCompletedAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      name: Value(name),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      sex: Value(sex),
      daysOfWeek: Value(daysOfWeek),
      timeOfDay: Value(timeOfDay),
      notifEnabled: Value(notifEnabled),
      notifDayBefore: Value(notifDayBefore),
      onboardingComplete: Value(onboardingComplete),
      currentWeek: currentWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(currentWeek),
      currentDay: currentDay == null && nullToAbsent
          ? const Value.absent()
          : Value(currentDay),
      currentColumn: currentColumn == null && nullToAbsent
          ? const Value.absent()
          : Value(currentColumn),
      pendingTest: pendingTest == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingTest),
      programCompletedAt: programCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(programCompletedAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int?>(json['age']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      sex: serializer.fromJson<String>(json['sex']),
      daysOfWeek: serializer.fromJson<String>(json['daysOfWeek']),
      timeOfDay: serializer.fromJson<String>(json['timeOfDay']),
      notifEnabled: serializer.fromJson<bool>(json['notifEnabled']),
      notifDayBefore: serializer.fromJson<bool>(json['notifDayBefore']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
      currentWeek: serializer.fromJson<int?>(json['currentWeek']),
      currentDay: serializer.fromJson<int?>(json['currentDay']),
      currentColumn: serializer.fromJson<int?>(json['currentColumn']),
      pendingTest: serializer.fromJson<String?>(json['pendingTest']),
      programCompletedAt:
          serializer.fromJson<DateTime?>(json['programCompletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int?>(age),
      'weightKg': serializer.toJson<double?>(weightKg),
      'sex': serializer.toJson<String>(sex),
      'daysOfWeek': serializer.toJson<String>(daysOfWeek),
      'timeOfDay': serializer.toJson<String>(timeOfDay),
      'notifEnabled': serializer.toJson<bool>(notifEnabled),
      'notifDayBefore': serializer.toJson<bool>(notifDayBefore),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
      'currentWeek': serializer.toJson<int?>(currentWeek),
      'currentDay': serializer.toJson<int?>(currentDay),
      'currentColumn': serializer.toJson<int?>(currentColumn),
      'pendingTest': serializer.toJson<String?>(pendingTest),
      'programCompletedAt': serializer.toJson<DateTime?>(programCompletedAt),
    };
  }

  User copyWith(
          {int? id,
          DateTime? createdAt,
          String? name,
          Value<int?> age = const Value.absent(),
          Value<double?> weightKg = const Value.absent(),
          String? sex,
          String? daysOfWeek,
          String? timeOfDay,
          bool? notifEnabled,
          bool? notifDayBefore,
          bool? onboardingComplete,
          Value<int?> currentWeek = const Value.absent(),
          Value<int?> currentDay = const Value.absent(),
          Value<int?> currentColumn = const Value.absent(),
          Value<String?> pendingTest = const Value.absent(),
          Value<DateTime?> programCompletedAt = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        name: name ?? this.name,
        age: age.present ? age.value : this.age,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        sex: sex ?? this.sex,
        daysOfWeek: daysOfWeek ?? this.daysOfWeek,
        timeOfDay: timeOfDay ?? this.timeOfDay,
        notifEnabled: notifEnabled ?? this.notifEnabled,
        notifDayBefore: notifDayBefore ?? this.notifDayBefore,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        currentWeek: currentWeek.present ? currentWeek.value : this.currentWeek,
        currentDay: currentDay.present ? currentDay.value : this.currentDay,
        currentColumn:
            currentColumn.present ? currentColumn.value : this.currentColumn,
        pendingTest: pendingTest.present ? pendingTest.value : this.pendingTest,
        programCompletedAt: programCompletedAt.present
            ? programCompletedAt.value
            : this.programCompletedAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      sex: data.sex.present ? data.sex.value : this.sex,
      daysOfWeek:
          data.daysOfWeek.present ? data.daysOfWeek.value : this.daysOfWeek,
      timeOfDay: data.timeOfDay.present ? data.timeOfDay.value : this.timeOfDay,
      notifEnabled: data.notifEnabled.present
          ? data.notifEnabled.value
          : this.notifEnabled,
      notifDayBefore: data.notifDayBefore.present
          ? data.notifDayBefore.value
          : this.notifDayBefore,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
      currentWeek:
          data.currentWeek.present ? data.currentWeek.value : this.currentWeek,
      currentDay:
          data.currentDay.present ? data.currentDay.value : this.currentDay,
      currentColumn: data.currentColumn.present
          ? data.currentColumn.value
          : this.currentColumn,
      pendingTest:
          data.pendingTest.present ? data.pendingTest.value : this.pendingTest,
      programCompletedAt: data.programCompletedAt.present
          ? data.programCompletedAt.value
          : this.programCompletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('weightKg: $weightKg, ')
          ..write('sex: $sex, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('notifEnabled: $notifEnabled, ')
          ..write('notifDayBefore: $notifDayBefore, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('currentWeek: $currentWeek, ')
          ..write('currentDay: $currentDay, ')
          ..write('currentColumn: $currentColumn, ')
          ..write('pendingTest: $pendingTest, ')
          ..write('programCompletedAt: $programCompletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      name,
      age,
      weightKg,
      sex,
      daysOfWeek,
      timeOfDay,
      notifEnabled,
      notifDayBefore,
      onboardingComplete,
      currentWeek,
      currentDay,
      currentColumn,
      pendingTest,
      programCompletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.age == this.age &&
          other.weightKg == this.weightKg &&
          other.sex == this.sex &&
          other.daysOfWeek == this.daysOfWeek &&
          other.timeOfDay == this.timeOfDay &&
          other.notifEnabled == this.notifEnabled &&
          other.notifDayBefore == this.notifDayBefore &&
          other.onboardingComplete == this.onboardingComplete &&
          other.currentWeek == this.currentWeek &&
          other.currentDay == this.currentDay &&
          other.currentColumn == this.currentColumn &&
          other.pendingTest == this.pendingTest &&
          other.programCompletedAt == this.programCompletedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<int?> age;
  final Value<double?> weightKg;
  final Value<String> sex;
  final Value<String> daysOfWeek;
  final Value<String> timeOfDay;
  final Value<bool> notifEnabled;
  final Value<bool> notifDayBefore;
  final Value<bool> onboardingComplete;
  final Value<int?> currentWeek;
  final Value<int?> currentDay;
  final Value<int?> currentColumn;
  final Value<String?> pendingTest;
  final Value<DateTime?> programCompletedAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.sex = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.notifEnabled = const Value.absent(),
    this.notifDayBefore = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.currentWeek = const Value.absent(),
    this.currentDay = const Value.absent(),
    this.currentColumn = const Value.absent(),
    this.pendingTest = const Value.absent(),
    this.programCompletedAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.sex = const Value.absent(),
    required String daysOfWeek,
    required String timeOfDay,
    this.notifEnabled = const Value.absent(),
    this.notifDayBefore = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.currentWeek = const Value.absent(),
    this.currentDay = const Value.absent(),
    this.currentColumn = const Value.absent(),
    this.pendingTest = const Value.absent(),
    this.programCompletedAt = const Value.absent(),
  })  : daysOfWeek = Value(daysOfWeek),
        timeOfDay = Value(timeOfDay);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<int>? age,
    Expression<double>? weightKg,
    Expression<String>? sex,
    Expression<String>? daysOfWeek,
    Expression<String>? timeOfDay,
    Expression<bool>? notifEnabled,
    Expression<bool>? notifDayBefore,
    Expression<bool>? onboardingComplete,
    Expression<int>? currentWeek,
    Expression<int>? currentDay,
    Expression<int>? currentColumn,
    Expression<String>? pendingTest,
    Expression<DateTime>? programCompletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (weightKg != null) 'weight_kg': weightKg,
      if (sex != null) 'sex': sex,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (timeOfDay != null) 'time_of_day': timeOfDay,
      if (notifEnabled != null) 'notif_enabled': notifEnabled,
      if (notifDayBefore != null) 'notif_day_before': notifDayBefore,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (currentWeek != null) 'current_week': currentWeek,
      if (currentDay != null) 'current_day': currentDay,
      if (currentColumn != null) 'current_column': currentColumn,
      if (pendingTest != null) 'pending_test': pendingTest,
      if (programCompletedAt != null)
        'program_completed_at': programCompletedAt,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<String>? name,
      Value<int?>? age,
      Value<double?>? weightKg,
      Value<String>? sex,
      Value<String>? daysOfWeek,
      Value<String>? timeOfDay,
      Value<bool>? notifEnabled,
      Value<bool>? notifDayBefore,
      Value<bool>? onboardingComplete,
      Value<int?>? currentWeek,
      Value<int?>? currentDay,
      Value<int?>? currentColumn,
      Value<String?>? pendingTest,
      Value<DateTime?>? programCompletedAt}) {
    return UsersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      sex: sex ?? this.sex,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      notifEnabled: notifEnabled ?? this.notifEnabled,
      notifDayBefore: notifDayBefore ?? this.notifDayBefore,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      currentColumn: currentColumn ?? this.currentColumn,
      pendingTest: pendingTest ?? this.pendingTest,
      programCompletedAt: programCompletedAt ?? this.programCompletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (timeOfDay.present) {
      map['time_of_day'] = Variable<String>(timeOfDay.value);
    }
    if (notifEnabled.present) {
      map['notif_enabled'] = Variable<bool>(notifEnabled.value);
    }
    if (notifDayBefore.present) {
      map['notif_day_before'] = Variable<bool>(notifDayBefore.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (currentWeek.present) {
      map['current_week'] = Variable<int>(currentWeek.value);
    }
    if (currentDay.present) {
      map['current_day'] = Variable<int>(currentDay.value);
    }
    if (currentColumn.present) {
      map['current_column'] = Variable<int>(currentColumn.value);
    }
    if (pendingTest.present) {
      map['pending_test'] = Variable<String>(pendingTest.value);
    }
    if (programCompletedAt.present) {
      map['program_completed_at'] =
          Variable<DateTime>(programCompletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('weightKg: $weightKg, ')
          ..write('sex: $sex, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('notifEnabled: $notifEnabled, ')
          ..write('notifDayBefore: $notifDayBefore, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('currentWeek: $currentWeek, ')
          ..write('currentDay: $currentDay, ')
          ..write('currentColumn: $currentColumn, ')
          ..write('pendingTest: $pendingTest, ')
          ..write('programCompletedAt: $programCompletedAt')
          ..write(')'))
        .toString();
  }
}

class $ScheduledSlotsTable extends ScheduledSlots
    with TableInfo<$ScheduledSlotsTable, ScheduledSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _weekMeta = const VerificationMeta('week');
  @override
  late final GeneratedColumn<int> week = GeneratedColumn<int>(
      'week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
      'day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _attemptOfDayMeta =
      const VerificationMeta('attemptOfDay');
  @override
  late final GeneratedColumn<int> attemptOfDay = GeneratedColumn<int>(
      'attempt_of_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _backlogCountMeta =
      const VerificationMeta('backlogCount');
  @override
  late final GeneratedColumn<int> backlogCount = GeneratedColumn<int>(
      'backlog_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resumeWorkoutIdMeta =
      const VerificationMeta('resumeWorkoutId');
  @override
  late final GeneratedColumn<int> resumeWorkoutId = GeneratedColumn<int>(
      'resume_workout_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dueAt,
        week,
        day,
        kind,
        status,
        attemptOfDay,
        backlogCount,
        notes,
        resumeWorkoutId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_slots';
  @override
  VerificationContext validateIntegrity(Insertable<ScheduledSlot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('week')) {
      context.handle(
          _weekMeta, week.isAcceptableOrUnknown(data['week']!, _weekMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('attempt_of_day')) {
      context.handle(
          _attemptOfDayMeta,
          attemptOfDay.isAcceptableOrUnknown(
              data['attempt_of_day']!, _attemptOfDayMeta));
    }
    if (data.containsKey('backlog_count')) {
      context.handle(
          _backlogCountMeta,
          backlogCount.isAcceptableOrUnknown(
              data['backlog_count']!, _backlogCountMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('resume_workout_id')) {
      context.handle(
          _resumeWorkoutIdMeta,
          resumeWorkoutId.isAcceptableOrUnknown(
              data['resume_workout_id']!, _resumeWorkoutIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledSlot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at'])!,
      week: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week']),
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attemptOfDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_of_day'])!,
      backlogCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}backlog_count'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      resumeWorkoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}resume_workout_id']),
    );
  }

  @override
  $ScheduledSlotsTable createAlias(String alias) {
    return $ScheduledSlotsTable(attachedDatabase, alias);
  }
}

class ScheduledSlot extends DataClass implements Insertable<ScheduledSlot> {
  final int id;
  final DateTime dueAt;
  final int? week;
  final int? day;
  final String kind;
  final String status;
  final int attemptOfDay;
  final int backlogCount;
  final String? notes;

  /// When set, this slot resumes an existing incomplete workout.
  final int? resumeWorkoutId;
  const ScheduledSlot(
      {required this.id,
      required this.dueAt,
      this.week,
      this.day,
      required this.kind,
      required this.status,
      required this.attemptOfDay,
      required this.backlogCount,
      this.notes,
      this.resumeWorkoutId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || week != null) {
      map['week'] = Variable<int>(week);
    }
    if (!nullToAbsent || day != null) {
      map['day'] = Variable<int>(day);
    }
    map['kind'] = Variable<String>(kind);
    map['status'] = Variable<String>(status);
    map['attempt_of_day'] = Variable<int>(attemptOfDay);
    map['backlog_count'] = Variable<int>(backlogCount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || resumeWorkoutId != null) {
      map['resume_workout_id'] = Variable<int>(resumeWorkoutId);
    }
    return map;
  }

  ScheduledSlotsCompanion toCompanion(bool nullToAbsent) {
    return ScheduledSlotsCompanion(
      id: Value(id),
      dueAt: Value(dueAt),
      week: week == null && nullToAbsent ? const Value.absent() : Value(week),
      day: day == null && nullToAbsent ? const Value.absent() : Value(day),
      kind: Value(kind),
      status: Value(status),
      attemptOfDay: Value(attemptOfDay),
      backlogCount: Value(backlogCount),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      resumeWorkoutId: resumeWorkoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(resumeWorkoutId),
    );
  }

  factory ScheduledSlot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledSlot(
      id: serializer.fromJson<int>(json['id']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      week: serializer.fromJson<int?>(json['week']),
      day: serializer.fromJson<int?>(json['day']),
      kind: serializer.fromJson<String>(json['kind']),
      status: serializer.fromJson<String>(json['status']),
      attemptOfDay: serializer.fromJson<int>(json['attemptOfDay']),
      backlogCount: serializer.fromJson<int>(json['backlogCount']),
      notes: serializer.fromJson<String?>(json['notes']),
      resumeWorkoutId: serializer.fromJson<int?>(json['resumeWorkoutId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'week': serializer.toJson<int?>(week),
      'day': serializer.toJson<int?>(day),
      'kind': serializer.toJson<String>(kind),
      'status': serializer.toJson<String>(status),
      'attemptOfDay': serializer.toJson<int>(attemptOfDay),
      'backlogCount': serializer.toJson<int>(backlogCount),
      'notes': serializer.toJson<String?>(notes),
      'resumeWorkoutId': serializer.toJson<int?>(resumeWorkoutId),
    };
  }

  ScheduledSlot copyWith(
          {int? id,
          DateTime? dueAt,
          Value<int?> week = const Value.absent(),
          Value<int?> day = const Value.absent(),
          String? kind,
          String? status,
          int? attemptOfDay,
          int? backlogCount,
          Value<String?> notes = const Value.absent(),
          Value<int?> resumeWorkoutId = const Value.absent()}) =>
      ScheduledSlot(
        id: id ?? this.id,
        dueAt: dueAt ?? this.dueAt,
        week: week.present ? week.value : this.week,
        day: day.present ? day.value : this.day,
        kind: kind ?? this.kind,
        status: status ?? this.status,
        attemptOfDay: attemptOfDay ?? this.attemptOfDay,
        backlogCount: backlogCount ?? this.backlogCount,
        notes: notes.present ? notes.value : this.notes,
        resumeWorkoutId: resumeWorkoutId.present
            ? resumeWorkoutId.value
            : this.resumeWorkoutId,
      );
  ScheduledSlot copyWithCompanion(ScheduledSlotsCompanion data) {
    return ScheduledSlot(
      id: data.id.present ? data.id.value : this.id,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      week: data.week.present ? data.week.value : this.week,
      day: data.day.present ? data.day.value : this.day,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      attemptOfDay: data.attemptOfDay.present
          ? data.attemptOfDay.value
          : this.attemptOfDay,
      backlogCount: data.backlogCount.present
          ? data.backlogCount.value
          : this.backlogCount,
      notes: data.notes.present ? data.notes.value : this.notes,
      resumeWorkoutId: data.resumeWorkoutId.present
          ? data.resumeWorkoutId.value
          : this.resumeWorkoutId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledSlot(')
          ..write('id: $id, ')
          ..write('dueAt: $dueAt, ')
          ..write('week: $week, ')
          ..write('day: $day, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('attemptOfDay: $attemptOfDay, ')
          ..write('backlogCount: $backlogCount, ')
          ..write('notes: $notes, ')
          ..write('resumeWorkoutId: $resumeWorkoutId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dueAt, week, day, kind, status,
      attemptOfDay, backlogCount, notes, resumeWorkoutId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledSlot &&
          other.id == this.id &&
          other.dueAt == this.dueAt &&
          other.week == this.week &&
          other.day == this.day &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.attemptOfDay == this.attemptOfDay &&
          other.backlogCount == this.backlogCount &&
          other.notes == this.notes &&
          other.resumeWorkoutId == this.resumeWorkoutId);
}

class ScheduledSlotsCompanion extends UpdateCompanion<ScheduledSlot> {
  final Value<int> id;
  final Value<DateTime> dueAt;
  final Value<int?> week;
  final Value<int?> day;
  final Value<String> kind;
  final Value<String> status;
  final Value<int> attemptOfDay;
  final Value<int> backlogCount;
  final Value<String?> notes;
  final Value<int?> resumeWorkoutId;
  const ScheduledSlotsCompanion({
    this.id = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.week = const Value.absent(),
    this.day = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptOfDay = const Value.absent(),
    this.backlogCount = const Value.absent(),
    this.notes = const Value.absent(),
    this.resumeWorkoutId = const Value.absent(),
  });
  ScheduledSlotsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime dueAt,
    this.week = const Value.absent(),
    this.day = const Value.absent(),
    required String kind,
    this.status = const Value.absent(),
    this.attemptOfDay = const Value.absent(),
    this.backlogCount = const Value.absent(),
    this.notes = const Value.absent(),
    this.resumeWorkoutId = const Value.absent(),
  })  : dueAt = Value(dueAt),
        kind = Value(kind);
  static Insertable<ScheduledSlot> custom({
    Expression<int>? id,
    Expression<DateTime>? dueAt,
    Expression<int>? week,
    Expression<int>? day,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<int>? attemptOfDay,
    Expression<int>? backlogCount,
    Expression<String>? notes,
    Expression<int>? resumeWorkoutId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dueAt != null) 'due_at': dueAt,
      if (week != null) 'week': week,
      if (day != null) 'day': day,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (attemptOfDay != null) 'attempt_of_day': attemptOfDay,
      if (backlogCount != null) 'backlog_count': backlogCount,
      if (notes != null) 'notes': notes,
      if (resumeWorkoutId != null) 'resume_workout_id': resumeWorkoutId,
    });
  }

  ScheduledSlotsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? dueAt,
      Value<int?>? week,
      Value<int?>? day,
      Value<String>? kind,
      Value<String>? status,
      Value<int>? attemptOfDay,
      Value<int>? backlogCount,
      Value<String?>? notes,
      Value<int?>? resumeWorkoutId}) {
    return ScheduledSlotsCompanion(
      id: id ?? this.id,
      dueAt: dueAt ?? this.dueAt,
      week: week ?? this.week,
      day: day ?? this.day,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      attemptOfDay: attemptOfDay ?? this.attemptOfDay,
      backlogCount: backlogCount ?? this.backlogCount,
      notes: notes ?? this.notes,
      resumeWorkoutId: resumeWorkoutId ?? this.resumeWorkoutId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (week.present) {
      map['week'] = Variable<int>(week.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptOfDay.present) {
      map['attempt_of_day'] = Variable<int>(attemptOfDay.value);
    }
    if (backlogCount.present) {
      map['backlog_count'] = Variable<int>(backlogCount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (resumeWorkoutId.present) {
      map['resume_workout_id'] = Variable<int>(resumeWorkoutId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledSlotsCompanion(')
          ..write('id: $id, ')
          ..write('dueAt: $dueAt, ')
          ..write('week: $week, ')
          ..write('day: $day, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('attemptOfDay: $attemptOfDay, ')
          ..write('backlogCount: $backlogCount, ')
          ..write('notes: $notes, ')
          ..write('resumeWorkoutId: $resumeWorkoutId')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _scheduledSlotIdMeta =
      const VerificationMeta('scheduledSlotId');
  @override
  late final GeneratedColumn<int> scheduledSlotId = GeneratedColumn<int>(
      'scheduled_slot_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES scheduled_slots (id)'));
  static const VerificationMeta _weekMeta = const VerificationMeta('week');
  @override
  late final GeneratedColumn<int> week = GeneratedColumn<int>(
      'week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
      'day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _columnMeta = const VerificationMeta('column');
  @override
  late final GeneratedColumn<int> column = GeneratedColumn<int>(
      'column', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('incomplete'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
      'finished_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _repeatFlagMeta =
      const VerificationMeta('repeatFlag');
  @override
  late final GeneratedColumn<bool> repeatFlag = GeneratedColumn<bool>(
      'repeat_flag', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("repeat_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        scheduledSlotId,
        week,
        day,
        column,
        status,
        startedAt,
        finishedAt,
        repeatFlag
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(Insertable<Workout> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scheduled_slot_id')) {
      context.handle(
          _scheduledSlotIdMeta,
          scheduledSlotId.isAcceptableOrUnknown(
              data['scheduled_slot_id']!, _scheduledSlotIdMeta));
    } else if (isInserting) {
      context.missing(_scheduledSlotIdMeta);
    }
    if (data.containsKey('week')) {
      context.handle(
          _weekMeta, week.isAcceptableOrUnknown(data['week']!, _weekMeta));
    } else if (isInserting) {
      context.missing(_weekMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('column')) {
      context.handle(_columnMeta,
          column.isAcceptableOrUnknown(data['column']!, _columnMeta));
    } else if (isInserting) {
      context.missing(_columnMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('repeat_flag')) {
      context.handle(
          _repeatFlagMeta,
          repeatFlag.isAcceptableOrUnknown(
              data['repeat_flag']!, _repeatFlagMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      scheduledSlotId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_slot_id'])!,
      week: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week'])!,
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day'])!,
      column: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}column'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      repeatFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}repeat_flag'])!,
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final int id;
  final int scheduledSlotId;
  final int week;
  final int day;
  final int column;
  final String status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final bool repeatFlag;
  const Workout(
      {required this.id,
      required this.scheduledSlotId,
      required this.week,
      required this.day,
      required this.column,
      required this.status,
      this.startedAt,
      this.finishedAt,
      required this.repeatFlag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scheduled_slot_id'] = Variable<int>(scheduledSlotId);
    map['week'] = Variable<int>(week);
    map['day'] = Variable<int>(day);
    map['column'] = Variable<int>(column);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['repeat_flag'] = Variable<bool>(repeatFlag);
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      scheduledSlotId: Value(scheduledSlotId),
      week: Value(week),
      day: Value(day),
      column: Value(column),
      status: Value(status),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      repeatFlag: Value(repeatFlag),
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<int>(json['id']),
      scheduledSlotId: serializer.fromJson<int>(json['scheduledSlotId']),
      week: serializer.fromJson<int>(json['week']),
      day: serializer.fromJson<int>(json['day']),
      column: serializer.fromJson<int>(json['column']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      repeatFlag: serializer.fromJson<bool>(json['repeatFlag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduledSlotId': serializer.toJson<int>(scheduledSlotId),
      'week': serializer.toJson<int>(week),
      'day': serializer.toJson<int>(day),
      'column': serializer.toJson<int>(column),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'repeatFlag': serializer.toJson<bool>(repeatFlag),
    };
  }

  Workout copyWith(
          {int? id,
          int? scheduledSlotId,
          int? week,
          int? day,
          int? column,
          String? status,
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> finishedAt = const Value.absent(),
          bool? repeatFlag}) =>
      Workout(
        id: id ?? this.id,
        scheduledSlotId: scheduledSlotId ?? this.scheduledSlotId,
        week: week ?? this.week,
        day: day ?? this.day,
        column: column ?? this.column,
        status: status ?? this.status,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
        repeatFlag: repeatFlag ?? this.repeatFlag,
      );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      scheduledSlotId: data.scheduledSlotId.present
          ? data.scheduledSlotId.value
          : this.scheduledSlotId,
      week: data.week.present ? data.week.value : this.week,
      day: data.day.present ? data.day.value : this.day,
      column: data.column.present ? data.column.value : this.column,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt:
          data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      repeatFlag:
          data.repeatFlag.present ? data.repeatFlag.value : this.repeatFlag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('scheduledSlotId: $scheduledSlotId, ')
          ..write('week: $week, ')
          ..write('day: $day, ')
          ..write('column: $column, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('repeatFlag: $repeatFlag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scheduledSlotId, week, day, column,
      status, startedAt, finishedAt, repeatFlag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.scheduledSlotId == this.scheduledSlotId &&
          other.week == this.week &&
          other.day == this.day &&
          other.column == this.column &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.repeatFlag == this.repeatFlag);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<int> id;
  final Value<int> scheduledSlotId;
  final Value<int> week;
  final Value<int> day;
  final Value<int> column;
  final Value<String> status;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<bool> repeatFlag;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.scheduledSlotId = const Value.absent(),
    this.week = const Value.absent(),
    this.day = const Value.absent(),
    this.column = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.repeatFlag = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required int scheduledSlotId,
    required int week,
    required int day,
    required int column,
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.repeatFlag = const Value.absent(),
  })  : scheduledSlotId = Value(scheduledSlotId),
        week = Value(week),
        day = Value(day),
        column = Value(column);
  static Insertable<Workout> custom({
    Expression<int>? id,
    Expression<int>? scheduledSlotId,
    Expression<int>? week,
    Expression<int>? day,
    Expression<int>? column,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<bool>? repeatFlag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduledSlotId != null) 'scheduled_slot_id': scheduledSlotId,
      if (week != null) 'week': week,
      if (day != null) 'day': day,
      if (column != null) 'column': column,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (repeatFlag != null) 'repeat_flag': repeatFlag,
    });
  }

  WorkoutsCompanion copyWith(
      {Value<int>? id,
      Value<int>? scheduledSlotId,
      Value<int>? week,
      Value<int>? day,
      Value<int>? column,
      Value<String>? status,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? finishedAt,
      Value<bool>? repeatFlag}) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      scheduledSlotId: scheduledSlotId ?? this.scheduledSlotId,
      week: week ?? this.week,
      day: day ?? this.day,
      column: column ?? this.column,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      repeatFlag: repeatFlag ?? this.repeatFlag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduledSlotId.present) {
      map['scheduled_slot_id'] = Variable<int>(scheduledSlotId.value);
    }
    if (week.present) {
      map['week'] = Variable<int>(week.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (column.present) {
      map['column'] = Variable<int>(column.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (repeatFlag.present) {
      map['repeat_flag'] = Variable<bool>(repeatFlag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('scheduledSlotId: $scheduledSlotId, ')
          ..write('week: $week, ')
          ..write('day: $day, ')
          ..write('column: $column, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('repeatFlag: $repeatFlag')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workouts (id)'));
  static const VerificationMeta _setIndexMeta =
      const VerificationMeta('setIndex');
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
      'set_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _prescribedMeta =
      const VerificationMeta('prescribed');
  @override
  late final GeneratedColumn<int> prescribed = GeneratedColumn<int>(
      'prescribed', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isPlusMeta = const VerificationMeta('isPlus');
  @override
  late final GeneratedColumn<bool> isPlus = GeneratedColumn<bool>(
      'is_plus', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_plus" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _performedMeta =
      const VerificationMeta('performed');
  @override
  late final GeneratedColumn<int> performed = GeneratedColumn<int>(
      'performed', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _restExtendedSecMeta =
      const VerificationMeta('restExtendedSec');
  @override
  late final GeneratedColumn<int> restExtendedSec = GeneratedColumn<int>(
      'rest_extended_sec', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, workoutId, setIndex, prescribed, isPlus, performed, restExtendedSec];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(_setIndexMeta,
          setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta));
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('prescribed')) {
      context.handle(
          _prescribedMeta,
          prescribed.isAcceptableOrUnknown(
              data['prescribed']!, _prescribedMeta));
    } else if (isInserting) {
      context.missing(_prescribedMeta);
    }
    if (data.containsKey('is_plus')) {
      context.handle(_isPlusMeta,
          isPlus.isAcceptableOrUnknown(data['is_plus']!, _isPlusMeta));
    }
    if (data.containsKey('performed')) {
      context.handle(_performedMeta,
          performed.isAcceptableOrUnknown(data['performed']!, _performedMeta));
    }
    if (data.containsKey('rest_extended_sec')) {
      context.handle(
          _restExtendedSecMeta,
          restExtendedSec.isAcceptableOrUnknown(
              data['rest_extended_sec']!, _restExtendedSecMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id'])!,
      setIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}set_index'])!,
      prescribed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prescribed'])!,
      isPlus: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_plus'])!,
      performed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}performed']),
      restExtendedSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rest_extended_sec'])!,
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final int workoutId;
  final int setIndex;
  final int prescribed;
  final bool isPlus;
  final int? performed;
  final int restExtendedSec;
  const WorkoutSet(
      {required this.id,
      required this.workoutId,
      required this.setIndex,
      required this.prescribed,
      required this.isPlus,
      this.performed,
      required this.restExtendedSec});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<int>(workoutId);
    map['set_index'] = Variable<int>(setIndex);
    map['prescribed'] = Variable<int>(prescribed);
    map['is_plus'] = Variable<bool>(isPlus);
    if (!nullToAbsent || performed != null) {
      map['performed'] = Variable<int>(performed);
    }
    map['rest_extended_sec'] = Variable<int>(restExtendedSec);
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      setIndex: Value(setIndex),
      prescribed: Value(prescribed),
      isPlus: Value(isPlus),
      performed: performed == null && nullToAbsent
          ? const Value.absent()
          : Value(performed),
      restExtendedSec: Value(restExtendedSec),
    );
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      prescribed: serializer.fromJson<int>(json['prescribed']),
      isPlus: serializer.fromJson<bool>(json['isPlus']),
      performed: serializer.fromJson<int?>(json['performed']),
      restExtendedSec: serializer.fromJson<int>(json['restExtendedSec']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutId': serializer.toJson<int>(workoutId),
      'setIndex': serializer.toJson<int>(setIndex),
      'prescribed': serializer.toJson<int>(prescribed),
      'isPlus': serializer.toJson<bool>(isPlus),
      'performed': serializer.toJson<int?>(performed),
      'restExtendedSec': serializer.toJson<int>(restExtendedSec),
    };
  }

  WorkoutSet copyWith(
          {int? id,
          int? workoutId,
          int? setIndex,
          int? prescribed,
          bool? isPlus,
          Value<int?> performed = const Value.absent(),
          int? restExtendedSec}) =>
      WorkoutSet(
        id: id ?? this.id,
        workoutId: workoutId ?? this.workoutId,
        setIndex: setIndex ?? this.setIndex,
        prescribed: prescribed ?? this.prescribed,
        isPlus: isPlus ?? this.isPlus,
        performed: performed.present ? performed.value : this.performed,
        restExtendedSec: restExtendedSec ?? this.restExtendedSec,
      );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      prescribed:
          data.prescribed.present ? data.prescribed.value : this.prescribed,
      isPlus: data.isPlus.present ? data.isPlus.value : this.isPlus,
      performed: data.performed.present ? data.performed.value : this.performed,
      restExtendedSec: data.restExtendedSec.present
          ? data.restExtendedSec.value
          : this.restExtendedSec,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('setIndex: $setIndex, ')
          ..write('prescribed: $prescribed, ')
          ..write('isPlus: $isPlus, ')
          ..write('performed: $performed, ')
          ..write('restExtendedSec: $restExtendedSec')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, workoutId, setIndex, prescribed, isPlus, performed, restExtendedSec);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.setIndex == this.setIndex &&
          other.prescribed == this.prescribed &&
          other.isPlus == this.isPlus &&
          other.performed == this.performed &&
          other.restExtendedSec == this.restExtendedSec);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<int> workoutId;
  final Value<int> setIndex;
  final Value<int> prescribed;
  final Value<bool> isPlus;
  final Value<int?> performed;
  final Value<int> restExtendedSec;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.prescribed = const Value.absent(),
    this.isPlus = const Value.absent(),
    this.performed = const Value.absent(),
    this.restExtendedSec = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    required int workoutId,
    required int setIndex,
    required int prescribed,
    this.isPlus = const Value.absent(),
    this.performed = const Value.absent(),
    this.restExtendedSec = const Value.absent(),
  })  : workoutId = Value(workoutId),
        setIndex = Value(setIndex),
        prescribed = Value(prescribed);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<int>? setIndex,
    Expression<int>? prescribed,
    Expression<bool>? isPlus,
    Expression<int>? performed,
    Expression<int>? restExtendedSec,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (setIndex != null) 'set_index': setIndex,
      if (prescribed != null) 'prescribed': prescribed,
      if (isPlus != null) 'is_plus': isPlus,
      if (performed != null) 'performed': performed,
      if (restExtendedSec != null) 'rest_extended_sec': restExtendedSec,
    });
  }

  WorkoutSetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? workoutId,
      Value<int>? setIndex,
      Value<int>? prescribed,
      Value<bool>? isPlus,
      Value<int?>? performed,
      Value<int>? restExtendedSec}) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      setIndex: setIndex ?? this.setIndex,
      prescribed: prescribed ?? this.prescribed,
      isPlus: isPlus ?? this.isPlus,
      performed: performed ?? this.performed,
      restExtendedSec: restExtendedSec ?? this.restExtendedSec,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (prescribed.present) {
      map['prescribed'] = Variable<int>(prescribed.value);
    }
    if (isPlus.present) {
      map['is_plus'] = Variable<bool>(isPlus.value);
    }
    if (performed.present) {
      map['performed'] = Variable<int>(performed.value);
    }
    if (restExtendedSec.present) {
      map['rest_extended_sec'] = Variable<int>(restExtendedSec.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('setIndex: $setIndex, ')
          ..write('prescribed: $prescribed, ')
          ..write('isPlus: $isPlus, ')
          ..write('performed: $performed, ')
          ..write('restExtendedSec: $restExtendedSec')
          ..write(')'))
        .toString();
  }
}

class $TestsTable extends Tests with TableInfo<$TestsTable, Test> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduledSlotIdMeta =
      const VerificationMeta('scheduledSlotId');
  @override
  late final GeneratedColumn<int> scheduledSlotId = GeneratedColumn<int>(
      'scheduled_slot_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES scheduled_slots (id)'));
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<int> result = GeneratedColumn<int>(
      'result', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
      'taken_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _routingMeta =
      const VerificationMeta('routing');
  @override
  late final GeneratedColumn<String> routing = GeneratedColumn<String>(
      'routing', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, kind, scheduledSlotId, result, takenAt, routing];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tests';
  @override
  VerificationContext validateIntegrity(Insertable<Test> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('scheduled_slot_id')) {
      context.handle(
          _scheduledSlotIdMeta,
          scheduledSlotId.isAcceptableOrUnknown(
              data['scheduled_slot_id']!, _scheduledSlotIdMeta));
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    }
    if (data.containsKey('routing')) {
      context.handle(_routingMeta,
          routing.isAcceptableOrUnknown(data['routing']!, _routingMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Test map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Test(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      scheduledSlotId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_slot_id']),
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}result'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at'])!,
      routing: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routing']),
    );
  }

  @override
  $TestsTable createAlias(String alias) {
    return $TestsTable(attachedDatabase, alias);
  }
}

class Test extends DataClass implements Insertable<Test> {
  final int id;
  final String kind;
  final int? scheduledSlotId;
  final int result;
  final DateTime takenAt;
  final String? routing;
  const Test(
      {required this.id,
      required this.kind,
      this.scheduledSlotId,
      required this.result,
      required this.takenAt,
      this.routing});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || scheduledSlotId != null) {
      map['scheduled_slot_id'] = Variable<int>(scheduledSlotId);
    }
    map['result'] = Variable<int>(result);
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || routing != null) {
      map['routing'] = Variable<String>(routing);
    }
    return map;
  }

  TestsCompanion toCompanion(bool nullToAbsent) {
    return TestsCompanion(
      id: Value(id),
      kind: Value(kind),
      scheduledSlotId: scheduledSlotId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledSlotId),
      result: Value(result),
      takenAt: Value(takenAt),
      routing: routing == null && nullToAbsent
          ? const Value.absent()
          : Value(routing),
    );
  }

  factory Test.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Test(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      scheduledSlotId: serializer.fromJson<int?>(json['scheduledSlotId']),
      result: serializer.fromJson<int>(json['result']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      routing: serializer.fromJson<String?>(json['routing']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'scheduledSlotId': serializer.toJson<int?>(scheduledSlotId),
      'result': serializer.toJson<int>(result),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'routing': serializer.toJson<String?>(routing),
    };
  }

  Test copyWith(
          {int? id,
          String? kind,
          Value<int?> scheduledSlotId = const Value.absent(),
          int? result,
          DateTime? takenAt,
          Value<String?> routing = const Value.absent()}) =>
      Test(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        scheduledSlotId: scheduledSlotId.present
            ? scheduledSlotId.value
            : this.scheduledSlotId,
        result: result ?? this.result,
        takenAt: takenAt ?? this.takenAt,
        routing: routing.present ? routing.value : this.routing,
      );
  Test copyWithCompanion(TestsCompanion data) {
    return Test(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      scheduledSlotId: data.scheduledSlotId.present
          ? data.scheduledSlotId.value
          : this.scheduledSlotId,
      result: data.result.present ? data.result.value : this.result,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      routing: data.routing.present ? data.routing.value : this.routing,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Test(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('scheduledSlotId: $scheduledSlotId, ')
          ..write('result: $result, ')
          ..write('takenAt: $takenAt, ')
          ..write('routing: $routing')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, scheduledSlotId, result, takenAt, routing);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Test &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.scheduledSlotId == this.scheduledSlotId &&
          other.result == this.result &&
          other.takenAt == this.takenAt &&
          other.routing == this.routing);
}

class TestsCompanion extends UpdateCompanion<Test> {
  final Value<int> id;
  final Value<String> kind;
  final Value<int?> scheduledSlotId;
  final Value<int> result;
  final Value<DateTime> takenAt;
  final Value<String?> routing;
  const TestsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.scheduledSlotId = const Value.absent(),
    this.result = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.routing = const Value.absent(),
  });
  TestsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    this.scheduledSlotId = const Value.absent(),
    required int result,
    this.takenAt = const Value.absent(),
    this.routing = const Value.absent(),
  })  : kind = Value(kind),
        result = Value(result);
  static Insertable<Test> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? scheduledSlotId,
    Expression<int>? result,
    Expression<DateTime>? takenAt,
    Expression<String>? routing,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (scheduledSlotId != null) 'scheduled_slot_id': scheduledSlotId,
      if (result != null) 'result': result,
      if (takenAt != null) 'taken_at': takenAt,
      if (routing != null) 'routing': routing,
    });
  }

  TestsCompanion copyWith(
      {Value<int>? id,
      Value<String>? kind,
      Value<int?>? scheduledSlotId,
      Value<int>? result,
      Value<DateTime>? takenAt,
      Value<String?>? routing}) {
    return TestsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      scheduledSlotId: scheduledSlotId ?? this.scheduledSlotId,
      result: result ?? this.result,
      takenAt: takenAt ?? this.takenAt,
      routing: routing ?? this.routing,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (scheduledSlotId.present) {
      map['scheduled_slot_id'] = Variable<int>(scheduledSlotId.value);
    }
    if (result.present) {
      map['result'] = Variable<int>(result.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (routing.present) {
      map['routing'] = Variable<String>(routing.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('scheduledSlotId: $scheduledSlotId, ')
          ..write('result: $result, ')
          ..write('takenAt: $takenAt, ')
          ..write('routing: $routing')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ScheduledSlotsTable scheduledSlots = $ScheduledSlotsTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $TestsTable tests = $TestsTable(this);
  late final Index scheduledSlotsStatusDue = Index('scheduled_slots_status_due',
      'CREATE INDEX scheduled_slots_status_due ON scheduled_slots (status, due_at)');
  late final Index workoutSetsWorkout = Index('workout_sets_workout',
      'CREATE INDEX workout_sets_workout ON workout_sets (workout_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        scheduledSlots,
        workouts,
        workoutSets,
        tests,
        scheduledSlotsStatusDue,
        workoutSetsWorkout
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<String> name,
  Value<int?> age,
  Value<double?> weightKg,
  Value<String> sex,
  required String daysOfWeek,
  required String timeOfDay,
  Value<bool> notifEnabled,
  Value<bool> notifDayBefore,
  Value<bool> onboardingComplete,
  Value<int?> currentWeek,
  Value<int?> currentDay,
  Value<int?> currentColumn,
  Value<String?> pendingTest,
  Value<DateTime?> programCompletedAt,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<String> name,
  Value<int?> age,
  Value<double?> weightKg,
  Value<String> sex,
  Value<String> daysOfWeek,
  Value<String> timeOfDay,
  Value<bool> notifEnabled,
  Value<bool> notifDayBefore,
  Value<bool> onboardingComplete,
  Value<int?> currentWeek,
  Value<int?> currentDay,
  Value<int?> currentColumn,
  Value<String?> pendingTest,
  Value<DateTime?> programCompletedAt,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeOfDay => $composableBuilder(
      column: $table.timeOfDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notifEnabled => $composableBuilder(
      column: $table.notifEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notifDayBefore => $composableBuilder(
      column: $table.notifDayBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentWeek => $composableBuilder(
      column: $table.currentWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentDay => $composableBuilder(
      column: $table.currentDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentColumn => $composableBuilder(
      column: $table.currentColumn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pendingTest => $composableBuilder(
      column: $table.pendingTest, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get programCompletedAt => $composableBuilder(
      column: $table.programCompletedAt,
      builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeOfDay => $composableBuilder(
      column: $table.timeOfDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notifEnabled => $composableBuilder(
      column: $table.notifEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notifDayBefore => $composableBuilder(
      column: $table.notifDayBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentWeek => $composableBuilder(
      column: $table.currentWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentDay => $composableBuilder(
      column: $table.currentDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentColumn => $composableBuilder(
      column: $table.currentColumn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pendingTest => $composableBuilder(
      column: $table.pendingTest, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get programCompletedAt => $composableBuilder(
      column: $table.programCompletedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
      column: $table.daysOfWeek, builder: (column) => column);

  GeneratedColumn<String> get timeOfDay =>
      $composableBuilder(column: $table.timeOfDay, builder: (column) => column);

  GeneratedColumn<bool> get notifEnabled => $composableBuilder(
      column: $table.notifEnabled, builder: (column) => column);

  GeneratedColumn<bool> get notifDayBefore => $composableBuilder(
      column: $table.notifDayBefore, builder: (column) => column);

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
      column: $table.onboardingComplete, builder: (column) => column);

  GeneratedColumn<int> get currentWeek => $composableBuilder(
      column: $table.currentWeek, builder: (column) => column);

  GeneratedColumn<int> get currentDay => $composableBuilder(
      column: $table.currentDay, builder: (column) => column);

  GeneratedColumn<int> get currentColumn => $composableBuilder(
      column: $table.currentColumn, builder: (column) => column);

  GeneratedColumn<String> get pendingTest => $composableBuilder(
      column: $table.pendingTest, builder: (column) => column);

  GeneratedColumn<DateTime> get programCompletedAt => $composableBuilder(
      column: $table.programCompletedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<String> sex = const Value.absent(),
            Value<String> daysOfWeek = const Value.absent(),
            Value<String> timeOfDay = const Value.absent(),
            Value<bool> notifEnabled = const Value.absent(),
            Value<bool> notifDayBefore = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
            Value<int?> currentWeek = const Value.absent(),
            Value<int?> currentDay = const Value.absent(),
            Value<int?> currentColumn = const Value.absent(),
            Value<String?> pendingTest = const Value.absent(),
            Value<DateTime?> programCompletedAt = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            createdAt: createdAt,
            name: name,
            age: age,
            weightKg: weightKg,
            sex: sex,
            daysOfWeek: daysOfWeek,
            timeOfDay: timeOfDay,
            notifEnabled: notifEnabled,
            notifDayBefore: notifDayBefore,
            onboardingComplete: onboardingComplete,
            currentWeek: currentWeek,
            currentDay: currentDay,
            currentColumn: currentColumn,
            pendingTest: pendingTest,
            programCompletedAt: programCompletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<String> sex = const Value.absent(),
            required String daysOfWeek,
            required String timeOfDay,
            Value<bool> notifEnabled = const Value.absent(),
            Value<bool> notifDayBefore = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
            Value<int?> currentWeek = const Value.absent(),
            Value<int?> currentDay = const Value.absent(),
            Value<int?> currentColumn = const Value.absent(),
            Value<String?> pendingTest = const Value.absent(),
            Value<DateTime?> programCompletedAt = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            createdAt: createdAt,
            name: name,
            age: age,
            weightKg: weightKg,
            sex: sex,
            daysOfWeek: daysOfWeek,
            timeOfDay: timeOfDay,
            notifEnabled: notifEnabled,
            notifDayBefore: notifDayBefore,
            onboardingComplete: onboardingComplete,
            currentWeek: currentWeek,
            currentDay: currentDay,
            currentColumn: currentColumn,
            pendingTest: pendingTest,
            programCompletedAt: programCompletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UsersTable, User>(table),
                    BaseReferences<_$AppDatabase, $UsersTable, User>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$ScheduledSlotsTableCreateCompanionBuilder = ScheduledSlotsCompanion
    Function({
  Value<int> id,
  required DateTime dueAt,
  Value<int?> week,
  Value<int?> day,
  required String kind,
  Value<String> status,
  Value<int> attemptOfDay,
  Value<int> backlogCount,
  Value<String?> notes,
  Value<int?> resumeWorkoutId,
});
typedef $$ScheduledSlotsTableUpdateCompanionBuilder = ScheduledSlotsCompanion
    Function({
  Value<int> id,
  Value<DateTime> dueAt,
  Value<int?> week,
  Value<int?> day,
  Value<String> kind,
  Value<String> status,
  Value<int> attemptOfDay,
  Value<int> backlogCount,
  Value<String?> notes,
  Value<int?> resumeWorkoutId,
});

final class $$ScheduledSlotsTableReferences
    extends BaseReferences<_$AppDatabase, $ScheduledSlotsTable, ScheduledSlot> {
  $$ScheduledSlotsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutsTable, List<Workout>> _workoutsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.workouts,
          aliasName: 'scheduled_slots__id__workouts__scheduled_slot_id');

  $$WorkoutsTableProcessedTableManager get workoutsRefs {
    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts).filter(
        (f) => f.scheduledSlotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TestsTable, List<Test>> _testsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tests,
          aliasName: 'scheduled_slots__id__tests__scheduled_slot_id');

  $$TestsTableProcessedTableManager get testsRefs {
    final manager = $$TestsTableTableManager($_db, $_db.tests).filter(
        (f) => f.scheduledSlotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_testsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ScheduledSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledSlotsTable> {
  $$ScheduledSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get week => $composableBuilder(
      column: $table.week, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptOfDay => $composableBuilder(
      column: $table.attemptOfDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get backlogCount => $composableBuilder(
      column: $table.backlogCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get resumeWorkoutId => $composableBuilder(
      column: $table.resumeWorkoutId,
      builder: (column) => ColumnFilters(column));

  Expression<bool> workoutsRefs(
      Expression<bool> Function($$WorkoutsTableFilterComposer f) f) {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.scheduledSlotId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> testsRefs(
      Expression<bool> Function($$TestsTableFilterComposer f) f) {
    final $$TestsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.scheduledSlotId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableFilterComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ScheduledSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledSlotsTable> {
  $$ScheduledSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get week => $composableBuilder(
      column: $table.week, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptOfDay => $composableBuilder(
      column: $table.attemptOfDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get backlogCount => $composableBuilder(
      column: $table.backlogCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get resumeWorkoutId => $composableBuilder(
      column: $table.resumeWorkoutId,
      builder: (column) => ColumnOrderings(column));
}

class $$ScheduledSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledSlotsTable> {
  $$ScheduledSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get week =>
      $composableBuilder(column: $table.week, builder: (column) => column);

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptOfDay => $composableBuilder(
      column: $table.attemptOfDay, builder: (column) => column);

  GeneratedColumn<int> get backlogCount => $composableBuilder(
      column: $table.backlogCount, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get resumeWorkoutId => $composableBuilder(
      column: $table.resumeWorkoutId, builder: (column) => column);

  Expression<T> workoutsRefs<T extends Object>(
      Expression<T> Function($$WorkoutsTableAnnotationComposer a) f) {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.scheduledSlotId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> testsRefs<T extends Object>(
      Expression<T> Function($$TestsTableAnnotationComposer a) f) {
    final $$TestsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tests,
        getReferencedColumn: (t) => t.scheduledSlotId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TestsTableAnnotationComposer(
              $db: $db,
              $table: $db.tests,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ScheduledSlotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScheduledSlotsTable,
    ScheduledSlot,
    $$ScheduledSlotsTableFilterComposer,
    $$ScheduledSlotsTableOrderingComposer,
    $$ScheduledSlotsTableAnnotationComposer,
    $$ScheduledSlotsTableCreateCompanionBuilder,
    $$ScheduledSlotsTableUpdateCompanionBuilder,
    (ScheduledSlot, $$ScheduledSlotsTableReferences),
    ScheduledSlot,
    PrefetchHooks Function({bool workoutsRefs, bool testsRefs})> {
  $$ScheduledSlotsTableTableManager(
      _$AppDatabase db, $ScheduledSlotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduledSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> dueAt = const Value.absent(),
            Value<int?> week = const Value.absent(),
            Value<int?> day = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attemptOfDay = const Value.absent(),
            Value<int> backlogCount = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> resumeWorkoutId = const Value.absent(),
          }) =>
              ScheduledSlotsCompanion(
            id: id,
            dueAt: dueAt,
            week: week,
            day: day,
            kind: kind,
            status: status,
            attemptOfDay: attemptOfDay,
            backlogCount: backlogCount,
            notes: notes,
            resumeWorkoutId: resumeWorkoutId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime dueAt,
            Value<int?> week = const Value.absent(),
            Value<int?> day = const Value.absent(),
            required String kind,
            Value<String> status = const Value.absent(),
            Value<int> attemptOfDay = const Value.absent(),
            Value<int> backlogCount = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> resumeWorkoutId = const Value.absent(),
          }) =>
              ScheduledSlotsCompanion.insert(
            id: id,
            dueAt: dueAt,
            week: week,
            day: day,
            kind: kind,
            status: status,
            attemptOfDay: attemptOfDay,
            backlogCount: backlogCount,
            notes: notes,
            resumeWorkoutId: resumeWorkoutId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ScheduledSlotsTable, ScheduledSlot>(table),
                    $$ScheduledSlotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workoutsRefs = false, testsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutsRefs) db.workouts,
                if (testsRefs) db.tests
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutsRefs)
                    await $_getPrefetchedData<ScheduledSlot,
                            $ScheduledSlotsTable, Workout>(
                        currentTable: table,
                        referencedTable: $$ScheduledSlotsTableReferences
                            ._workoutsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduledSlotsTableReferences(db, table, p0)
                                .workoutsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.scheduledSlotId == item.id),
                        typedResults: items),
                  if (testsRefs)
                    await $_getPrefetchedData<ScheduledSlot,
                            $ScheduledSlotsTable, Test>(
                        currentTable: table,
                        referencedTable:
                            $$ScheduledSlotsTableReferences._testsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduledSlotsTableReferences(db, table, p0)
                                .testsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.scheduledSlotId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ScheduledSlotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScheduledSlotsTable,
    ScheduledSlot,
    $$ScheduledSlotsTableFilterComposer,
    $$ScheduledSlotsTableOrderingComposer,
    $$ScheduledSlotsTableAnnotationComposer,
    $$ScheduledSlotsTableCreateCompanionBuilder,
    $$ScheduledSlotsTableUpdateCompanionBuilder,
    (ScheduledSlot, $$ScheduledSlotsTableReferences),
    ScheduledSlot,
    PrefetchHooks Function({bool workoutsRefs, bool testsRefs})>;
typedef $$WorkoutsTableCreateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  required int scheduledSlotId,
  required int week,
  required int day,
  required int column,
  Value<String> status,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<bool> repeatFlag,
});
typedef $$WorkoutsTableUpdateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  Value<int> scheduledSlotId,
  Value<int> week,
  Value<int> day,
  Value<int> column,
  Value<String> status,
  Value<DateTime?> startedAt,
  Value<DateTime?> finishedAt,
  Value<bool> repeatFlag,
});

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduledSlotsTable _scheduledSlotIdTable(_$AppDatabase db) =>
      db.scheduledSlots
          .createAlias('workouts__scheduled_slot_id__scheduled_slots__id');

  $$ScheduledSlotsTableProcessedTableManager get scheduledSlotId {
    final $_column = $_itemColumn<int>('scheduled_slot_id')!;

    final manager = $$ScheduledSlotsTableTableManager($_db, $_db.scheduledSlots)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduledSlotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
      _workoutSetsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workoutSets,
              aliasName: 'workouts__id__workout_sets__workout_id');

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets)
        .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get week => $composableBuilder(
      column: $table.week, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get column => $composableBuilder(
      column: $table.column, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get repeatFlag => $composableBuilder(
      column: $table.repeatFlag, builder: (column) => ColumnFilters(column));

  $$ScheduledSlotsTableFilterComposer get scheduledSlotId {
    final $$ScheduledSlotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduledSlotId,
        referencedTable: $db.scheduledSlots,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduledSlotsTableFilterComposer(
              $db: $db,
              $table: $db.scheduledSlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> workoutSetsRefs(
      Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableFilterComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get week => $composableBuilder(
      column: $table.week, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get column => $composableBuilder(
      column: $table.column, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get repeatFlag => $composableBuilder(
      column: $table.repeatFlag, builder: (column) => ColumnOrderings(column));

  $$ScheduledSlotsTableOrderingComposer get scheduledSlotId {
    final $$ScheduledSlotsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduledSlotId,
        referencedTable: $db.scheduledSlots,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduledSlotsTableOrderingComposer(
              $db: $db,
              $table: $db.scheduledSlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get week =>
      $composableBuilder(column: $table.week, builder: (column) => column);

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get column =>
      $composableBuilder(column: $table.column, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
      column: $table.finishedAt, builder: (column) => column);

  GeneratedColumn<bool> get repeatFlag => $composableBuilder(
      column: $table.repeatFlag, builder: (column) => column);

  $$ScheduledSlotsTableAnnotationComposer get scheduledSlotId {
    final $$ScheduledSlotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduledSlotId,
        referencedTable: $db.scheduledSlots,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduledSlotsTableAnnotationComposer(
              $db: $db,
              $table: $db.scheduledSlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> workoutSetsRefs<T extends Object>(
      Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableAnnotationComposer,
    $$WorkoutsTableCreateCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder,
    (Workout, $$WorkoutsTableReferences),
    Workout,
    PrefetchHooks Function({bool scheduledSlotId, bool workoutSetsRefs})> {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> scheduledSlotId = const Value.absent(),
            Value<int> week = const Value.absent(),
            Value<int> day = const Value.absent(),
            Value<int> column = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<bool> repeatFlag = const Value.absent(),
          }) =>
              WorkoutsCompanion(
            id: id,
            scheduledSlotId: scheduledSlotId,
            week: week,
            day: day,
            column: column,
            status: status,
            startedAt: startedAt,
            finishedAt: finishedAt,
            repeatFlag: repeatFlag,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int scheduledSlotId,
            required int week,
            required int day,
            required int column,
            Value<String> status = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<bool> repeatFlag = const Value.absent(),
          }) =>
              WorkoutsCompanion.insert(
            id: id,
            scheduledSlotId: scheduledSlotId,
            week: week,
            day: day,
            column: column,
            status: status,
            startedAt: startedAt,
            finishedAt: finishedAt,
            repeatFlag: repeatFlag,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$WorkoutsTable, Workout>(table),
                    $$WorkoutsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {scheduledSlotId = false, workoutSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutSetsRefs) db.workoutSets],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (scheduledSlotId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.scheduledSlotId,
                    referencedTable:
                        $$WorkoutsTableReferences._scheduledSlotIdTable(db),
                    referencedColumn:
                        $$WorkoutsTableReferences._scheduledSlotIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutSetsRefs)
                    await $_getPrefetchedData<Workout, $WorkoutsTable,
                            WorkoutSet>(
                        currentTable: table,
                        referencedTable:
                            $$WorkoutsTableReferences._workoutSetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutsTableReferences(db, table, p0)
                                .workoutSetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkoutsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableAnnotationComposer,
    $$WorkoutsTableCreateCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder,
    (Workout, $$WorkoutsTableReferences),
    Workout,
    PrefetchHooks Function({bool scheduledSlotId, bool workoutSetsRefs})>;
typedef $$WorkoutSetsTableCreateCompanionBuilder = WorkoutSetsCompanion
    Function({
  Value<int> id,
  required int workoutId,
  required int setIndex,
  required int prescribed,
  Value<bool> isPlus,
  Value<int?> performed,
  Value<int> restExtendedSec,
});
typedef $$WorkoutSetsTableUpdateCompanionBuilder = WorkoutSetsCompanion
    Function({
  Value<int> id,
  Value<int> workoutId,
  Value<int> setIndex,
  Value<int> prescribed,
  Value<bool> isPlus,
  Value<int?> performed,
  Value<int> restExtendedSec,
});

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('workout_sets__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get setIndex => $composableBuilder(
      column: $table.setIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prescribed => $composableBuilder(
      column: $table.prescribed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPlus => $composableBuilder(
      column: $table.isPlus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get performed => $composableBuilder(
      column: $table.performed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get restExtendedSec => $composableBuilder(
      column: $table.restExtendedSec,
      builder: (column) => ColumnFilters(column));

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get setIndex => $composableBuilder(
      column: $table.setIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prescribed => $composableBuilder(
      column: $table.prescribed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPlus => $composableBuilder(
      column: $table.isPlus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get performed => $composableBuilder(
      column: $table.performed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restExtendedSec => $composableBuilder(
      column: $table.restExtendedSec,
      builder: (column) => ColumnOrderings(column));

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<int> get prescribed => $composableBuilder(
      column: $table.prescribed, builder: (column) => column);

  GeneratedColumn<bool> get isPlus =>
      $composableBuilder(column: $table.isPlus, builder: (column) => column);

  GeneratedColumn<int> get performed =>
      $composableBuilder(column: $table.performed, builder: (column) => column);

  GeneratedColumn<int> get restExtendedSec => $composableBuilder(
      column: $table.restExtendedSec, builder: (column) => column);

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSet,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSet, $$WorkoutSetsTableReferences),
    WorkoutSet,
    PrefetchHooks Function({bool workoutId})> {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
            Value<int> setIndex = const Value.absent(),
            Value<int> prescribed = const Value.absent(),
            Value<bool> isPlus = const Value.absent(),
            Value<int?> performed = const Value.absent(),
            Value<int> restExtendedSec = const Value.absent(),
          }) =>
              WorkoutSetsCompanion(
            id: id,
            workoutId: workoutId,
            setIndex: setIndex,
            prescribed: prescribed,
            isPlus: isPlus,
            performed: performed,
            restExtendedSec: restExtendedSec,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workoutId,
            required int setIndex,
            required int prescribed,
            Value<bool> isPlus = const Value.absent(),
            Value<int?> performed = const Value.absent(),
            Value<int> restExtendedSec = const Value.absent(),
          }) =>
              WorkoutSetsCompanion.insert(
            id: id,
            workoutId: workoutId,
            setIndex: setIndex,
            prescribed: prescribed,
            isPlus: isPlus,
            performed: performed,
            restExtendedSec: restExtendedSec,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$WorkoutSetsTable, WorkoutSet>(table),
                    $$WorkoutSetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable:
                        $$WorkoutSetsTableReferences._workoutIdTable(db),
                    referencedColumn:
                        $$WorkoutSetsTableReferences._workoutIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WorkoutSetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSet,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSet, $$WorkoutSetsTableReferences),
    WorkoutSet,
    PrefetchHooks Function({bool workoutId})>;
typedef $$TestsTableCreateCompanionBuilder = TestsCompanion Function({
  Value<int> id,
  required String kind,
  Value<int?> scheduledSlotId,
  required int result,
  Value<DateTime> takenAt,
  Value<String?> routing,
});
typedef $$TestsTableUpdateCompanionBuilder = TestsCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<int?> scheduledSlotId,
  Value<int> result,
  Value<DateTime> takenAt,
  Value<String?> routing,
});

final class $$TestsTableReferences
    extends BaseReferences<_$AppDatabase, $TestsTable, Test> {
  $$TestsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduledSlotsTable _scheduledSlotIdTable(_$AppDatabase db) =>
      db.scheduledSlots
          .createAlias('tests__scheduled_slot_id__scheduled_slots__id');

  $$ScheduledSlotsTableProcessedTableManager? get scheduledSlotId {
    final $_column = $_itemColumn<int>('scheduled_slot_id');
    if ($_column == null) return null;
    final manager = $$ScheduledSlotsTableTableManager($_db, $_db.scheduledSlots)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduledSlotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TestsTableFilterComposer extends Composer<_$AppDatabase, $TestsTable> {
  $$TestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routing => $composableBuilder(
      column: $table.routing, builder: (column) => ColumnFilters(column));

  $$ScheduledSlotsTableFilterComposer get scheduledSlotId {
    final $$ScheduledSlotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduledSlotId,
        referencedTable: $db.scheduledSlots,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduledSlotsTableFilterComposer(
              $db: $db,
              $table: $db.scheduledSlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TestsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestsTable> {
  $$TestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routing => $composableBuilder(
      column: $table.routing, builder: (column) => ColumnOrderings(column));

  $$ScheduledSlotsTableOrderingComposer get scheduledSlotId {
    final $$ScheduledSlotsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduledSlotId,
        referencedTable: $db.scheduledSlots,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduledSlotsTableOrderingComposer(
              $db: $db,
              $table: $db.scheduledSlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestsTable> {
  $$TestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get routing =>
      $composableBuilder(column: $table.routing, builder: (column) => column);

  $$ScheduledSlotsTableAnnotationComposer get scheduledSlotId {
    final $$ScheduledSlotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduledSlotId,
        referencedTable: $db.scheduledSlots,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduledSlotsTableAnnotationComposer(
              $db: $db,
              $table: $db.scheduledSlots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TestsTable,
    Test,
    $$TestsTableFilterComposer,
    $$TestsTableOrderingComposer,
    $$TestsTableAnnotationComposer,
    $$TestsTableCreateCompanionBuilder,
    $$TestsTableUpdateCompanionBuilder,
    (Test, $$TestsTableReferences),
    Test,
    PrefetchHooks Function({bool scheduledSlotId})> {
  $$TestsTableTableManager(_$AppDatabase db, $TestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int?> scheduledSlotId = const Value.absent(),
            Value<int> result = const Value.absent(),
            Value<DateTime> takenAt = const Value.absent(),
            Value<String?> routing = const Value.absent(),
          }) =>
              TestsCompanion(
            id: id,
            kind: kind,
            scheduledSlotId: scheduledSlotId,
            result: result,
            takenAt: takenAt,
            routing: routing,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String kind,
            Value<int?> scheduledSlotId = const Value.absent(),
            required int result,
            Value<DateTime> takenAt = const Value.absent(),
            Value<String?> routing = const Value.absent(),
          }) =>
              TestsCompanion.insert(
            id: id,
            kind: kind,
            scheduledSlotId: scheduledSlotId,
            result: result,
            takenAt: takenAt,
            routing: routing,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TestsTable, Test>(table),
                    $$TestsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({scheduledSlotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (scheduledSlotId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.scheduledSlotId,
                    referencedTable:
                        $$TestsTableReferences._scheduledSlotIdTable(db),
                    referencedColumn:
                        $$TestsTableReferences._scheduledSlotIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TestsTable,
    Test,
    $$TestsTableFilterComposer,
    $$TestsTableOrderingComposer,
    $$TestsTableAnnotationComposer,
    $$TestsTableCreateCompanionBuilder,
    $$TestsTableUpdateCompanionBuilder,
    (Test, $$TestsTableReferences),
    Test,
    PrefetchHooks Function({bool scheduledSlotId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ScheduledSlotsTableTableManager get scheduledSlots =>
      $$ScheduledSlotsTableTableManager(_db, _db.scheduledSlots);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$TestsTableTableManager get tests =>
      $$TestsTableTableManager(_db, _db.tests);
}
