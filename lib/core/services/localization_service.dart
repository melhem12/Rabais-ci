import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Localization service for managing app language
class LocalizationService {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'fr';
  
  static const List<Locale> supportedLocales = [
    Locale('fr', ''), // French
    Locale('en', ''), // English
  ];

  /// Get the current language from storage
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  /// Set the current language in storage
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Get the current locale
  static Future<Locale> getCurrentLocale() async {
    final languageCode = await getCurrentLanguage();
    return Locale(languageCode);
  }

  /// Check if the current language is French
  static Future<bool> isFrench() async {
    final language = await getCurrentLanguage();
    return language == 'fr';
  }

  /// Check if the current language is English
  static Future<bool> isEnglish() async {
    final language = await getCurrentLanguage();
    return language == 'en';
  }

  /// Clear the saved language preference (used on logout)
  static Future<void> clearLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageKey);
  }
}




