
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:type_word/features/practice/repository/word_repository.dart';
import 'package:type_word/widgets/word_generator.dart';

// Events
abstract class PracticeEvent extends Equatable {
  const PracticeEvent();
  @override
  List<Object> get props => [];
}

class LoadCategory extends PracticeEvent {
  final String category;
  const LoadCategory(this.category);
}

class PracticeInputChanged extends PracticeEvent {
  final String input;
  const PracticeInputChanged(this.input);
}

class SubmitWord extends PracticeEvent {}

// States
abstract class PracticeState extends Equatable {
  const PracticeState();
  @override
  List<Object?> get props => [];
}

class PracticeInitial extends PracticeState {}

class PracticeLoading extends PracticeState {}

class PracticeLoaded extends PracticeState {
  final String currentWord;
  final String translation;
  final String typedText;
  final bool isCorrect;
  final int wordsTyped;
  final int wpm;

  const PracticeLoaded({
    required this.currentWord,
    required this.translation,
    this.typedText = '',
    this.isCorrect = true, // Initially true or neutral
    this.wordsTyped = 0,
    this.wpm = 0,
  });

  PracticeLoaded copyWith({
    String? currentWord,
    String? translation,
    String? typedText,
    bool? isCorrect,
    int? wordsTyped,
    int? wpm,
  }) {
    return PracticeLoaded(
      currentWord: currentWord ?? this.currentWord,
      translation: translation ?? this.translation,
      typedText: typedText ?? this.typedText,
      isCorrect: isCorrect ?? this.isCorrect,
      wordsTyped: wordsTyped ?? this.wordsTyped,
      wpm: wpm ?? this.wpm,
    );
  }

  @override
  List<Object?> get props => [currentWord, translation, typedText, isCorrect, wordsTyped, wpm];
}

class PracticeError extends PracticeState {
  final String message;
  const PracticeError(this.message);
}

// BLoC
class PracticeBloc extends Bloc<PracticeEvent, PracticeState> {
  final WordRepository repository;
  late WordGenerator _wordGenerator;
  
  PracticeBloc(this.repository) : super(PracticeInitial()) {
    on<LoadCategory>(_onLoadCategory);
    on<PracticeInputChanged>(_onInputChanged);
    on<SubmitWord>(_onSubmitWord);
  }

  Future<void> _onLoadCategory(LoadCategory event, Emitter<PracticeState> emit) async {
    emit(PracticeLoading());
    try {
      await repository.loadTranslations();
      final words = await repository.loadWordsForCategory(event.category);
      if (words.isEmpty) {
        emit(const PracticeError("No words found for this category"));
        return;
      }
      
      // Shuffle words for random order
      words.shuffle();
      
      WordGenerator.initializeWordList(words);
      _wordGenerator = WordGenerator(0); // Seed 0
      
      final firstWord = _wordGenerator.nextWord();
      final translation = repository.getTranslation(firstWord);
      
      emit(PracticeLoaded(
        currentWord: firstWord,
        translation: translation,
      ));
    } catch (e) {
      emit(PracticeError(e.toString()));
    }
  }

  void _onInputChanged(PracticeInputChanged event, Emitter<PracticeState> emit) {
    if (state is PracticeLoaded) {
      final currentState = state as PracticeLoaded;
      final normalizedInput = event.input.toLowerCase();
      bool isCorrect = currentState.currentWord.startsWith(normalizedInput);
      
      emit(currentState.copyWith(
        typedText: normalizedInput,
        isCorrect: isCorrect,
      ));

      if (normalizedInput == currentState.currentWord) {
        add(SubmitWord());
      }
    }
  }

  void _onSubmitWord(SubmitWord event, Emitter<PracticeState> emit) {
    if (state is PracticeLoaded) {
      final currentState = state as PracticeLoaded;
      // Ensure specific comparison just in case, though typedText should be lowercased already
      if (currentState.typedText == currentState.currentWord) {
         final nextWord = _wordGenerator.nextWord();
         final translation = repository.getTranslation(nextWord);
         
         emit(currentState.copyWith(
           currentWord: nextWord,
           translation: translation,
           typedText: '',
           isCorrect: true,
           wordsTyped: currentState.wordsTyped + 1,
         ));
      } else {
        // Handle incorrect submission visual feedback if needed
      }
    }
  }
}
