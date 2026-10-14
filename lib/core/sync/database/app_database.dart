import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// The Balora Mobile local database.
///
/// Kept intentionally lightweight — only stores:
/// - Sync Queue (commands pending sync)
/// - Sessions (pairing/auth data)
/// - Scan History (barcode log)
///
/// This is NOT a full product cache — data comes from
/// Balora Desktop via REST calls.
@DriftDatabase(tables: [QueueItems, Sessions, ScanHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing — accepts a custom query executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here.
      },
    );
  }
}

/// Opens a persistent SQLite database for the application.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'balora_mob.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
