import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TTSApiService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/audio/speech';

  static const String _englishModel = 'canopylabs/orpheus-v1-english';

  static const String _arabicModel = 'canopylabs/orpheus-arabic-saudi';

  String get _apiKey {
    return dotenv.env['GROQ_API_KEY']?.trim() ?? '';
  }

  bool get hasApiKey => _apiKey.isNotEmpty;

  // ============================================================
  // GENERATE SPEECH
  // ============================================================

  Future<String?> generateSpeech({
    required String text,
    String language = 'en-US',
    String? voice,
  }) async {
    final String cleanText = text.trim();

    if (cleanText.isEmpty) {
      debugPrint('TTS ERROR: Text is empty.');
      return null;
    }

    if (!hasApiKey) {
      debugPrint('TTS ERROR: GROQ_API_KEY missing.');
      return null;
    }

    try {
      // ----------------------------------------------------------
      // Detect language
      // ----------------------------------------------------------

      final String languageCode = language.toLowerCase().split('-').first;

      final bool isArabic = languageCode == 'ar';

      final String model = isArabic ? _arabicModel : _englishModel;

      // ----------------------------------------------------------
      // Select voice
      // ----------------------------------------------------------

      final String selectedVoice = voice ?? (isArabic ? 'noura' : 'hannah');

      // ----------------------------------------------------------
      // Groq Orpheus maximum input = 200 characters
      // ----------------------------------------------------------

      String inputText = cleanText;

      if (inputText.length > 200) {
        inputText = inputText.substring(0, 200);

        debugPrint(
          'TTS: Text was longer than 200 characters.'
          ' Using first 200 characters.',
        );
      }

      // ----------------------------------------------------------
      // Request body
      // ----------------------------------------------------------

      final Map<String, dynamic> body = {
        'model': model,
        'input': inputText,
        'voice': selectedVoice,
        'response_format': 'wav',
      };

      debugPrint('========================================');
      debugPrint('TTS REQUEST');
      debugPrint('Model: $model');
      debugPrint('Voice: $selectedVoice');
      debugPrint('Language: $language');
      debugPrint('Text: $inputText');
      debugPrint('========================================');

      // ----------------------------------------------------------
      // API request
      // ----------------------------------------------------------

      final http.Response response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
              'Accept': 'audio/wav',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          debugPrint('TTS ERROR: Groq returned empty audio.');
          return null;
        }

        debugPrint(
          'TTS SUCCESS: Received '
          '${response.bodyBytes.length} bytes.',
        );

        final String? filePath = await _saveAudioFile(response.bodyBytes);

        return filePath;
      }

      // ----------------------------------------------------------
      // API ERROR
      // ----------------------------------------------------------

      debugPrint('========================================');
      debugPrint('TTS API ERROR');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');
      debugPrint('========================================');

      return null;
    } on SocketException catch (e) {
      debugPrint('TTS NETWORK ERROR: $e');
      return null;
    } on HttpException catch (e) {
      debugPrint('TTS HTTP ERROR: $e');
      return null;
    } on FormatException catch (e) {
      debugPrint('TTS FORMAT ERROR: $e');
      return null;
    } on Exception catch (e) {
      debugPrint('TTS EXCEPTION: $e');
      return null;
    } catch (e) {
      debugPrint('TTS UNKNOWN ERROR: $e');
      return null;
    }
  }

  // ============================================================
  // SAVE AUDIO
  // ============================================================

  Future<String?> _saveAudioFile(List<int> audioBytes) async {
    try {
      final Directory directory = await getTemporaryDirectory();

      final String fileName =
          'multivoice_tts_${DateTime.now().millisecondsSinceEpoch}.wav';

      final String filePath = '${directory.path}/$fileName';

      final File audioFile = File(filePath);

      await audioFile.writeAsBytes(audioBytes, flush: true);

      if (!await audioFile.exists()) {
        debugPrint('TTS ERROR: Audio file does not exist.');
        return null;
      }

      final int size = await audioFile.length();

      if (size <= 0) {
        debugPrint('TTS ERROR: Audio file is empty.');
        return null;
      }

      debugPrint('========================================');
      debugPrint('TTS AUDIO CREATED');
      debugPrint('File: $filePath');
      debugPrint('Size: $size bytes');
      debugPrint('========================================');

      return filePath;
    } catch (e) {
      debugPrint('TTS FILE SAVE ERROR: $e');
      return null;
    }
  }

  // ============================================================
  // DELETE AUDIO
  // ============================================================

  Future<void> deleteAudioFile(String filePath) async {
    try {
      final File file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('TTS DELETE ERROR: $e');
    }
  }

  // ============================================================
  // CLEAR OLD AUDIO
  // ============================================================

  Future<void> clearOldAudioFiles() async {
    try {
      final Directory directory = await getTemporaryDirectory();

      if (!await directory.exists()) {
        return;
      }

      final List<FileSystemEntity> files = directory.listSync();

      for (final FileSystemEntity entity in files) {
        if (entity is File &&
            entity.path.contains('multivoice_tts_') &&
            entity.path.endsWith('.wav')) {
          try {
            await entity.delete();
          } catch (e) {
            debugPrint('Could not delete TTS file: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('TTS CLEANUP ERROR: $e');
    }
  }

  // ============================================================
  // TEST CONNECTION
  // ============================================================

  Future<bool> testConnection() async {
    if (!hasApiKey) {
      debugPrint('TTS TEST FAILED: GROQ_API_KEY missing.');
      return false;
    }

    final String? filePath = await generateSpeech(
      text: 'Hello. This is MultiVoice Assist.',
      language: 'en-US',
      voice: 'hannah',
    );

    if (filePath == null) {
      debugPrint('TTS TEST FAILED.');
      return false;
    }

    debugPrint('TTS TEST SUCCESS: $filePath');

    return true;
  }
}
