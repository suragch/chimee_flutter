import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../codec/legacy/legacy.dart';
import 'app_database.dart';

class MigrationResult {
  final bool alreadyCompleted;
  final int migratedFavorites;
  final int migratedHistory;
  final List<String> detectedSources;

  const MigrationResult({
    required this.alreadyCompleted,
    this.migratedFavorites = 0,
    this.migratedHistory = 0,
    this.detectedSources = const [],
  });
}

class LegacyMigrator {
  final AppDatabase _appDatabase;
  final String? androidLegacyPath;
  final String? iosLegacyPath;

  // Default initial messages for fresh installs (originally from strings.xml)
  static const List<String> defaultInitialUnicodeMessages = [
    'ᠳᠠᠷᠤᠪᠴᠢ ᠶᠢ ᠳᠠᠷᠤᠭᠠᠳ ᠪᠠᠢᠪᠠᠯ ᠵᠠᠬᠢᠶ᠎ᠠ ᠶᠢ ᠤᠰᠠᠳᠬᠠᠵᠤ ᠬᠠᠶᠠᠨ᠎ᠠ ᠃',
    'ᠵᠠᠬᠢᠶ᠎ᠠ ᠶᠢ ᠳᠣᠪᠴᠢᠳᠠᠪᠠᠯ ᠨᠠᠢᠷᠠᠭᠤᠯᠬᠤ ᠴᠣᠩᠬᠣᠨ ᠳᠤ ᠬᠠᠭᠤᠯᠤᠨ ᠠᠪᠴᠢᠷᠠᠨ᠎ᠠ ᠃',
    'ᠰᠠᠢᠨ ᠪᠠᠢᠨ᠎ᠠ ᠤᠤ ︖',
  ];

  LegacyMigrator({
    AppDatabase? appDatabase,
    this.androidLegacyPath,
    this.iosLegacyPath,
  }) : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<MigrationResult> executeMigration() async {
    final completed = await _appDatabase.getMetadata(
      DatabaseConstants.keyLegacyMigrationCompleted,
    );
    if (completed == '1') {
      return const MigrationResult(alreadyCompleted: true);
    }

    final androidPath = await _resolveAndroidPath();
    final iosPath = await _resolveIosPath();

    final List<FavoriteItem> favoritesToMigrate = [];
    final List<HistoryItem> historyToMigrate = [];
    final List<String> detectedSources = [];

    // Probe legacy Android database
    if (androidPath != null && File(androidPath).existsSync()) {
      final androidItems = await _readLegacyAndroidDatabase(androidPath);
      if (androidItems != null) {
        favoritesToMigrate.addAll(androidItems.favorites);
        historyToMigrate.addAll(androidItems.history);
        detectedSources.add(DatabaseConstants.legacySourceAndroid);
      }
    }

    // Probe legacy iOS database
    if (iosPath != null && File(iosPath).existsSync()) {
      final iosItems = await _readLegacyIosDatabase(iosPath);
      if (iosItems != null) {
        favoritesToMigrate.addAll(iosItems.favorites);
        historyToMigrate.addAll(iosItems.history);
        detectedSources.add(DatabaseConstants.legacySourceIos);
      }
    }

    // Execute atomic transaction on chimee_flutter.db
    await _appDatabase.transaction((txn) async {
      // If legacy items found, insert them
      for (final fav in favoritesToMigrate) {
        await _appDatabase.insertFavorite(fav, executor: txn);
      }
      for (final hist in historyToMigrate) {
        await _appDatabase.insertHistory(hist, executor: txn);
      }

      // If fresh install with no legacy items, seed default favorites
      if (detectedSources.isEmpty && favoritesToMigrate.isEmpty) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final legacyCodec = MongolCode.instance;
        for (int i = 0; i < defaultInitialUnicodeMessages.length; i++) {
          final menksoftMsg = legacyCodec.unicodeToMenksoft(
            defaultInitialUnicodeMessages[i],
          );
          await _appDatabase.insertFavorite(
            FavoriteItem(
              timestamp: now + i,
              message: menksoftMsg,
            ),
            executor: txn,
          );
        }
      }

      // Mark migration as completed
      await _appDatabase.setMetadata(
        DatabaseConstants.keyLegacyMigrationCompleted,
        '1',
        executor: txn,
      );
    });

