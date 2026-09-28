import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioTtsService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  bool _isSpeaking = false;
  bool _isPaused = false;
  bool _isLoading = false;

  String? _currentAudioPath;

  bool get isSpeaking => _isSpeaking;

  bool get isPaused => _isPaused;

  bool get isLoading => _isLoading;

  String? get currentAudioPath => _currentAudioPath;

  AudioTtsService() {
    _listenToPlayer();
  }

  void _listenToPlayer() {
    _player.playerStateStream.listen((PlayerState state) {
      if (state.processingState == ProcessingState.completed) {
        _isSpeaking = false;
        _isPaused = false;
        _isLoading = false;

        notifyListeners();
      }
    });
  }

  Future<void> speak(String text) async {
    final String cleanText = text.trim();

    if (cleanText.isEmpty) {
      return;
    }

    await stop();

    _isLoading = true;
    _isSpeaking = false;
    _isPaused = false;

    notifyListeners();

    try {
      final String apiKey = dotenv.env['OPENAI_API_KEY']?.trim() ?? '';

      if (apiKey.isEmpty) {
        throw Exception(
          'OPENAI_API_KEY is missing. '
          'Add it to your .env file.',
        );
      }

      final http.Response response = await http
          .post(
            Uri.parse('https://api.openai.com/v1/audio/speech'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'gpt-4o-mini-tts',
              'voice': 'alloy',
              'input': cleanText,
              'response_format': 'mp3',
            }),
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('TTS STATUS: ${response.statusCode}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message = 'TTS request failed.';

        try {
          final dynamic data = jsonDecode(response.body);

          if (data is Map<String, dynamic>) {
            final dynamic error = data['error'];

            if (error is Map<String, dynamic>) {
              final dynamic errorMessage = error['message'];

              if (errorMessage != null) {
                message = errorMessage.toString();
              }
            }
          }
        } catch (_) {}

        throw Exception(
          'OpenAI TTS Error '
          '${response.statusCode}: $message',
        );
      }

      final Directory directory = await getTemporaryDirectory();

      final String fileName =
          'multivoice_${DateTime.now().millisecondsSinceEpoch}.mp3';

      final File audioFile = File('${directory.path}/$fileName');

      await audioFile.writeAsBytes(response.bodyBytes, flush: true);

      _currentAudioPath = audioFile.path;

      await _player.setFilePath(audioFile.path);

      _isLoading = false;
      _isSpeaking = true;
      _isPaused = false;

      notifyListeners();

      await _player.play();
    } on TimeoutException {
      _isLoading = false;
      _isSpeaking = false;
      _isPaused = false;

      notifyListeners();

      throw Exception(
        'Voice generation timed out. '
        'Please check your internet connection.',
      );
    } on http.ClientException {
      _isLoading = false;
      _isSpeaking = false;
      _isPaused = false;

      notifyListeners();

      throw Exception('Unable to connect to the voice server.');
    } catch (e) {
      debugPrint('TTS ERROR: $e');

      _isLoading = false;
      _isSpeaking = false;
      _isPaused = false;

      notifyListeners();

      rethrow;
    }
  }

  Future<void> pause() async {
    if (!_isSpeaking) {
      return;
    }

    await _player.pause();

    _isPaused = true;
    _isSpeaking = true;

    notifyListeners();
  }

  Future<void> resume() async {
    if (!_isPaused) {
      return;
    }

    _isPaused = false;
    _isSpeaking = true;

    notifyListeners();

    await _player.play();
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }

    _isSpeaking = false;
    _isPaused = false;
    _isLoading = false;

    notifyListeners();
  }

  Future<void> clearOldAudioFiles() async {
    try {
      final Directory directory = await getTemporaryDirectory();

      if (!await directory.exists()) {
        return;
      }

      final List<FileSystemEntity> files = directory.listSync();

      for (final FileSystemEntity file in files) {
        if (file is File) {
          final String name = file.path.split(Platform.pathSeparator).last;

          if (name.startsWith('multivoice_') && name.endsWith('.mp3')) {
            try {
              await file.delete();
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint('Clear audio error: $e');
    }
  }

  Future<void> deleteCurrentAudio() async {
    final String? path = _currentAudioPath;

    if (path == null || path.isEmpty) {
      return;
    }

    try {
      final File file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Delete audio error: $e');
    }

    _currentAudioPath = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();

    super.dispose();
  }
}
