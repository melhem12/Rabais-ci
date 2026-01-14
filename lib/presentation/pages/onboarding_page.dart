import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/slide_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';
import '../../core/theme/app_theme.dart';

/// Onboarding page for role selection
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RABAIS CI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideInWidget(
              begin: const Offset(0, -0.3),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryOrange,
                      AppTheme.primaryTurquoise,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SlideInWidget(
              begin: const Offset(-0.3, 0),
              child: Text(
                'Bienvenue sur RABAIS CI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            FadeInWidget(
              delay: 0.1,
              child: Text(
                'Choisissez votre rôle pour continuer',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            FadeInWidget(
              delay: 0.2,
              child: _buildRoleCard(
                title: 'Je suis client',
                subtitle: 'Achetez des bons de réduction',
                icon: Icons.person,
                role: 'customer',
              ),
            ),
            const SizedBox(height: 16),
            FadeInWidget(
              delay: 0.3,
              child: _buildRoleCard(
                title: 'Je suis commerçant',
                subtitle: 'Échangez des bons de réduction',
                icon: Icons.store,
                role: 'merchant',
              ),
            ),
            const SizedBox(height: 48),
            FadeInWidget(
              delay: 0.4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryOrange,
                      AppTheme.primaryTurquoise,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String role,
  }) {
    final isSelected = _selectedRole == role;
    
    return ScaleTapWidget(
      onTap: () => setState(() => _selectedRole = role),
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryOrange.withValues(alpha: 0.15),
                      AppTheme.primaryTurquoise.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: isSelected
                ? Border.all(color: AppTheme.primaryOrange, width: 2)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryOrange,
                            AppTheme.primaryTurquoise,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.primaryOrange : AppTheme.navyBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange,
                        AppTheme.primaryTurquoise,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _continue() {
    if (_selectedRole == 'customer') {
      context.go('/login?role=customer');
    } else if (_selectedRole == 'merchant') {
      context.go('/login?role=merchant');
    }
  }
}