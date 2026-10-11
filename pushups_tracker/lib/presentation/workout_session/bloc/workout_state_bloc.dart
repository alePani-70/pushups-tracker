part of 'workout_bloc.dart';

enum WorkoutBlocStatus { initial, active, resting, complete, saving, saved, abandoned, error }

class WorkoutBlocState extends Equatable {
  final WorkoutBlocStatus status;
  final WorkoutState? workout;

  /// Scheduled slot this session belongs to (null for ad-hoc workouts).
  final int? slotId;
  final String? error;

  /// Routing message produced after a successful save (e.g. what comes next).
  final String? message;

  const WorkoutBlocState({
    this.status = WorkoutBlocStatus.initial,
    this.workout,
    this.slotId,
    this.error,
    this.message,
  });

  WorkoutBlocState copyWith({
    WorkoutBlocStatus? status,
    WorkoutState? workout,
    int? slotId,
    String? error,
    String? message,
  }) {
    return WorkoutBlocState(
      status: status ?? this.status,
      workout: workout ?? this.workout,
      slotId: slotId ?? this.slotId,
      // A new status clears a stale error unless a new one is supplied.
      error: error ?? (status != null && status != this.status ? null : this.error),
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, workout, slotId, error, message];
}
