import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/localization_service.dart';
import 'localization_event.dart';
import 'localization_state.dart';

/// Localization BLoC
class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  LocalizationBloc() : super(LocalizationInitial()) {
    on<LoadLanguageEvent>(_onLoadLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onLoadLanguage(LoadLanguageEvent event, Emitter<LocalizationState> emit) async {
    try {
      final languageCode = await LocalizationService.getCurrentLanguage();
      final locale = Locale(languageCode);
      print('LocalizationBloc: Loaded language: $languageCode');
      emit(LocalizationLoaded(locale: locale, languageCode: languageCode));
    } catch (e) {
      print('LocalizationBloc: Error loading language: $e');
      emit(LocalizationError('Failed to load language: $e'));
    }
  }

  Future<void> _onChangeLanguage(ChangeLanguageEvent event, Emitter<LocalizationState> emit) async {
    try {
      print('LocalizationBloc: Changing language to: ${event.languageCode}');
      await LocalizationService.setLanguage(event.languageCode);
      final locale = Locale(event.languageCode);
      emit(LocalizationLoaded(locale: locale, languageCode: event.languageCode));
      print('LocalizationBloc: Language changed successfully to: ${event.languageCode}');
    } catch (e) {
      print('LocalizationBloc: Error changing language: $e');
      emit(LocalizationError('Failed to change language: $e'));
    }
  }
}
