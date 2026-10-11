import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/database.dart';
import '../../../data/program_repository.dart';
import '../../../domain/models/workout_state.dart';
import '../../../services/app_settings.dart';
import '../../../services/notification_service.dart';
import '../../../services/progression_service.dart';
import '../../../services/session_store.dart';

part 'workout_event.dart';
part 'workout_state_bloc.dart';

/// State machine: initial → active ⇄ resting → … → complete → saving → saved.
///
/// The rest timer is wall-clock based: `restEndsAt` is fixed when a set ends
/// and the displayed countdown is derived from it on every tick, so time spent
/// with the app in the background is accounted for. A local notification is
/// scheduled for the end of each rest so the cue works with the screen off.
/// Every meaningful state change is snapshotted through [SessionStore] for
/// crash recovery.
class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutBlocState> {
  final AppDatabase _db;
  final ProgramRepository _program;
  final ProgressionService _progression;
  final SessionStore _sessions;
  final NotificationService _notifications;
  final AppSettings _settings;
  Timer? _restTimer;

  WorkoutBloc(
    this._db,
    this._program,
    this._progression,
    this._sessions,
    this._notifications,
    this._settings,
  ) : super(const WorkoutBlocState()) {
    on<WorkoutStarted>(_onStarted);
    on<WorkoutRestored>(_onRestored);
    on<RepAdded>(_onRepAdded);
    on<RepRemoved>(_onRepRemoved);
    on<SetCompleted>(_onSetCompleted);
    on<RestTicked>(_onRestTicked);
    on<RestExtended>(_onRestExtended);
    on<RestSkipped>(_onRestSkipped);
    on<WorkoutSaved>(_onSaved);
    on<WorkoutDiscarded>(_onDiscarded);
  }

  // ------------------------------------------------------------ snapshots

  @override
  void onChange(Change<WorkoutBlocState> change) {
    super.onChange(change);
    if (_shouldSnapshot(change.currentState, change.nextState)) {
      final next = change.nextState;
      unawaited(_sessions.save({
        'workout': next.workout!.toJson(),
        'slotId': next.slotId,
        'savedAt': DateTime.now().toIso8601String(),
      }));
    }
  }

  bool _shouldSnapshot(WorkoutBlocState prev, WorkoutBlocState next) {
    final ws = next.workout;
    if (ws == null) return false;
    switch (next.status) {
      case WorkoutBlocStatus.active:
      case WorkoutBlocStatus.resting:
      case WorkoutBlocStatus.complete:
        break;
      default:
        return false;
    }
    // Skip writes where only the countdown number changed; restEndsAt already
    // captures everything needed to restore the rest.
    final prevWs = prev.workout;
    if (prevWs != null &&
        prev.status == next.status &&
        prevWs.copyWith(restSecondsRemaining: ws.restSecondsRemaining) == ws) {
      return false;
    }
    return true;
  }

  // ------------------------------------------------------------ helpers

  int _restFor(int week, int day) => _program.getDay(week, day)?['restSeconds'] as int? ?? 60;

