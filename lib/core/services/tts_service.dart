import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends ChangeNotifier {
  static final TtsService instance = TtsService._init();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  TtsService._init() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        notifyListeners();
        debugPrint('TTS Error: $msg');
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      // Default settings for Bangla voice
      await _flutterTts.setLanguage('bn-BD');
      await _flutterTts.setSpeechRate(0.45); // Slower speech rate for elderly users
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS Initialization failed: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      if (_isSpeaking) {
        await stop();
      }

      // Try setting language to bn-BD, fallback to bn-IN if needed
      bool isLanguageAvailable = await _flutterTts.isLanguageAvailable('bn-BD') as bool;
      if (!isLanguageAvailable) {
        await _flutterTts.setLanguage('bn-IN'); // Fallback to Indian Bangla
      } else {
        await _flutterTts.setLanguage('bn-BD');
      }

      // Slower pace for clarity
      await _flutterTts.setSpeechRate(0.45);
      
      await _flutterTts.speak(text);
      _isSpeaking = true;
      notifyListeners();
    } catch (e) {
      _isSpeaking = false;
      notifyListeners();
      debugPrint('TTS Speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      debugPrint('TTS Stop error: $e');
    }
  }
}
