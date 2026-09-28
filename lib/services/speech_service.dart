import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    try {
      final bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech Status: $status');
        },
        onError: (error) {
          debugPrint('Speech Error: $error');
        },
        debugLogging: true,
      );

      return available;
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      return false;
    }
  }

  Future<void> startListening(Function(String) onResult) async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }

      await _speech.cancel();

      onResult('');

      await _speech.listen(
        onResult: (result) {
          debugPrint('Recognized Words: ${result.recognizedWords}');

          debugPrint('Final Result: ${result.finalResult}');

          onResult(result.recognizedWords);
        },
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Start listening error: $e');
      rethrow;
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();

        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      debugPrint('Stop listening error: $e');
    }
  }

  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } catch (e) {
      debugPrint('Cancel listening error: $e');
    }
  }
}
