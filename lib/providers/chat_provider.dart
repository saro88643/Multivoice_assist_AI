import 'package:flutter/foundation.dart';

import '../models/message_model.dart';
import '../services/grok_service.dart';
import 'history_provider.dart';

class ChatProvider extends ChangeNotifier {
  // ============================================================
  // SERVICES
  // ============================================================

  final GrokService _grokService = GrokService();

  // ============================================================
  // MESSAGES
  // ============================================================

  final List<MessageModel> _messages = [];

  List<MessageModel> get messages => List.unmodifiable(_messages);

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage(
    String text, {
    required HistoryProvider historyProvider,
  }) async {
    final String question = text.trim();

    if (question.isEmpty) {
      return;
    }

    // Prevent multiple requests at the same time.
    if (_isLoading) {
      debugPrint('ChatProvider: Already sending a message.');
      return;
    }

    // Clear previous error.
    _errorMessage = null;

    // ==========================================================
    // ADD USER MESSAGE
    // ==========================================================

    final MessageModel userMessage = MessageModel(
      text: question,
      isUser: true,
      time: DateTime.now(),
    );

    _messages.add(userMessage);

    notifyListeners();

    // ==========================================================
    // START LOADING
    // ==========================================================

    _isLoading = true;

    notifyListeners();

    try {
      debugPrint('========================================');
      debugPrint('Sending to Groq: $question');
      debugPrint('========================================');

      // ========================================================
      // GET AI RESPONSE
      // ========================================================

      final String response = await _grokService.sendMessage(question);

      final String answer = response.trim();

      debugPrint('========================================');
      debugPrint('Groq response received');
      debugPrint('AI response: $answer');
      debugPrint('========================================');

      // ========================================================
      // CHECK EMPTY RESPONSE
      // ========================================================

      if (answer.isEmpty) {
        throw Exception('AI returned an empty response.');
      }

      // ========================================================
      // ADD AI MESSAGE TO CHAT
      // ========================================================

      final MessageModel aiMessage = MessageModel(
        text: answer,
        isUser: false,
        time: DateTime.now(),
      );

      _messages.add(aiMessage);

      // IMPORTANT:
      // Notify ChatScreen immediately.
      // The AI response will now appear even before
      // the history database finishes saving.
      notifyListeners();

      debugPrint('AI message added to chat.');

      // ========================================================
      // SAVE TO HISTORY
      // ========================================================

      try {
        final bool saved = await historyProvider.saveMessage(
          userMessage: question,
          aiResponse: answer,
        );

        debugPrint('History saved: $saved');
      } catch (historyError, historyStack) {
        // History failure should NOT remove the AI response
        // from the current chat.
        debugPrint('HISTORY SAVE ERROR: $historyError');
        debugPrint(historyStack.toString());
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      _errorMessage = null;

      debugPrint('Chat completed successfully.');
    } catch (e, stackTrace) {
      // ========================================================
      // AI ERROR
      // ========================================================

      debugPrint('========================================');
      debugPrint('CHAT PROVIDER ERROR');
      debugPrint('$e');
      debugPrint('========================================');

      debugPrint(stackTrace.toString());

      _errorMessage = e.toString();

      // IMPORTANT:
      // Only add an error message when Groq itself failed.
      //
      // Do NOT add an error message because history saving failed.
      final MessageModel errorMessage = MessageModel(
        text: 'Unable to get AI response. Please try again.',
        isUser: false,
        time: DateTime.now(),
      );

      _messages.add(errorMessage);

      notifyListeners();
    } finally {
      // ========================================================
      // STOP LOADING
      // ========================================================

      _isLoading = false;

      notifyListeners();

      debugPrint('ChatProvider: Loading finished.');
    }
  }

  // ============================================================
  // CLEAR ALL MESSAGES
  // ============================================================

  void clearMessages() {
    _messages.clear();

    _errorMessage = null;

    _isLoading = false;

    notifyListeners();

    debugPrint('ChatProvider: Messages cleared.');
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}
