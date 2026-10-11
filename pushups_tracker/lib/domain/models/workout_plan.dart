/// One prescribed set of a workout day in a given column.
class PlannedSet {
  final int index; // 0-based
  final int reps;
  final bool isPlus;

  const PlannedSet({required this.index, required this.reps, required this.isPlus});

  String get label => isPlus ? '$reps+' : '$reps';
}

/// What a workout day looks like for a specific column: the content shown in
/// the Workout Preview (spec §3.8) and the Next Up card.
class WorkoutPlan {
  final int week;
  final int day; // 0-based
  final int column; // 1-based
  final String columnLabel; // e.g. "6-10"
  final int restSeconds;
  final List<PlannedSet> sets;

  const WorkoutPlan({
    required this.week,
    required this.day,
    required this.column,
    required this.columnLabel,
    required this.restSeconds,
    required this.sets,
  });

  int get setCount => sets.length;
  int get totalMinReps => sets.fold<int>(0, (sum, s) => sum + s.reps);

  /// Spec §3.8: ≈ 2 s per rep + rest × (sets − 1).
  Duration get estimatedDuration =>
      Duration(seconds: totalMinReps * 2 + restSeconds * (setCount - 1).clamp(0, setCount));

  int get estimatedMinutes => (estimatedDuration.inSeconds / 60).ceil();

  /// "10 · 12 · 7 · 7 · 9+"
  String get summary => sets.map((s) => s.label).join(' · ');

  String get title => 'Week $week · Day ${day + 1}';
  String get columnTitle => columnLabel.isEmpty ? 'Column $column' : 'Column $column · $columnLabel';
}
