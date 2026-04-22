import 'package:shared_preferences/shared_preferences.dart';

import 'configurations.dart';

class Utility {
  static bool validateEmail(String text) {
    return RegExp(
      r"^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*@[a-zA-Z0-9]+(\.[a-zA-Z]{2,4}){1,2}$",
    ).hasMatch(text);
  }

  static bool validateCredentials({required String userId, String? password}) {
    if (password == null) {
      for (var entry in Configurations.credentials) {
        if (entry['userid'] == userId) {
          return true;
        }
      }
      return false;
    } else {
      for (var entry in Configurations.credentials) {
        if (entry['userid'] == userId && entry['password'] == password) {
          return true;
        }
      }
      return false;
    }
  }

  static bool validatePasswordLength(String text) {
    return text.length > 3;
  }

  static bool validateLowerCase(String text) {
    return RegExp(r"[a-z]").hasMatch(text);
  }

  static bool validateUpperCase(String text) {
    return RegExp(r"[A-Z]").hasMatch(text);
  }

  static bool validateDigit(String text) {
    return RegExp(r"[0-9]").hasMatch(text);
  }

  static bool validateSymbol(String text) {
    return RegExp(r"[!@#$^_]").hasMatch(text);
  }

  static bool validatePassword(String text) {
    return validatePasswordLength(text) &&
        validateLowerCase(text) &&
        validateUpperCase(text) &&
        validateDigit(text) &&
        validateSymbol(text);
  }

  static bool validateUniqueUserId(String userId) {
    final normalizedUserId = userId.trim().toLowerCase();
    for (var entry in Configurations.credentials) {
      final savedUserId = entry['userid']?.trim().toLowerCase();
      if (savedUserId == normalizedUserId) {
        return false;
      }
    }
    return true;
  }

  // SharedPreferences methods
  static const String _userIDKey = 'saved_user_id';

  static Future<void> saveUserID(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIDKey, userID);
  }

  static Future<String?> getSavedUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIDKey);
  }
}
