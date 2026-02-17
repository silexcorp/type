
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../word_model.dart';
import '../../../../word_generator.dart';

class WordRepository {
  Map<String, String> _translations = {};
  List<String> _currentWords = [];

  Future<void> loadTranslations() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/translations_es.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _translations = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print("Error loading translations: $e");
      // Populate with some defaults or leave empty if file missing
    }
  }

  Future<List<String>> loadWordsForCategory(String category) async {
    String assetPath;
    switch (category.toLowerCase()) {
      case 'adjectives':
        assetPath = 'assets/adjectives.txt';
        break;
      case 'verbs':
        assetPath = 'assets/verbs.txt';
        break;
      case 'nouns':
        assetPath = 'assets/nouns.txt';
        break;
      default:
        assetPath = 'assets/words.txt';
    }

    try {
      final String content = await rootBundle.loadString(assetPath);
      _currentWords = content.split('\n').map((w) => w.trim()).where((w) => w.isNotEmpty).toList();
      return _currentWords;
    } catch (e) {
      print("Error loading words for $category: $e");
      return [];
    }
  }

  String getTranslation(String word) {
    return _translations[word.toLowerCase()] ?? 'Traducción no disponible';
  }
}