  int _remaining(DateTime? endsAt) {
    if (endsAt == null) return 0;
    final ms = endsAt.difference(DateTime.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  WorkoutState _advanceToNextSet(WorkoutState ws) => ws.copyWith(
        status: WorkoutStatus.active,
        currentSetIndex: ws.currentSetIndex + 1,
        restSecondsRemaining: 0,
        clearRestEndsAt: true,
      );

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) => add(const RestTicked()));
  }

  /// Schedules the screen-off cue one second after the rest ends. If the app is
  /// in the foreground the tick at 0 cancels it first, so it only shows when
  /// the in-app timer could not.
  void _scheduleRestAlert(WorkoutState ws) {
    final endsAt = ws.restEndsAt;
    if (endsAt == null || !_settings.restEndAlert) return;
    final next = ws.nextSet;
    final body = next == null ? 'Back to it!' : 'Next: Set ${next.index + 1} — ${next.label} reps';
    unawaited(_notifications.scheduleRestEnd(at: endsAt.add(const Duration(seconds: 1)), body: body));
  }

  void _cancelRestAlert() => unawaited(_notifications.cancelRestEnd());

  // ------------------------------------------------------------ start / restore

  Future<void> _onStarted(WorkoutStarted event, Emitter<WorkoutBlocState> emit) async {
    if (event.resumeWorkoutId != null) {
      await _resume(event, emit);
      return;
    }

    final dayData = _program.getDay(event.week, event.day);
    if (dayData == null) {
      emit(state.copyWith(status: WorkoutBlocStatus.error, error: 'Invalid workout day'));
      return;
    }

    final setsData = (dayData['sets'] as List).cast<List>();
    final isPlusList = (dayData['isPlus'] as List).cast<bool>();
    final colIndex = (event.column - 1).clamp(0, 2);

    final sets = <SetState>[
      for (var i = 0; i < setsData.length; i++)
        SetState(
          index: i,
          prescribed: setsData[i][colIndex] as int,
          isPlus: i < isPlusList.length && isPlusList[i],
        ),
    ];

    emit(state.copyWith(
      workout: WorkoutState(
        week: event.week,
        day: event.day,
        column: event.column,
        status: WorkoutStatus.active,
        sets: sets,
        restDurationSeconds: _restFor(event.week, event.day),
        startedAt: DateTime.now(),
      ),
      status: WorkoutBlocStatus.active,
      slotId: event.slotId,
    ));
  }

  Future<void> _resume(WorkoutStarted event, Emitter<WorkoutBlocState> emit) async {
    final workout = await _db.getWorkout(event.resumeWorkoutId!);
    if (workout == null) {
      emit(state.copyWith(status: WorkoutBlocStatus.error, error: 'Workout to resume was not found'));
      return;
    }
    final rows = await _db.getSetsForWorkout(workout.id);
    final sets = rows
        .map((r) => SetState(
              index: r.setIndex,
              prescribed: r.prescribed,
              isPlus: r.isPlus,
              performed: r.performed,
              restExtendedSec: r.restExtendedSec,
              dbId: r.id,
            ))
        .toList();
    var idx = sets.indexWhere((s) => s.performed == null);
    if (idx < 0) idx = sets.isEmpty ? 0 : sets.length - 1;

    emit(state.copyWith(
      workout: WorkoutState(
        week: workout.week,
        day: workout.day,
        column: workout.column,
        status: WorkoutStatus.active,
        sets: sets,
        currentSetIndex: idx,
        restDurationSeconds: _restFor(workout.week, workout.day),
        workoutId: workout.id,
        startedAt: workout.startedAt ?? DateTime.now(),
      ),
      status: WorkoutBlocStatus.active,
      slotId: event.slotId,
    ));
  }

  void _onRestored(WorkoutRestored event, Emitter<WorkoutBlocState> emit) {
    final WorkoutState ws;
    try {
      ws = WorkoutState.fromJson(Map<String, dynamic>.from(event.snapshot['workout'] as Map));
    } catch (_) {
      unawaited(_sessions.clear());
      emit(state.copyWith(status: WorkoutBlocStatus.error, error: 'Saved session could not be restored'));
      return;
    }
    final slotId = event.snapshot['slotId'] as int?;

    switch (ws.status) {
      case WorkoutStatus.resting:
        final remaining = _remaining(ws.restEndsAt);
        if (remaining <= 0) {
          _cancelRestAlert();
          emit(state.copyWith(
            workout: _advanceToNextSet(ws),
            status: WorkoutBlocStatus.active,
            slotId: slotId,
          ));
        } else {
          emit(state.copyWith(
            workout: ws.copyWith(restSecondsRemaining: remaining),
            status: WorkoutBlocStatus.resting,
            slotId: slotId,
          ));
          _startRestTimer();
        }
        break;
      case WorkoutStatus.complete:
        emit(state.copyWith(workout: ws, status: WorkoutBlocStatus.complete, slotId: slotId));
        break;
      default:
        emit(state.copyWith(
          workout: ws.copyWith(status: WorkoutStatus.active, clearRestEndsAt: true),
          status: WorkoutBlocStatus.active,
          slotId: slotId,
        ));
    }
  }

  // ------------------------------------------------------------ reps

  void _onRepAdded(RepAdded event, Emitter<WorkoutBlocState> emit) {
    final ws = state.workout;
    if (ws == null || ws.status != WorkoutStatus.active) return;
    final current = ws.currentSet;
    if (current == null) return;

    final updated = [...ws.sets];
    updated[ws.currentSetIndex] = current.copyWith(performed: (current.performed ?? 0) + 1);
    emit(state.copyWith(workout: ws.copyWith(sets: updated)));
  }

  void _onRepRemoved(RepRemoved event, Emitter<WorkoutBlocState> emit) {
    final ws = state.workout;
    if (ws == null || ws.status != WorkoutStatus.active) return;
    final current = ws.currentSet;
    if (current == null || (current.performed ?? 0) <= 0) return;

    final updated = [...ws.sets];
    updated[ws.currentSetIndex] = current.copyWith(performed: current.performed! - 1);
    emit(state.copyWith(workout: ws.copyWith(sets: updated)));
  }

  // ------------------------------------------------------------ sets & rest

  void _onSetCompleted(SetCompleted event, Emitter<WorkoutBlocState> emit) {
    final ws = state.workout;
    if (ws == null || ws.status != WorkoutStatus.active) return;
    final current = ws.currentSet;
    if (current == null) return;

    // A set that was ended is "attempted": store 0 rather than null.
    final updated = [...ws.sets];
    updated[ws.currentSetIndex] = current.copyWith(performed: current.performed ?? 0);

    if (ws.isLastSet) {
      _restTimer?.cancel();
      _cancelRestAlert();
      emit(state.copyWith(
        workout: ws.copyWith(sets: updated, status: WorkoutStatus.complete, clearRestEndsAt: true),
        status: WorkoutBlocStatus.complete,
      ));
      return;
    }

    final restSeconds = _restFor(ws.week, ws.day);
    final resting = ws.copyWith(
      sets: updated,
      status: WorkoutStatus.resting,
      restSecondsRemaining: restSeconds,
      restDurationSeconds: restSeconds,
      restEndsAt: DateTime.now().add(Duration(seconds: restSeconds)),
    );
    emit(state.copyWith(workout: resting, status: WorkoutBlocStatus.resting));
    _scheduleRestAlert(resting);
    _startRestTimer();
  }

  void _onRestTicked(RestTicked event, Emitter<WorkoutBlocState> emit) {
    final ws = state.workout;
    if (ws == null || ws.status != WorkoutStatus.resting) {
      _restTimer?.cancel();
      return;
    }
    final remaining = _remaining(ws.restEndsAt);
    if (remaining <= 0) {
      _restTimer?.cancel();
      _cancelRestAlert();
      emit(state.copyWith(workout: _advanceToNextSet(ws), status: WorkoutBlocStatus.active));
    } else if (remaining != ws.restSecondsRemaining) {
      emit(state.copyWith(workout: ws.copyWith(restSecondsRemaining: remaining)));
    }
  }

  void _onRestExtended(RestExtended event, Emitter<WorkoutBlocState> emit) {
    final ws = state.workout;
    if (ws == null || ws.status != WorkoutStatus.resting || ws.restEndsAt == null) return;

    final updated = [...ws.sets];
    final current = updated[ws.currentSetIndex];
    updated[ws.currentSetIndex] = current.copyWith(restExtendedSec: current.restExtendedSec + event.seconds);

    final endsAt = ws.restEndsAt!.add(Duration(seconds: event.seconds));
    final extended = ws.copyWith(
      sets: updated,
      restEndsAt: endsAt,
      restSecondsRemaining: _remaining(endsAt),
      restDurationSeconds: ws.restDurationSeconds + event.seconds,
    );
    emit(state.copyWith(workout: extended));
    _scheduleRestAlert(extended);
  }

  void _onRestSkipped(RestSkipped event, Emitter<WorkoutBlocState> emit) {
    _restTimer?.cancel();
    final ws = state.workout;
    if (ws == null || ws.status != WorkoutStatus.resting) return;
    _cancelRestAlert();
    emit(state.copyWith(workout: _advanceToNextSet(ws), status: WorkoutBlocStatus.active));
  }

  // ------------------------------------------------------------ persistence

  Future<void> _onSaved(WorkoutSaved event, Emitter<WorkoutBlocState> emit) async {
    final ws = state.workout;
    if (ws == null || state.status == WorkoutBlocStatus.saving || state.status == WorkoutBlocStatus.saved) {
      return;
    }
    _restTimer?.cancel();
    _cancelRestAlert();
    emit(state.copyWith(status: WorkoutBlocStatus.saving));

    final isComplete = ws.status == WorkoutStatus.complete;
    final now = DateTime.now();
    final workoutStatus = isComplete ? 'completed' : 'incomplete';
    int? slotId = state.slotId;

    try {
      await _db.transaction(() async {
        // Ad-hoc workout (no slot): create one so history stays relational.
        slotId ??= await _db.insertSlot(ScheduledSlotsCompanion(
          dueAt: Value(now),
          week: Value(ws.week),
          day: Value(ws.day),
          kind: const Value('workout'),
          status: const Value('pending'),
        ));

        if (ws.workoutId != null) {
          await _db.updateWorkoutStatus(ws.workoutId!, workoutStatus, finishedAt: now);
          for (final set in ws.sets) {
            if (set.dbId != null) {
              await _db.updateSetResult(set.dbId!,
                  performed: set.performed, restExtendedSec: set.restExtendedSec);
            } else {
              await _db.insertSet(_setCompanion(ws.workoutId!, set));
            }
          }
        } else {
          final workoutId = await _db.insertWorkout(WorkoutsCompanion(
            scheduledSlotId: Value(slotId!),
            week: Value(ws.week),
            day: Value(ws.day),
            column: Value(ws.column),
            status: Value(workoutStatus),
            startedAt: Value(ws.startedAt ?? now),
            finishedAt: Value(now),
          ));
          for (final set in ws.sets) {
            await _db.insertSet(_setCompanion(workoutId, set));
          }
        }
      });

      await _sessions.clear();

      String? message;
      if (isComplete) {
        await _db.updateSlotStatus(slotId!, 'done');
        final route = await _progression.onWorkoutCompleted(
          week: ws.week,
          day: ws.day,
          column: ws.column,
        );
        message = route.message;
      } else {
        await _progression.onWorkoutIncomplete(slotId: slotId!);
        message = 'Saved. Resume from set ${ws.completedSets + 1} at your next workout slot.';
      }

      emit(state.copyWith(status: WorkoutBlocStatus.saved, message: message));
    } catch (e) {
      emit(state.copyWith(
        status: isComplete ? WorkoutBlocStatus.complete : WorkoutBlocStatus.active,
        error: 'Could not save workout: $e',
      ));
    }
  }

  WorkoutSetsCompanion _setCompanion(int workoutId, SetState set) => WorkoutSetsCompanion(
        workoutId: Value(workoutId),
        setIndex: Value(set.index),
        prescribed: Value(set.prescribed),
        isPlus: Value(set.isPlus),
        performed: Value(set.performed),
        restExtendedSec: Value(set.restExtendedSec),
      );

  Future<void> _onDiscarded(WorkoutDiscarded event, Emitter<WorkoutBlocState> emit) async {
    _restTimer?.cancel();
    _cancelRestAlert();
    await _sessions.clear();
    if (state.workout == null) return;
    emit(state.copyWith(
      workout: state.workout!.copyWith(status: WorkoutStatus.abandoned),
      status: WorkoutBlocStatus.abandoned,
    ));
  }

  @override
  Future<void> close() {
    _restTimer?.cancel();
    return super.close();
  }
}
