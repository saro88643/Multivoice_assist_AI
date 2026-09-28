import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  // ============================================================
  // DEFAULT LOGIN DETAILS (FALLBACK)
  // ============================================================

  static const String defaultEmail = 'admin@gmail.com';

  static const String defaultPassword = 'admin123';

  // ============================================================
  // LOGIN STATE
  // ============================================================

  bool _isLoggedIn = false;

  String? _loggedInEmail;

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isLoggedIn => _isLoggedIn;

  String? get loggedInEmail => _loggedInEmail;

  // ============================================================
  // LOGIN
  // ============================================================

  Future<bool> login({required String email, required String password}) async {
    final String enteredEmail = email.trim().toLowerCase();

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get stored credentials
    final String? storedEmail = prefs.getString('user_email');
    final String? storedPassword = prefs.getString('user_password');

    bool isCorrect = false;

    // Check against stored credentials first
    if (storedEmail != null && storedPassword != null) {
      if (enteredEmail == storedEmail.toLowerCase() && password == storedPassword) {
        isCorrect = true;
      }
    }

    // Fallback to default admin account if not registered
    if (!isCorrect) {
      if (enteredEmail == defaultEmail.toLowerCase() && password == defaultPassword) {
        isCorrect = true;
      }
    }

    if (isCorrect) {
      _isLoggedIn = true;
      _loggedInEmail = enteredEmail;

      notifyListeners();

      debugPrint('================================');
      debugPrint('LOGIN SUCCESS');
      debugPrint('Email: $enteredEmail');
      debugPrint('================================');

      return true;
    }

    debugPrint('================================');
    debugPrint('LOGIN FAILED');
    debugPrint('Email: $enteredEmail');
    debugPrint('================================');

    return false;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void logout() {
    _isLoggedIn = false;
    _loggedInEmail = null;

    notifyListeners();

    debugPrint('User logged out.');
  }
}
