
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:type_word/features/practice/bloc/practice_bloc.dart';
import 'package:type_word/features/practice/repository/word_repository.dart';
import 'package:type_word/widgets/theme_colors.dart';

class PracticeScreen extends StatelessWidget {
  final String category;

  const PracticeScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PracticeBloc(WordRepository())..add(LoadCategory(category)),
      child: const PracticeView(),
    );
  }
}

class PracticeView extends StatefulWidget {
  const PracticeView({Key? key}) : super(key: key);

  @override
  State<PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends State<PracticeView> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(BuildContext context, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final bloc = context.read<PracticeBloc>();
      final state = bloc.state;

      if (state is PracticeLoaded) {
        if (event.logicalKey.keyLabel != null &&
            event.logicalKey.keyLabel.length == 1 &&
            // Allow all printable characters (excluding ASCII control chars)
            !RegExp(r'[\x00-\x1F\x7F]').hasMatch(event.logicalKey.keyLabel) &&
            !event.isControlPressed && !event.isMetaPressed // Avoid shortcuts
           ) {
          bloc.add(PracticeInputChanged(state.typedText + event.logicalKey.keyLabel));
        } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
          if (state.typedText.isNotEmpty) {
            bloc.add(PracticeInputChanged(state.typedText.substring(0, state.typedText.length - 1)));
          }
        } else if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.enter) {
          if (state.typedText == state.currentWord) {
            bloc.add(SubmitWord());
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (event) => _handleKeyEvent(context, event),
        child: BlocConsumer<PracticeBloc, PracticeState>(
          listenWhen: (previous, current) {
             return previous is PracticeLoaded && 
                    current is PracticeLoaded && 
                    current.wordsTyped > previous.wordsTyped;
          },
          listener: (context, state) {
            SystemSound.play(SystemSoundType.click);
          },
          builder: (context, state) {
            if (state is PracticeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PracticeError) {
              return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
            } else if (state is PracticeLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Words Typed: ${state.wordsTyped}',
                      style: const TextStyle(color: ThemeColors.green, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    // Word Display
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Text(
                          state.currentWord,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.grey[800],
                              fontFamily: 'Courier', 
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          state.typedText,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: state.isCorrect ? ThemeColors.green : ThemeColors.red,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Translation Display
                    Text(
                      state.translation,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Type the word above',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
