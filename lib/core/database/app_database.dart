import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';
import 'models/dictionary_word.dart';
import 'models/favorite_item.dart';
import 'models/history_item.dart';

export 'models/dictionary_word.dart';
export 'models/favorite_item.dart';
export 'models/history_item.dart';
export 'database_constants.dart';

class AppDatabase {
  static AppDatabase? _instance;
  Database? _db;
  final String? customPath;

  AppDatabase({this.customPath});

  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }

  // Allow setting a mock or test instance
  static set instance(AppDatabase db) {
    _instance = db;
  }

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final String path;
    if (customPath != null) {
      path = customPath!;
    } else {
      final databasesPath = await getDatabasesPath();
      path = p.join(databasesPath, DatabaseConstants.databaseName);
    }

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableFavorites} (
        ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.columnLegacySource} TEXT,
        ${DatabaseConstants.columnLegacyId} INTEGER,
        ${DatabaseConstants.columnTimestamp} INTEGER NOT NULL,
        ${DatabaseConstants.columnMessage} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableHistory} (
        ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.columnLegacySource} TEXT,
        ${DatabaseConstants.columnLegacyId} INTEGER,
        ${DatabaseConstants.columnTimestamp} INTEGER NOT NULL,
        ${DatabaseConstants.columnMessage} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableUserDictionary} (
        ${DatabaseConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.columnWord} TEXT NOT NULL UNIQUE,
        ${DatabaseConstants.columnFrequency} INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tableAppMetadata} (
        ${DatabaseConstants.columnKey} TEXT PRIMARY KEY,
        ${DatabaseConstants.columnValue} TEXT NOT NULL
      )
    ''');
  }

  // --- App Metadata ---

  Future<String?> getMetadata(String key, {DatabaseExecutor? executor}) async {
    final exec = executor ?? await database;
    final results = await exec.query(
      DatabaseConstants.tableAppMetadata,
      columns: [DatabaseConstants.columnValue],
      where: '${DatabaseConstants.columnKey} = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first[DatabaseConstants.columnValue] as String?;
  }

  Future<void> setMetadata(
    String key,
    String value, {
    DatabaseExecutor? executor,
  }) async {
    final exec = executor ?? await database;
    await exec.insert(
      DatabaseConstants.tableAppMetadata,
      {
        DatabaseConstants.columnKey: key,
        DatabaseConstants.columnValue: value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Favorites ---

  Future<List<FavoriteItem>> getAllFavorites({DatabaseExecutor? executor}) async {
    final exec = executor ?? await database;
    final results = await exec.query(
      DatabaseConstants.tableFavorites,
      orderBy: '${DatabaseConstants.columnTimestamp} DESC',
    );
    return results.map((map) => FavoriteItem.fromMap(map)).toList();
  }

  Future<int> insertFavorite(
    FavoriteItem item, {
    DatabaseExecutor? executor,
  }) async {
    final exec = executor ?? await database;
    return await exec.insert(
      DatabaseConstants.tableFavorites,
      item.toMap(),
    );
  }

  Future<int> updateFavorite(
    FavoriteItem item, {
    DatabaseExecutor? executor,
  }) async {
    final exec = executor ?? await database;
    return await exec.update(
      DatabaseConstants.tableFavorites,
      item.toMap(),
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteFavorite(int id, {DatabaseExecutor? executor}) async {
    final exec = executor ?? await database;
    return await exec.delete(
      DatabaseConstants.tableFavorites,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  // --- History ---

  Future<List<HistoryItem>> getAllHistory({DatabaseExecutor? executor}) async {
    final exec = executor ?? await database;
    final results = await exec.query(
      DatabaseConstants.tableHistory,
      orderBy: '${DatabaseConstants.columnTimestamp} DESC',
    );
    return results.map((map) => HistoryItem.fromMap(map)).toList();
  }

  Future<int> insertHistory(
    HistoryItem item, {
    DatabaseExecutor? executor,
  }) async {
    final exec = executor ?? await database;
    return await exec.insert(
      DatabaseConstants.tableHistory,
      item.toMap(),
    );
  }

  Future<int> deleteHistory(int id, {DatabaseExecutor? executor}) async {
    final exec = executor ?? await database;
    return await exec.delete(
      DatabaseConstants.tableHistory,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAllHistory({DatabaseExecutor? executor}) async {
    final exec = executor ?? await database;
    return await exec.delete(DatabaseConstants.tableHistory);
  }

  // --- User Dictionary ---

  Future<List<DictionaryWord>> getDictionaryWords({
    String? prefix,
    int limit = 20,
    DatabaseExecutor? executor,
  }) async {
    final exec = executor ?? await database;
    final List<Map<String, dynamic>> results;

    if (prefix != null && prefix.isNotEmpty) {
      // Menksoft prefix query
      results = await exec.query(
        DatabaseConstants.tableUserDictionary,
        where: '${DatabaseConstants.columnWord} LIKE ?',
        whereArgs: ['$prefix%'],
        orderBy: '${DatabaseConstants.columnFrequency} DESC, length(${DatabaseConstants.columnWord}) ASC',
        limit: limit,
      );
    } else {
      results = await exec.query(
        DatabaseConstants.tableUserDictionary,
        orderBy: '${DatabaseConstants.columnFrequency} DESC',
        limit: limit,
      );
    }
    return results.map((map) => DictionaryWord.fromMap(map)).toList();
  }

  Future<int> insertOrIncrementWord(
    String word, {
    int increment = 1,
    DatabaseExecutor? executor,
  }) async {
    final exec = executor ?? await database;
    return await exec.rawInsert(
      '''
      INSERT INTO ${DatabaseConstants.tableUserDictionary} (${DatabaseConstants.columnWord}, ${DatabaseConstants.columnFrequency})
      VALUES (?, ?)
      ON CONFLICT(${DatabaseConstants.columnWord})
      DO UPDATE SET ${DatabaseConstants.columnFrequency} = ${DatabaseConstants.columnFrequency} + ?
      ''',
      [word, increment, increment],
    );
  }

  Future<int> deleteWord(String word, {DatabaseExecutor? executor}) async {
    final exec = executor ?? await database;
    return await exec.delete(
      DatabaseConstants.tableUserDictionary,
      where: '${DatabaseConstants.columnWord} = ?',
      whereArgs: [word],
    );
  }

  // --- Transactions ---

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
