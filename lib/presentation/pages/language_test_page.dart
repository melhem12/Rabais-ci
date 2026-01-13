import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/l10n/app_localizations.dart';
import '../features/localization/bloc/localization_bloc.dart';
import '../features/localization/bloc/localization_state.dart';
import '../features/localization/bloc/localization_event.dart';
import '../widgets/localized_app.dart';

/// A simple test page to verify language changes
class LanguageTestPage extends StatelessWidget {
  const LanguageTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<LocalizationBloc, LocalizationState>(
              builder: (context, state) {
                String currentLanguage = 'Unknown';
                if (state is LocalizationLoaded) {
                  currentLanguage = state.languageCode;
                }
                
                return Column(
                  children: [
                    Text(
                      'Current Language: $currentLanguage',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Test Text: ${l10n.login}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Settings: ${l10n.settings}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.read<LocalizationBloc>().add(ChangeLanguageEvent('en'));
                // Force app restart to apply language change
                RestartWidget.restartApp(context);
              },
              child: const Text('Switch to English'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<LocalizationBloc>().add(ChangeLanguageEvent('fr'));
                // Force app restart to apply language change
                RestartWidget.restartApp(context);
              },
              child: const Text('Switch to French'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
