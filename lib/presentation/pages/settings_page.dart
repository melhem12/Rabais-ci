import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../features/localization/bloc/localization_bloc.dart';
import '../features/localization/bloc/localization_event.dart';
import '../features/localization/bloc/localization_state.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/localized_app.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/slide_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';
import 'profile_page.dart';
import 'support_page.dart';
import 'purchases_page.dart';

/// Settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String _buildName =
      String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: '1.0.0');
  static const String _buildNumber =
      String.fromEnvironment('FLUTTER_BUILD_NUMBER', defaultValue: '0');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final versionLabel = '$_buildName+$_buildNumber';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          FadeInWidget(
            delay: 0.1,
            child: SlideInWidget(
              delay: 0.1,
              begin: const Offset(-0.2, 0),
              child: _buildSectionHeader(context, l10n.profile),
            ),
          ),
          FadeInWidget(
            delay: 0.15,
            child: _buildSettingsTile(
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
          ),
          FadeInWidget(
            delay: 0.2,
            child: _buildSettingsTile(
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
          ),
          FadeInWidget(
            delay: 0.25,
            child: _buildSettingsTile(
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
          ),
          
          const SizedBox(height: 24),
          
          // App Section
          FadeInWidget(
            delay: 0.3,
            child: SlideInWidget(
              delay: 0.3,
              begin: const Offset(-0.2, 0),
              child: _buildSectionHeader(context, l10n.application),
            ),
          ),
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
          FadeInWidget(
            delay: 0.45,
            child: SlideInWidget(
              delay: 0.45,
              begin: const Offset(-0.2, 0),
              child: _buildSectionHeader(context, l10n.support),
            ),
          ),
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
            subtitle: '${l10n.version} $versionLabel',
            onTap: () {
              _showAboutDialog(context, l10n, versionLabel);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Account Section
          FadeInWidget(
            delay: 0.55,
            child: SlideInWidget(
              delay: 0.55,
              begin: const Offset(-0.2, 0),
              child: _buildSectionHeader(context, l10n.account),
            ),
          ),
          FadeInWidget(
            delay: 0.65,
            child: _buildSettingsTile(
              context,
              icon: Icons.logout,
              title: l10n.logout,
              subtitle: l10n.logoutConfirmationMessage,
              onTap: () => _showLogoutDialog(context),
              textColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
          color: AppTheme.primaryTurquoise,
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
    return ScaleTapWidget(
      onTap: onTap,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppTheme.primaryOrange.withOpacity(0.05),
              ],
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (textColor ?? AppTheme.primaryOrange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: textColor ?? AppTheme.primaryOrange,
                size: 24,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: textColor ?? AppTheme.primaryOrange,
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n, String versionLabel) {
    showAboutDialog(
      context: context,
      applicationName: 'RABAIS CI',
      applicationVersion: versionLabel,
      applicationIcon: const Icon(
        Icons.shopping_bag_outlined,
        size: 48,
        color: Color(0xFF1976D2),
      ),
      children: [
        Text(
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
