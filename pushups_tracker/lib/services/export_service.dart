import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show ValueSerializer;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';

/// Exports the whole local database as one CSV per table plus a single JSON
/// backup, then hands the files to the OS share sheet (spec §10.1).
class ExportService {
  final AppDatabase _db;

  ExportService(this._db);

  Future<Map<String, List<Map<String, dynamic>>>> dumpTables() async {
    const serializer = ValueSerializer.defaults(serializeDateTimeValuesAsString: true);
    return {
      'users': [for (final r in await _db.select(_db.users).get()) r.toJson(serializer: serializer)],
      'scheduled_slots': [
        for (final r in await _db.select(_db.scheduledSlots).get()) r.toJson(serializer: serializer)
      ],
      'workouts': [for (final r in await _db.select(_db.workouts).get()) r.toJson(serializer: serializer)],
      'workout_sets': [for (final r in await _db.select(_db.workoutSets).get()) r.toJson(serializer: serializer)],
      'tests': [for (final r in await _db.select(_db.tests).get()) r.toJson(serializer: serializer)],
    };
  }

  /// Writes the export files to a temp folder and opens the share sheet.
  /// Returns the number of files shared.
  Future<int> shareExport() async {
    final tables = await dumpTables();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final dir = Directory(p.join((await getTemporaryDirectory()).path, 'pushups_export_$stamp'));
    await dir.create(recursive: true);

    final files = <XFile>[];
    for (final entry in tables.entries) {
      final file = File(p.join(dir.path, '${entry.key}.csv'));
      await file.writeAsString(toCsv(entry.value));
      files.add(XFile(file.path, mimeType: 'text/csv', name: '${entry.key}.csv'));
    }

    final backup = File(p.join(dir.path, 'pushups_backup_$stamp.json'));
    await backup.writeAsString(json.encode({
      'app': 'pushups_tracker',
      'exportedAt': DateTime.now().toIso8601String(),
      'schemaVersion': _db.schemaVersion,
      'tables': tables,
    }));
    files.add(XFile(backup.path, mimeType: 'application/json', name: p.basename(backup.path)));

    await SharePlus.instance.share(ShareParams(
      files: files,
      subject: '100 Pushups — data export $stamp',
      text: 'Workout history export (CSV per table + JSON backup).',
    ));
    return files.length;
  }

  /// Minimal RFC 4180 encoder. Column order follows the first row's keys.
  static String toCsv(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return '';
    final columns = rows.first.keys.toList();
    final buffer = StringBuffer()..writeln(columns.map(_escape).join(','));
    for (final row in rows) {
      buffer.writeln(columns.map((c) => _escape(row[c])).join(','));
    }
    return buffer.toString();
  }

  static String _escape(Object? value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
