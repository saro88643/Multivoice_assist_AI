import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/history_model.dart';

class HistoryProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  final List<HistoryModel> _historyList = [];

  List<HistoryModel> get historyList => List.unmodifiable(_historyList);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final List<HistoryModel> chats = await _databaseHelper.getAllChats();

      _historyList
        ..clear()
        ..addAll(chats);

      debugPrint('History loaded: ${_historyList.length}');
    } catch (e) {
      debugPrint('History load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveChat({
    required String question,
    required String answer,
  }) async {
    final String cleanQuestion = question.trim();
    final String cleanAnswer = answer.trim();

    if (cleanQuestion.isEmpty || cleanAnswer.isEmpty) {
      return false;
    }

    try {
      final HistoryModel history = HistoryModel(
        question: cleanQuestion,
        answer: cleanAnswer,
        dateTime: DateTime.now().toIso8601String(),
      );

      await _databaseHelper.insertChat(history);

      await _reloadHistory();

      debugPrint('Chat saved successfully.');

      return true;
    } catch (e) {
      debugPrint('History save error: $e');

      return false;
    }
  }

  Future<bool> saveMessage({
    required String userMessage,
    required String aiResponse,
  }) async {
    return saveChat(question: userMessage, answer: aiResponse);
  }

  Future<bool> deleteChat(int id) async {
    try {
      await _databaseHelper.deleteChat(id);

      await _reloadHistory();

      return true;
    } catch (e) {
      debugPrint('Delete chat error: $e');

      return false;
    }
  }

  Future<bool> deleteAllChats() async {
    try {
      await _databaseHelper.deleteAllChats();

      _historyList.clear();

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Delete all error: $e');

      return false;
    }
  }

  void clearLocalHistory() {
    _historyList.clear();

    notifyListeners();
  }

  Future<void> _reloadHistory() async {
    try {
      final List<HistoryModel> chats = await _databaseHelper.getAllChats();

      _historyList
        ..clear()
        ..addAll(chats);

      notifyListeners();
    } catch (e) {
      debugPrint('History reload error: $e');
    }
  }
}
