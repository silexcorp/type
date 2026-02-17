
class WordGenerator {

  WordGenerator(this.seed);

  final int seed;
  int index = -1;

  static List<String> words = [];

  static void initializeWordList(List<dynamic> words) {
    print("#### WORDS: ${words.toString()}");
    WordGenerator.words = List.from(words);
  }

  String nextWord() {
    if(index < WordGenerator.words.length){
    }else{
      index = 0;
    }
    index++;
    print("#### index: $index, word: ${WordGenerator.words[index]}");
    return WordGenerator.words[index];
  }
}

/*

class WordGenerator {

  WordGenerator(this.seed);

  int seed = 0;
  int index = 0;
  int current = 0;
  static List<Word> _list = [];
  static Word word = Word();

  static List<String> words = [];

  static void initializeWordList(List<Word> words) {
    WordGenerator._list = words;
  }

  void nextItem(){
    index = 0;
    word = WordGenerator._list.elementAt(seed);
    word.descriptions.forEach((element) {
      List<String> items = element.split(' ');
      print("### words:[${word.word}] ${items}");
      index += items.length;
      words.addAll(items);
    });
  }

  int getWordsLength(){
    return index;
  }

  String nextWord() {
    if(current >= 0 && current < words.length){
      ++current;
      return words.elementAt(current);
    }else{
      return '';
    }
  }
}
*/
