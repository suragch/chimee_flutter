class DatabaseConstants {
  static const String databaseName = 'chimee_flutter.db';
  static const int databaseVersion = 1;

  // Table names
  static const String tableFavorites = 'favorites';
  static const String tableHistory = 'history';
  static const String tableUserDictionary = 'user_dictionary';
  static const String tableAppMetadata = 'app_metadata';

  // Common message table columns
  static const String columnId = 'id';
  static const String columnLegacySource = 'legacy_source';
  static const String columnLegacyId = 'legacy_id';
  static const String columnTimestamp = 'timestamp';
  static const String columnMessage = 'message';

  // User dictionary columns
  static const String columnWord = 'word';
  static const String columnFrequency = 'frequency';

  // App metadata columns
  static const String columnKey = 'key';
  static const String columnValue = 'value';

  // Metadata keys
  static const String keyLegacyMigrationCompleted = 'legacy_migration_completed';
  static const String keyInitialDataSeeded = 'initial_data_seeded';

  // Legacy platform identifiers
  static const String legacySourceAndroid = 'android';
  static const String legacySourceIos = 'ios';

  // Legacy filenames
  static const String legacyAndroidDbName = 'chimee_user_messages.db';
  static const String legacyIosDbName = 'db.sqlite';
}
