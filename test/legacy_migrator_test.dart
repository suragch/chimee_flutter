import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:chimee/core/database/app_database.dart';
import 'package:chimee/core/database/legacy_migrator.dart';
import 'package:chimee/core/codec/legacy/legacy.dart';

void main() {
  // Initialize FFI for local tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory tempDir;
  late String appDbPath;
  late AppDatabase appDb;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('chimee_db_test_');
    appDbPath = '${tempDir.path}/chimee_flutter.db';
    appDb = AppDatabase(customPath: appDbPath);
  });

  tearDown(() async {
    await appDb.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AppDatabase basic CRUD', () {
    test('can insert, retrieve, update, and delete favorites', () async {
      final favs = await appDb.getAllFavorites();
      expect(favs, isEmpty);

      final id = await appDb.insertFavorite(
        FavoriteItem(
          timestamp: 123456789,
          message: '',
        ),
      );
      expect(id, isPositive);

      final listAfter = await appDb.getAllFavorites();
      expect(listAfter.length, 1);
      expect(listAfter.first.message, '');
      expect(listAfter.first.timestamp, 123456789);

      await appDb.updateFavorite(
        listAfter.first.copyWith(message: ' updated'),
      );
      final listUpdated = await appDb.getAllFavorites();
      expect(listUpdated.first.message, ' updated');

      await appDb.deleteFavorite(id);
      expect(await appDb.getAllFavorites(), isEmpty);
    });

    test('can insert, retrieve, and clear history', () async {
      await appDb.insertHistory(
        HistoryItem(timestamp: 1000, message: 'msg1'),
      );
      await appDb.insertHistory(
        HistoryItem(timestamp: 2000, message: 'msg2'),
      );

      final history = await appDb.getAllHistory();
      expect(history.length, 2);
      expect(history.first.message, 'msg2'); // sorted DESC by timestamp

      await appDb.clearAllHistory();
      expect(await appDb.getAllHistory(), isEmpty);
    });

    test('can insert, query prefix, and increment user dictionary words', () async {
      await appDb.insertOrIncrementWord('');
      await appDb.insertOrIncrementWord('');
      await appDb.insertOrIncrementWord('');

      final words = await appDb.getDictionaryWords(prefix: '');
      expect(words.length, 2);
      // '' has frequency 2 so it should be first
      expect(words.first.word, '');
      expect(words.first.frequency, 2);
      expect(words.last.word, '');
      expect(words.last.frequency, 1);
    });
  });

  group('LegacyMigrator', () {
    test('fresh install seeds default favorites and marks completed', () async {
      final migrator = LegacyMigrator(
        appDatabase: appDb,
        androidLegacyPath: '${tempDir.path}/non_existent_android.db',
        iosLegacyPath: '${tempDir.path}/non_existent_ios.db',
      );

      final result = await migrator.executeMigration();
      expect(result.alreadyCompleted, isFalse);
      expect(result.detectedSources, isEmpty);

      final status = await appDb.getMetadata(
        DatabaseConstants.keyLegacyMigrationCompleted,
      );
      expect(status, '1');

      final favorites = await appDb.getAllFavorites();
      expect(favorites.length, 3);
      // Verify text is converted to Menksoft code
      for (final fav in favorites) {
        expect(fav.message.isNotEmpty, isTrue);
        // Menksoft PUA characters are >= 0xE200
        expect(
          fav.message.codeUnits.any((c) => c >= 0xE200),
          isTrue,
        );
      }

      // Second migration should be a no-op
      final secondResult = await migrator.executeMigration();
      expect(secondResult.alreadyCompleted, isTrue);
      expect(await appDb.getAllFavorites(), hasLength(3));
    });

    test('migrates Android legacy database with millisecond timestamps', () async {
      final androidDbPath = '${tempDir.path}/chimee_user_messages.db';
      final androidDb = await openDatabase(androidDbPath, version: 1,
          onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE FAVORITE (
            _id INTEGER PRIMARY KEY,
            date_time INTEGER,
            message TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE HISTORY (
            _id INTEGER PRIMARY KEY,
            date_time INTEGER,
            message TEXT NOT NULL
          )
        ''');
      });

      const sampleUnicode = 'ᠰᠠᠢᠨ ᠪᠠᠢᠨ᠎ᠠ ᠤᠤ';
      final expectedMenksoft = MongolCode.instance.unicodeToMenksoft(sampleUnicode);
      const androidTimestampMs = 1700000000123; // >= 10^11

      await androidDb.insert('FAVORITE', {
        '_id': 42,
        'date_time': androidTimestampMs,
        'message': sampleUnicode,
      });

      await androidDb.insert('HISTORY', {
        '_id': 99,
        'date_time': androidTimestampMs + 100,
        'message': sampleUnicode,
      });

      await androidDb.close();

      final migrator = LegacyMigrator(
        appDatabase: appDb,
        androidLegacyPath: androidDbPath,
        iosLegacyPath: '${tempDir.path}/non_existent_ios.db',
      );

      final result = await migrator.executeMigration();
      expect(result.alreadyCompleted, isFalse);
      expect(result.detectedSources, contains('android'));
      expect(result.migratedFavorites, 1);
      expect(result.migratedHistory, 1);

      // Verify favorites
      final favorites = await appDb.getAllFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.legacySource, 'android');
      expect(favorites.first.legacyId, 42);
      expect(favorites.first.timestamp, androidTimestampMs);
      expect(favorites.first.message, expectedMenksoft);

      // Verify history
      final history = await appDb.getAllHistory();
      expect(history.length, 1);
      expect(history.first.legacySource, 'android');
      expect(history.first.legacyId, 99);
      expect(history.first.timestamp, androidTimestampMs + 100);
      expect(history.first.message, expectedMenksoft);

      // Verify legacy file still exists and was untouched
      expect(File(androidDbPath).existsSync(), isTrue);
    });

    test('migrates iOS legacy database with second timestamps scaled x1000', () async {
      final iosDbPath = '${tempDir.path}/db.sqlite';
      final iosDb = await openDatabase(iosDbPath, version: 1,
          onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE favorite (
            _id INTEGER PRIMARY KEY,
            datetime INTEGER,
            message TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE history (
            _id INTEGER PRIMARY KEY,
            datetime INTEGER,
            message TEXT NOT NULL
          )
        ''');
      });

      const sampleUnicode = 'ᠮᠣᠩᠭᠣᠯ';
      final expectedMenksoft = MongolCode.instance.unicodeToMenksoft(sampleUnicode);
      const iosTimestampSec = 1609459200; // < 10^11 (seconds)

      await iosDb.insert('favorite', {
        '_id': 101,
        'datetime': iosTimestampSec,
        'message': sampleUnicode,
      });

      await iosDb.insert('history', {
        '_id': 202,
        'datetime': iosTimestampSec + 5,
        'message': sampleUnicode,
      });

      await iosDb.close();

      final migrator = LegacyMigrator(
        appDatabase: appDb,
        androidLegacyPath: '${tempDir.path}/non_existent_android.db',
        iosLegacyPath: iosDbPath,
      );

      final result = await migrator.executeMigration();
      expect(result.alreadyCompleted, isFalse);
      expect(result.detectedSources, contains('ios'));
      expect(result.migratedFavorites, 1);
      expect(result.migratedHistory, 1);

      // Verify favorites
      final favorites = await appDb.getAllFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.legacySource, 'ios');
      expect(favorites.first.legacyId, 101);
      expect(favorites.first.timestamp, iosTimestampSec * 1000); // scaled to ms
      expect(favorites.first.message, expectedMenksoft);

      // Verify history
      final history = await appDb.getAllHistory();
      expect(history.length, 1);
      expect(history.first.legacySource, 'ios');
      expect(history.first.legacyId, 202);
      expect(history.first.timestamp, (iosTimestampSec + 5) * 1000); // scaled to ms
      expect(history.first.message, expectedMenksoft);

      // Verify legacy file still exists and was untouched
      expect(File(iosDbPath).existsSync(), isTrue);
    });
  });
}
