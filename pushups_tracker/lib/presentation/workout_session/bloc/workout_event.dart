part of 'workout_bloc.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();
  @override
  List<Object?> get props => [];
}

/// Start a fresh workout, or resume a saved incomplete one when
/// [resumeWorkoutId] is given (week/day/column are then read from the DB).
class WorkoutStarted extends WorkoutEvent {
  final int week;
  final int day;
  final int column;
  final int? slotId;
  final int? resumeWorkoutId;

  const WorkoutStarted({
    required this.week,
    required this.day,
    required this.column,
    this.slotId,
    this.resumeWorkoutId,
  });

  @override
  List<Object?> get props => [week, day, column, slotId, resumeWorkoutId];
}

/// Restore an interrupted session from a [SessionStore] snapshot.
class WorkoutRestored extends WorkoutEvent {
  final Map<String, dynamic> snapshot;
  const WorkoutRestored(this.snapshot);

  @override
  List<Object?> get props => [snapshot];
}

class RepAdded extends WorkoutEvent {
  const RepAdded();
}

class RepRemoved extends WorkoutEvent {
  const RepRemoved();
}

class SetCompleted extends WorkoutEvent {
  const SetCompleted();
}

class RestTicked extends WorkoutEvent {
  const RestTicked();
}

class RestExtended extends WorkoutEvent {
  final int seconds;
  const RestExtended(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class RestSkipped extends WorkoutEvent {
  const RestSkipped();
}

/// Persist the workout (complete or incomplete) and update the program state.
class WorkoutSaved extends WorkoutEvent {
  const WorkoutSaved();
}

/// Throw the in-memory session away (clears the crash-recovery snapshot).
class WorkoutDiscarded extends WorkoutEvent {
  const WorkoutDiscarded();
}
