import 'package:equatable/equatable.dart';

enum WorkoutStatus { idle, active, resting, complete, abandoned }

class WorkoutState extends Equatable {
  final int week;
  final int day; // 0-based
  final int column;
  final int currentSetIndex;
  final int restSecondsRemaining;

  /// Prescribed rest for this day plus any extensions on the current rest.
  final int restDurationSeconds;

  /// Wall-clock instant at which the current rest ends (null when not resting).
  final DateTime? restEndsAt;
  final WorkoutStatus status;
  final List<SetState> sets;

  /// Database id when this state continues a previously saved workout.
  final int? workoutId;
  final DateTime? startedAt;

  const WorkoutState({
    required this.week,
    required this.day,
    required this.column,
    this.currentSetIndex = 0,
    this.restSecondsRemaining = 0,
    this.restDurationSeconds = 0,
    this.restEndsAt,
    this.status = WorkoutStatus.idle,
    this.sets = const [],
    this.workoutId,
    this.startedAt,
  });

  WorkoutState copyWith({
    int? week,
    int? day,
    int? column,
    int? currentSetIndex,
    int? restSecondsRemaining,
    int? restDurationSeconds,
    DateTime? restEndsAt,
    bool clearRestEndsAt = false,
    WorkoutStatus? status,
    List<SetState>? sets,
    int? workoutId,
    DateTime? startedAt,
  }) {
    return WorkoutState(
      week: week ?? this.week,
      day: day ?? this.day,
      column: column ?? this.column,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      restEndsAt: clearRestEndsAt ? null : (restEndsAt ?? this.restEndsAt),
      status: status ?? this.status,
      sets: sets ?? this.sets,
      workoutId: workoutId ?? this.workoutId,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  int get totalSets => sets.length;
  bool get isLastSet => currentSetIndex >= totalSets - 1;
  SetState? get currentSet => currentSetIndex < sets.length ? sets[currentSetIndex] : null;
  SetState? get nextSet => currentSetIndex + 1 < sets.length ? sets[currentSetIndex + 1] : null;
  int get completedSets => sets.where((s) => s.performed != null).length;
  int get totalReps => sets.fold<int>(0, (sum, s) => sum + (s.performed ?? 0));
  bool get hasAnyReps => sets.any((s) => (s.performed ?? 0) > 0);

  Map<String, dynamic> toJson() => {
        'week': week,
        'day': day,
        'column': column,
        'currentSetIndex': currentSetIndex,
        'restSecondsRemaining': restSecondsRemaining,
        'restDurationSeconds': restDurationSeconds,
        'restEndsAt': restEndsAt?.toIso8601String(),
        'status': status.name,
        'sets': sets.map((s) => s.toJson()).toList(),
        'workoutId': workoutId,
        'startedAt': startedAt?.toIso8601String(),
      };

  factory WorkoutState.fromJson(Map<String, dynamic> json) {
    return WorkoutState(
      week: json['week'] as int,
      day: json['day'] as int,
      column: json['column'] as int,
      currentSetIndex: json['currentSetIndex'] as int? ?? 0,
      restSecondsRemaining: json['restSecondsRemaining'] as int? ?? 0,
      restDurationSeconds: json['restDurationSeconds'] as int? ?? 0,
      restEndsAt: json['restEndsAt'] == null ? null : DateTime.parse(json['restEndsAt'] as String),
      status: WorkoutStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => WorkoutStatus.active,
      ),
      sets: (json['sets'] as List? ?? const [])
          .map((s) => SetState.fromJson(s as Map<String, dynamic>))
          .toList(),
      workoutId: json['workoutId'] as int?,
      startedAt: json['startedAt'] == null ? null : DateTime.parse(json['startedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        week,
        day,
        column,
        currentSetIndex,
        restSecondsRemaining,
        restDurationSeconds,
        restEndsAt,
        status,
        sets,
        workoutId,
        startedAt,
      ];
}

class SetState extends Equatable {
  final int index;
  final int prescribed;
  final bool isPlus;
  final int? performed;
  final int restExtendedSec;

  /// Row id in `workout_sets` when this set has already been persisted.
  final int? dbId;

  const SetState({
    required this.index,
    required this.prescribed,
    required this.isPlus,
    this.performed,
    this.restExtendedSec = 0,
    this.dbId,
  });

  SetState copyWith({
    int? index,
    int? prescribed,
    bool? isPlus,
    int? performed,
    int? restExtendedSec,
    int? dbId,
  }) {
    return SetState(
      index: index ?? this.index,
      prescribed: prescribed ?? this.prescribed,
      isPlus: isPlus ?? this.isPlus,
      performed: performed ?? this.performed,
      restExtendedSec: restExtendedSec ?? this.restExtendedSec,
      dbId: dbId ?? this.dbId,
    );
  }

  String get label => isPlus ? '$prescribed+' : '$prescribed';

  Map<String, dynamic> toJson() => {
        'index': index,
        'prescribed': prescribed,
        'isPlus': isPlus,
        'performed': performed,
        'restExtendedSec': restExtendedSec,
        'dbId': dbId,
      };

  factory SetState.fromJson(Map<String, dynamic> json) => SetState(
        index: json['index'] as int,
        prescribed: json['prescribed'] as int,
        isPlus: json['isPlus'] as bool? ?? false,
        performed: json['performed'] as int?,
        restExtendedSec: json['restExtendedSec'] as int? ?? 0,
        dbId: json['dbId'] as int?,
      );

  @override
  List<Object?> get props => [index, prescribed, isPlus, performed, restExtendedSec, dbId];
}
