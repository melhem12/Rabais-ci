import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Localization states
abstract class LocalizationState extends Equatable {
  const LocalizationState();

  @override
  List<Object?> get props => [];
}

class LocalizationInitial extends LocalizationState {}

class LocalizationLoaded extends LocalizationState {
  final Locale locale;
  final String languageCode;

  const LocalizationLoaded({
    required this.locale,
    required this.languageCode,
  });

  @override
  List<Object?> get props => [locale, languageCode];
}

class LocalizationError extends LocalizationState {
  final String message;

  const LocalizationError(this.message);

  @override
  List<Object?> get props => [message];
}











