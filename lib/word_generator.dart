
import 'dart:math';

class WordGenerator {
  WordGenerator(this.seed, int wordListType)
      : random = Random(seed),
        modulo = wordListType;

  final int seed;
  final Random random;
  final int modulo;

  static List<String> _words = [];

  static void initializeWordList(List<dynamic> words) {
    WordGenerator._words = List.from(words);
  }

  String nextWord() {
    final index = random.nextInt(modulo);
    return WordGenerator._words[index];
  }
}
