import 'package:equatable/equatable.dart';

/// Localization events
abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLanguageEvent extends LocalizationEvent {
  const LoadLanguageEvent();
}

class ChangeLanguageEvent extends LocalizationEvent {
  final String languageCode;

  const ChangeLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}











