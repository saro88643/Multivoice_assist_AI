import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GrokService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const String _model = 'openai/gpt-oss-20b';

  String get _apiKey {
    return dotenv.env['GROQ_API_KEY']?.trim() ?? '';
  }

  bool get hasApiKey {
    return _apiKey.isNotEmpty;
  }

  Future<String> sendMessage(String userMessage) async {
    final String question = userMessage.trim();

    if (question.isEmpty) {
      throw Exception('Please enter a message.');
    }

    if (!hasApiKey) {
      throw Exception('GROQ_API_KEY is missing. Check your .env file.');
    }

    try {
      final http.Response response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content': '''
You are MultiVoice Assist, a friendly multilingual AI assistant.

Rules:

1. Detect the language used by the user.
2. Reply in the SAME language.
3. English input -> English response.
4. Tamil input -> Tamil response.
5. Hindi input -> Hindi response.
6. Malayalam input -> Malayalam response.
7. Telugu input -> Telugu response.
8. Kannada input -> Kannada response.
9. For any other language, reply in that same language.
10. Give a useful answer.
11. Do not reveal internal reasoning.
12. Keep answers clear and easy to understand.
13. Use normal plain text.
''',
                },
                {'role': 'user', 'content': question},
              ],
              'include_reasoning': false,
              'max_completion_tokens': 2048,
              'temperature': 0.6,
            }),
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('GROQ STATUS: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _extractResponse(response.body);
      }

      throw Exception(_extractApiError(response.statusCode, response.body));
    } on TimeoutException {
      throw Exception(
        'The AI server took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw Exception(
        'Unable to connect to Groq. Check your internet connection.',
      );
    }
  }

  String _extractResponse(String responseBody) {
    try {
      final dynamic decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid response.');
      }

      final dynamic choices = decoded['choices'];

      if (choices is! List || choices.isEmpty) {
        throw const FormatException('No response from AI.');
      }

      final dynamic firstChoice = choices.first;

      if (firstChoice is! Map<String, dynamic>) {
        throw const FormatException('Invalid choice.');
      }

      final dynamic message = firstChoice['message'];

      if (message is! Map<String, dynamic>) {
        throw const FormatException('Invalid AI message.');
      }

      final dynamic content = message['content'];

      if (content == null) {
        throw const FormatException('AI response is empty.');
      }

      final String answer = content.toString().trim();

      if (answer.isEmpty) {
        throw const FormatException('AI returned an empty response.');
      }

      return _cleanPlainText(answer);
    } catch (e) {
      debugPrint('Response parsing error: $e');

      rethrow;
    }
  }

  String _extractApiError(int statusCode, String responseBody) {
    try {
      final dynamic decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        final dynamic error = decoded['error'];

        if (error is Map<String, dynamic>) {
          final dynamic message = error['message'];

          if (message != null) {
            return 'Groq API Error $statusCode: ${message.toString()}';
          }
        }
      }
    } catch (_) {}

    return 'Groq API Error $statusCode';
  }

  String _cleanPlainText(String text) {
    String result = text;

    result = result.replaceAll('\r\n', '\n');

    result = result.replaceAll('\r', '\n');

    final List<String> lines = result.split('\n');

    final List<String> cleaned = [];

    for (String line in lines) {
      String current = line.trim();

      if (current.isEmpty) {
        continue;
      }

      current = current.replaceFirst(RegExp(r'^#{1,6}\s*'), '');

      current = current.replaceFirst(RegExp(r'^[-*+]\s+'), '');

      current = current.replaceFirst(RegExp(r'^\d+[.)]\s+'), '');

      current = current.replaceAll('**', '');

      current = current.replaceAll('__', '');

      current = current.replaceAll('`', '');

      current = current.replaceFirst(RegExp(r'^>\s?'), '');

      current = current.replaceAll(RegExp(r'[ \t]+'), ' ');

      if (current.isNotEmpty) {
        cleaned.add(current);
      }
    }

    return cleaned.join('\n').trim();
  }
}
