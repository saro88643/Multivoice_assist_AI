import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class TTSService extends ChangeNotifier {
  // ============================================================
  // AUDIO PLAYER
  // ============================================================

  final AudioPlayer _audioPlayer = AudioPlayer();

  // ============================================================
  // STATE
  // ============================================================

  bool _isSpeaking = false;
  bool _isPaused = false;

  String? _currentAudioPath;

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isSpeaking => _isSpeaking;

  bool get isPaused => _isPaused;

  bool get isPlaying => _audioPlayer.playing;

  String? get currentAudioPath => _currentAudioPath;

  Duration get position => _audioPlayer.position;

  Duration? get duration => _audioPlayer.duration;

  bool get isCompleted {
    return _audioPlayer.processingState == ProcessingState.completed;
  }

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  TTSService() {
    _initialize();
  }

  // ============================================================
  // INITIALIZE AUDIO PLAYER
  // ============================================================

  void _initialize() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isSpeaking = false;
        _isPaused = false;

        notifyListeners();
      } else if (state.playing) {
        _isSpeaking = true;
        _isPaused = false;

        notifyListeners();
      }
    });

    _audioPlayer.positionStream.listen((_) {
      notifyListeners();
    });
  }

  // ============================================================
  // PLAY AUDIO FILE
  // ============================================================

  Future<void> speakAudioFile(String audioFilePath) async {
    final path = audioFilePath.trim();

    if (path.isEmpty) {
      debugPrint('Audio path is empty.');
      return;
    }

    try {
      final file = File(path);

      if (!await file.exists()) {
        debugPrint('Audio file does not exist: $path');
        return;
      }

      // Stop previous audio.
      await _audioPlayer.stop();

      // Save current audio path.
      _currentAudioPath = path;

      // Load audio file.
      await _audioPlayer.setFilePath(path);

      _isSpeaking = true;
      _isPaused = false;

      notifyListeners();

      // Play audio.
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('TTS playback error: $e');

      _isSpeaking = false;
      _isPaused = false;

      notifyListeners();
    }
  }

  // ============================================================
  // PAUSE
  // ============================================================

  Future<void> pause() async {
    if (!_audioPlayer.playing) {
      return;
    }

    try {
      await _audioPlayer.pause();

      _isSpeaking = false;
      _isPaused = true;

      notifyListeners();
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }

  // ============================================================
  // RESUME
  // ============================================================

  Future<void> resume() async {
    if (_currentAudioPath == null) {
      return;
    }

    try {
      // If audio finished, start again from beginning.
      if (_audioPlayer.processingState == ProcessingState.completed) {
        await _audioPlayer.seek(Duration.zero);
      }

      _isSpeaking = true;
      _isPaused = false;

      notifyListeners();

      await _audioPlayer.play();
    } catch (e) {
      debugPrint('TTS resume error: $e');

      _isSpeaking = false;
      _isPaused = false;

      notifyListeners();
    }
  }

  // ============================================================
  // STOP
  // ============================================================

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();

      _isSpeaking = false;
      _isPaused = false;

      _currentAudioPath = null;

      notifyListeners();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  // ============================================================
  // TOGGLE PLAY / PAUSE
  // ============================================================

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
      return;
    }

    if (_isPaused) {
      await resume();
      return;
    }

    if (_currentAudioPath != null) {
      await resume();
    }
  }

  // ============================================================
  // SEEK
  // ============================================================

  Future<void> seek(Duration newPosition) async {
    try {
      await _audioPlayer.seek(newPosition);

      notifyListeners();
    } catch (e) {
      debugPrint('TTS seek error: $e');
    }
  }

  // ============================================================
  // FORWARD 10 SECONDS
  // ============================================================

  Future<void> forward10Seconds() async {
    try {
      final currentPosition = _audioPlayer.position;
      final totalDuration = _audioPlayer.duration;

      if (totalDuration == null) {
        return;
      }

      Duration newPosition = currentPosition + const Duration(seconds: 10);

      if (newPosition > totalDuration) {
        newPosition = totalDuration;
      }

      await _audioPlayer.seek(newPosition);

      notifyListeners();
    } catch (e) {
      debugPrint('Forward error: $e');
    }
  }

  // ============================================================
  // BACKWARD 10 SECONDS
  // ============================================================

  Future<void> backward10Seconds() async {
    try {
      final currentPosition = _audioPlayer.position;

      Duration newPosition = currentPosition - const Duration(seconds: 10);

      if (newPosition < Duration.zero) {
        newPosition = Duration.zero;
      }

      await _audioPlayer.seek(newPosition);

      notifyListeners();
    } catch (e) {
      debugPrint('Backward error: $e');
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _audioPlayer.dispose();

    super.dispose();
  }
}
