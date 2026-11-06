import '../database_constants.dart';

class FavoriteItem {
  final int? id;
  final String? legacySource;
  final int? legacyId;
  final int timestamp;
  final String message;

  FavoriteItem({
    this.id,
    this.legacySource,
    this.legacyId,
    required this.timestamp,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DatabaseConstants.columnTimestamp: timestamp,
      DatabaseConstants.columnMessage: message,
    };
    if (id != null) {
      map[DatabaseConstants.columnId] = id;
    }
    if (legacySource != null) {
      map[DatabaseConstants.columnLegacySource] = legacySource;
    }
    if (legacyId != null) {
      map[DatabaseConstants.columnLegacyId] = legacyId;
    }
    return map;
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      id: map[DatabaseConstants.columnId] as int?,
      legacySource: map[DatabaseConstants.columnLegacySource] as String?,
      legacyId: map[DatabaseConstants.columnLegacyId] as int?,
      timestamp: map[DatabaseConstants.columnTimestamp] as int,
      message: map[DatabaseConstants.columnMessage] as String,
    );
  }

  FavoriteItem copyWith({
    int? id,
    String? legacySource,
    int? legacyId,
    int? timestamp,
    String? message,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      legacySource: legacySource ?? this.legacySource,
      legacyId: legacyId ?? this.legacyId,
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          legacySource == other.legacySource &&
          legacyId == other.legacyId &&
          timestamp == other.timestamp &&
          message == other.message;

  @override
  int get hashCode =>
      id.hashCode ^
      legacySource.hashCode ^
      legacyId.hashCode ^
      timestamp.hashCode ^
      message.hashCode;
}
