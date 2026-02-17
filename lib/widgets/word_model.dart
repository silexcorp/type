
class Word {
  String word;
  List<dynamic> derivatives;
  List<dynamic> descriptions;
  List<dynamic> examples;
  int frequency;
  List<dynamic> synonyms;
  Map<String, List<dynamic>> translations;

  Word({
    this.word = '',
    this.derivatives = const [],
    this.descriptions = const [],
    this.examples = const [],
    this.frequency = 0,
    this.synonyms = const [],
    this.translations = const {},
  });

  factory Word.fromJson(MapEntry<String, dynamic> json) {
    String word = json.key;
    Map<String, dynamic> wordData = json.value;
    return Word(
      word: word,
      derivatives: wordData['derivatives'] == null ? [] : List<String>.from(wordData['derivatives']),
      descriptions: wordData['descriptions'] == null ? [] : List<String>.from(wordData['descriptions']),
      examples: wordData['examples'] == null ? [] : List<String>.from(wordData['examples']),
      frequency: wordData['frequency'] ?? 0,
      synonyms: [],//List<String>.from(wordData['synonyms']),
      translations: {}//(wordData['translations'] as Map<String, dynamic>).map((key, value) => MapEntry(key, List<String>.from(value)),),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'derivatives': derivatives,
      'descriptions': descriptions,
      'examples': examples,
      'frequency': frequency,
      'synonyms': synonyms,
      'translations': translations,
    };
  }
}