    return MigrationResult(
      alreadyCompleted: false,
      migratedFavorites: favoritesToMigrate.length,
      migratedHistory: historyToMigrate.length,
      detectedSources: detectedSources,
    );
  }

  Future<String?> _resolveAndroidPath() async {
    if (androidLegacyPath != null) return androidLegacyPath;
    try {
      final dbDir = await getDatabasesPath();
      return p.join(dbDir, DatabaseConstants.legacyAndroidDbName);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveIosPath() async {
    if (iosLegacyPath != null) return iosLegacyPath;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      return p.join(docDir.path, DatabaseConstants.legacyIosDbName);
    } catch (_) {
      return null;
    }
  }

  Future<_LegacyExtractedItems?> _readLegacyAndroidDatabase(String path) async {
    Database? db;
    try {
      db = await openDatabase(path, readOnly: true);
      final legacyCodec = MongolCode.instance;

      final List<FavoriteItem> favorites = [];
      final List<HistoryItem> history = [];

      // Android table: FAVORITE (_id, date_time, message)
      if (await _tableExists(db, 'FAVORITE')) {
        final rows = await db.query('FAVORITE');
        for (final row in rows) {
          final id = row['_id'] as int?;
          final rawTime = row['date_time'] as int?;
          final rawMsg = row['message'] as String?;
          if (rawMsg == null || rawMsg.isEmpty) continue;

          final timestamp = _normalizeTimestamp(rawTime);
          final menksoft = legacyCodec.unicodeToMenksoft(rawMsg);
          favorites.add(
            FavoriteItem(
              legacySource: DatabaseConstants.legacySourceAndroid,
              legacyId: id,
              timestamp: timestamp,
              message: menksoft,
            ),
          );
        }
      }

      // Android table: HISTORY (_id, date_time, message)
      if (await _tableExists(db, 'HISTORY')) {
        final rows = await db.query('HISTORY');
        for (final row in rows) {
          final id = row['_id'] as int?;
          final rawTime = row['date_time'] as int?;
          final rawMsg = row['message'] as String?;
          if (rawMsg == null || rawMsg.isEmpty) continue;

          final timestamp = _normalizeTimestamp(rawTime);
          final menksoft = legacyCodec.unicodeToMenksoft(rawMsg);
          history.add(
            HistoryItem(
              legacySource: DatabaseConstants.legacySourceAndroid,
              legacyId: id,
              timestamp: timestamp,
              message: menksoft,
            ),
          );
        }
      }

      return _LegacyExtractedItems(favorites: favorites, history: history);
    } catch (_) {
      return null;
    } finally {
      if (db != null && db.isOpen) {
        await db.close();
      }
    }
  }

  Future<_LegacyExtractedItems?> _readLegacyIosDatabase(String path) async {
    Database? db;
    try {
      db = await openDatabase(path, readOnly: true);
      final legacyCodec = MongolCode.instance;

      final List<FavoriteItem> favorites = [];
      final List<HistoryItem> history = [];

      // iOS table: favorite (_id, datetime, message)
      if (await _tableExists(db, 'favorite')) {
        final rows = await db.query('favorite');
        for (final row in rows) {
          final id = row['_id'] as int?;
          final rawTime = row['datetime'] as int?;
          final rawMsg = row['message'] as String?;
          if (rawMsg == null || rawMsg.isEmpty) continue;

          final timestamp = _normalizeTimestamp(rawTime);
          final menksoft = legacyCodec.unicodeToMenksoft(rawMsg);
          favorites.add(
            FavoriteItem(
              legacySource: DatabaseConstants.legacySourceIos,
              legacyId: id,
              timestamp: timestamp,
              message: menksoft,
            ),
          );
        }
      }

      // iOS table: history (_id, datetime, message)
      if (await _tableExists(db, 'history')) {
        final rows = await db.query('history');
        for (final row in rows) {
          final id = row['_id'] as int?;
          final rawTime = row['datetime'] as int?;
          final rawMsg = row['message'] as String?;
          if (rawMsg == null || rawMsg.isEmpty) continue;

          final timestamp = _normalizeTimestamp(rawTime);
          final menksoft = legacyCodec.unicodeToMenksoft(rawMsg);
          history.add(
            HistoryItem(
              legacySource: DatabaseConstants.legacySourceIos,
              legacyId: id,
              timestamp: timestamp,
              message: menksoft,
            ),
          );
        }
      }

      return _LegacyExtractedItems(favorites: favorites, history: history);
    } catch (_) {
      return null;
    } finally {
      if (db != null && db.isOpen) {
        await db.close();
      }
    }
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  int _normalizeTimestamp(int? raw) {
    if (raw == null) {
      return DateTime.now().millisecondsSinceEpoch;
    }
    // Android stores milliseconds (>= 10^11)
    // iOS stores seconds (< 10^11), scale by 1000
    if (raw < 100000000000) {
      return raw * 1000;
    }
    return raw;
  }
}

class _LegacyExtractedItems {
  final List<FavoriteItem> favorites;
  final List<HistoryItem> history;

  _LegacyExtractedItems({
    required this.favorites,
    required this.history,
  });
}
