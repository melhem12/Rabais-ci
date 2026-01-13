import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/localization/bloc/localization_bloc.dart';
import '../features/localization/bloc/localization_event.dart';
import '../features/localization/bloc/localization_state.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/localized_app.dart';
import 'profile_page.dart';
import 'support_page.dart';
import 'purchases_page.dart';

/// Settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          _buildSectionHeader(context, l10n.profile),
          _buildSettingsTile(
            context,
            icon: Icons.person,
            title: l10n.personalInfo,
            subtitle: l10n.modifyYourInfo,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.local_offer,
            title: 'Mes Coupons', // Will be localized
            subtitle: 'Voir tous vos coupons achetés',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PurchasesPage(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security,
            title: l10n.security,
            subtitle: l10n.passwordAndAuth,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.featureWillBeAvailableSoon),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // App Section
          _buildSectionHeader(context, l10n.application),
          BlocBuilder<LocalizationBloc, LocalizationState>(
            builder: (context, state) {
              String currentLanguage = l10n.french;
              if (state is LocalizationLoaded) {
                currentLanguage = state.languageCode == 'fr' ? l10n.french : l10n.english;
              }
              
              return _buildSettingsTile(
                context,
                icon: Icons.language,
                title: l10n.language,
                subtitle: currentLanguage,
                onTap: () => _showLanguageDialog(context),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: l10n.notifications,
            subtitle: l10n.manageNotifications,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode,
            title: l10n.theme,
            subtitle: l10n.system,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.featureWillBeAvailableSoon),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Support Section
          _buildSectionHeader(context, l10n.support),
          _buildSettingsTile(
            context,
            icon: Icons.help,
            title: l10n.help,
            subtitle: l10n.faqAndSupport,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupportPage(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.contact_support,
            title: l10n.contactUs,
            subtitle: l10n.customerSupport,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupportPage(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info,
            title: l10n.about,
            subtitle: l10n.version,
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Account Section
          _buildSectionHeader(context, l10n.account),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: l10n.logout,
            subtitle: l10n.logoutConfirmationMessage,
            onTap: () => _showLogoutDialog(context),
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'RABAIS CI',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.shopping_bag_outlined,
        size: 48,
        color: Color(0xFF1976D2),
      ),
      children: [
        const Text(
          'RABAIS CI est une application mobile qui permet aux clients de découvrir et d\'acheter des bons de réduction auprès de commerçants locaux.',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmation),
        content: Text(l10n.logoutConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, state) {
          String currentLanguage = 'fr';
          if (state is LocalizationLoaded) {
            currentLanguage = state.languageCode;
          }
          
          return AlertDialog(
            title: Text(l10n.language),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text(l10n.french),
                  value: 'fr',
                  groupValue: currentLanguage,
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.of(context).pop();
                      context.read<LocalizationBloc>().add(ChangeLanguageEvent(value));
                      // Force app restart to apply language change
                      RestartWidget.restartApp(context);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(l10n.english),
                  value: 'en',
                  groupValue: currentLanguage,
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.of(context).pop();
                      context.read<LocalizationBloc>().add(ChangeLanguageEvent(value));
                      // Force app restart to apply language change
                      RestartWidget.restartApp(context);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.ok),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Notifications page
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _promotionalNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Notification Types
          _buildSectionHeader('Types de notifications'),
          _buildSwitchTile(
            'Notifications push',
            'Recevoir des notifications sur votre appareil',
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
          ),
          _buildSwitchTile(
            'Notifications par email',
            'Recevoir des notifications par email',
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
          _buildSwitchTile(
            'Notifications par SMS',
            'Recevoir des notifications par SMS',
            _smsNotifications,
            (value) => setState(() => _smsNotifications = value),
          ),
          
          const SizedBox(height: 24),
          
          // Notification Categories
          _buildSectionHeader('Catégories'),
          _buildSwitchTile(
            'Notifications promotionnelles',
            'Nouveaux bons et offres spéciales',
            _promotionalNotifications,
            (value) => setState(() => _promotionalNotifications = value),
          ),
          _buildSwitchTile(
            'Notifications de transaction',
            'Confirmations d\'achat et de rédemption',
            true,
            (value) {
              // This would be handled by the backend
            },
          ),
          _buildSwitchTile(
            'Notifications de sécurité',
            'Connexions et changements de compte',
            true,
            (value) {
              // This would be handled by the backend
            },
          ),
          
          const SizedBox(height: 24),
          
          // Frequency
          _buildSectionHeader('Fréquence'),
          _buildSettingsTile(
            icon: Icons.schedule,
            title: 'Fréquence des notifications',
            subtitle: 'Immédiatement',
            onTap: () {
              _showFrequencyDialog();
            },
          ),
          
          const SizedBox(height: 24),
          
          // Test Notification
          _buildSectionHeader('Test'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Envoyer une notification de test'),
              subtitle: const Text('Tester vos paramètres de notification'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification de test envoyée!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showFrequencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fréquence des notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Immédiatement'),
              value: 'immediate',
              groupValue: 'immediate',
              onChanged: (value) {
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Quotidiennement'),
              value: 'daily',
              groupValue: 'immediate',
              onChanged: (value) {
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Hebdomadairement'),
              value: 'weekly',
              groupValue: 'immediate',
              onChanged: (value) {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
