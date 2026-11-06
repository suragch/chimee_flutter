import '../database_constants.dart';

class DictionaryWord {
  final int? id;
  final String word;
  final int frequency;

  DictionaryWord({
    this.id,
    required this.word,
    this.frequency = 1,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      DatabaseConstants.columnWord: word,
      DatabaseConstants.columnFrequency: frequency,
    };
    if (id != null) {
      map[DatabaseConstants.columnId] = id;
    }
    return map;
  }

  factory DictionaryWord.fromMap(Map<String, dynamic> map) {
    return DictionaryWord(
      id: map[DatabaseConstants.columnId] as int?,
      word: map[DatabaseConstants.columnWord] as String,
      frequency: (map[DatabaseConstants.columnFrequency] as int?) ?? 1,
    );
  }

  DictionaryWord copyWith({
    int? id,
    String? word,
    int? frequency,
  }) {
    return DictionaryWord(
      id: id ?? this.id,
      word: word ?? this.word,
      frequency: frequency ?? this.frequency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DictionaryWord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          word == other.word &&
          frequency == other.frequency;

  @override
  int get hashCode => id.hashCode ^ word.hashCode ^ frequency.hashCode;
}
