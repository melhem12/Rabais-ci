import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            const Icon(
              Icons.local_offer,
              size: 100,
              color: Color(0xFF1976D2),
            ),
            const SizedBox(height: 32),
            const Text(
              'Bienvenue sur RABAIS CI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Choisissez votre rôle pour continuer',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildRoleCard(
              title: 'Je suis client',
              subtitle: 'Achetez des bons de réduction',
              icon: Icons.person,
              role: 'customer',
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              title: 'Je suis commerçant',
              subtitle: 'Échangez des bons de réduction',
              icon: Icons.store,
              role: 'merchant',
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedRole != null ? _continue : null,
                child: const Text('Continuer'),
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
    
    return Card(
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: const Color(0xFF1976D2), width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? const Color(0xFF1976D2) : Colors.grey,
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
                        color: isSelected ? const Color(0xFF1976D2) : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF1976D2),
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