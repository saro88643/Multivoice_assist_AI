import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = "Auto";

  String get language => _language;

  void changeLanguage(String value) {
    _language = value;
    notifyListeners();
  }
}
