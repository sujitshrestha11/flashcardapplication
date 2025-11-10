import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

// --- Data Model ---
class WordPair {
  final String korean;
  final String english;

  WordPair(this.korean, this.english);
}

// --- Theme Management ---
class ThemeProvider with ChangeNotifier {
  final SharedPreferences prefs;
  late bool _isDarkMode;

  ThemeProvider(this.prefs) {
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}

// --- Main Application State ---
class TrainerState with ChangeNotifier {
  final FlutterTts flutterTts = FlutterTts();

  String vocabularyText = '';
  List<WordPair> wordPairs = [];
  int repetitions = 1;
  int shuffleReps = 1;
  double speed = 0.5;
  bool speakEnglish = true;

  bool isPlaying = false;
  int currentIndex = -1;
  int currentRep = 0;
  String status = 'Ready';

  bool get isTtsInitialized => _isTtsInitialized;
  bool _isTtsInitialized = false;

  final ScrollController scrollController = ScrollController();

  TrainerState() {
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.awaitSpeakCompletion(true);
    _isTtsInitialized = true;
  }

  void parseVocabulary() {
    wordPairs = vocabularyText
        .split('\n')
        .where((line) => line.contains(';'))
        .map((line) {
          final parts = line.split(';');
          return WordPair(parts[0].trim(), parts[1].trim());
        })
        .toList();
    notifyListeners();
  }

  void _updateStatus(String newStatus) {
    status = newStatus;
    notifyListeners();
  }

  void _scrollToCurrent() {
    if (currentIndex >= 0 && currentIndex < wordPairs.length) {
      scrollController.animateTo(
        currentIndex * 50.0, // Assuming each item has a height of 50.0
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> speak(String text, String language) async {
    await flutterTts.setLanguage(language);
    await flutterTts.setSpeechRate(speed);
    await flutterTts.speak(text);
  }

  Future<void> startPlayback() async {
    if (isPlaying) return;
    isPlaying = true;
    notifyListeners();

    parseVocabulary();
    if (wordPairs.isEmpty) {
      stopPlayback();
      return;
    }

    for (int i = 0; i < wordPairs.length; i++) {
      if (!isPlaying) break;
      currentIndex = i;
      _scrollToCurrent();
      for (int j = 0; j < repetitions; j++) {
        if (!isPlaying) break;
        currentRep = j + 1;
        _updateStatus(
          'Word ${i + 1}/${wordPairs.length} | Speaking "${wordPairs[i].korean}" (Repetition ${j + 1}/$repetitions)',
        );
        await speak(wordPairs[i].korean, 'ko-KR');
        if (speakEnglish) {
          await speak(wordPairs[i].english, 'en-US');
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    stopPlayback();
  }

  Future<void> shufflePlayback() async {
    if (isPlaying) return;
    isPlaying = true;
    notifyListeners();

    parseVocabulary();
    if (wordPairs.isEmpty) {
      stopPlayback();
      return;
    }

    List<WordPair> shuffledList = [];
    for (var pair in wordPairs) {
      for (int i = 0; i < shuffleReps; i++) {
        shuffledList.add(pair);
      }
    }
    shuffledList.shuffle();

    for (int i = 0; i < shuffledList.length; i++) {
      if (!isPlaying) break;
      final originalIndex = wordPairs.indexOf(shuffledList[i]);
      currentIndex = originalIndex;
      _scrollToCurrent();
      _updateStatus(
        'Word ${i + 1}/${shuffledList.length} | Speaking "${shuffledList[i].korean}"',
      );
      await speak(shuffledList[i].korean, 'ko-KR');
      if (speakEnglish) {
        await speak(shuffledList[i].english, 'en-US');
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    stopPlayback();
  }

  void stopPlayback() {
    isPlaying = false;
    currentIndex = -1;
    currentRep = 0;
    status = 'Ready';
    flutterTts.stop();
    notifyListeners();
  }
}
