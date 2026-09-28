import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechProvider extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();

  bool _speechEnabled = false;
  bool _isListening = false;

  String _recognizedText = '';

  String? _error;

  bool get speechEnabled => _speechEnabled;

  bool get isListening => _isListening;

  String get recognizedText => _recognizedText;

  String? get error => _error;

  Future<void> startListening() async {
    _error = null;

    try {
      _speechEnabled = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');

          if (status == 'done' || status == 'notListening') {
            _isListening = false;

            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');

          _error = error.errorMsg;

          _isListening = false;

          notifyListeners();
        },
        debugLogging: true,
      );
    } catch (e) {
      _speechEnabled = false;

      _error = e.toString();

      notifyListeners();

      throw Exception('Speech initialization failed: $e');
    }

    if (!_speechEnabled) {
      _error = 'Speech recognition is not available on this device.';

      notifyListeners();

      throw Exception(_error!);
    }

    _recognizedText = '';

    try {
      await _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;

          notifyListeners();

          debugPrint('Recognized: $_recognizedText');
        },
        listenMode: ListenMode.confirmation,
        partialResults: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        cancelOnError: false,
      );

      _isListening = true;

      notifyListeners();
    } catch (e) {
      _isListening = false;

      _error = e.toString();

      notifyListeners();

      throw Exception('Unable to start microphone: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Speech stop error: $e');
    }

    _isListening = false;

    notifyListeners();
  }

  Future<void> cancelListening() async {
    try {
      await _speech.cancel();
    } catch (e) {
      debugPrint('Speech cancel error: $e');
    }

    _isListening = false;

    notifyListeners();
  }

  void clearText() {
    _recognizedText = '';
    _error = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _speech.cancel();

    super.dispose();
  }
}
