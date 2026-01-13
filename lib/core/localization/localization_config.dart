import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import '../../generated/l10n/app_localizations.dart';

/// Localization configuration for the app
class LocalizationConfig {
  static const List<Locale> supportedLocales = [
    Locale('fr', ''), // French
    Locale('en', ''), // English
  ];

  static const Locale defaultLocale = Locale('fr', '');

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static List<Locale> localeResolutionCallback(
    List<Locale>? locales,
    Iterable<Locale> supportedLocales,
  ) {
    if (locales == null || locales.isEmpty) {
      return [defaultLocale];
    }

    for (final locale in locales) {
      for (final supportedLocale in supportedLocales) {
        if (locale.languageCode == supportedLocale.languageCode) {
          return [locale];
        }
      }
    }

    return [defaultLocale];
  }
}

/// Extension to get localized strings easily
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Utility class for date formatting
class DateFormatter {
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    return DateFormat.yMMMd(locale.languageCode).format(date);
  }

  static String formatDateTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context);
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  static String formatTime(BuildContext context, DateTime time) {
    final locale = Localizations.localeOf(context);
    return DateFormat.jm(locale.languageCode).format(time);
  }
}