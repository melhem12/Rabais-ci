import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../widgets/animations/custom_loader.dart';
import '../../widgets/common/app_widgets.dart';
import '../../widgets/animations/fade_in_widget.dart';
import '../../widgets/animations/slide_in_widget.dart';
import '../../widgets/animations/scale_tap_widget.dart';
import '../../../core/theme/app_theme.dart';

/// Professional registration page with responsive design
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedRole = 'customer';
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    // Get role from query parameters
    final uri = GoRouterState.of(context).uri;
    final role = uri.queryParameters['role'];
    if (role != null && ['customer', 'merchant'].contains(role)) {
      _selectedRole = role;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpVerificationRequired) {
              context.go('/otp-verification');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(context),
                
                const SizedBox(height: 32),
                
                // Registration form
                _buildRegistrationForm(context),
                
                const SizedBox(height: 24),
                
                // Login link
                _buildLoginLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        SlideInWidget(
          begin: const Offset(0, -0.3),
          child: Container(
            padding: const EdgeInsets.all(20),
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
              Icons.person_add,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SlideInWidget(
          begin: const Offset(-0.3, 0),
          child: Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryOrange,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInWidget(
          delay: 0.1,
          child: Text(
            'Rejoignez RABAIS CI et commencez à économiser',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Role selection
          _buildRoleSelection(context),
          const SizedBox(height: 24),
          
          // Personal information
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  labelText: 'Prénom',
                  hintText: 'Votre prénom',
                  controller: _firstNameController,
                  prefixIcon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  labelText: 'Nom',
                  hintText: 'Votre nom',
                  controller: _lastNameController,
                  prefixIcon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          AppTextField(
            labelText: 'Email',
            hintText: 'votre.email@exemple.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          AppTextField(
            labelText: 'Téléphone',
            hintText: '+225 XX XX XX XX',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de téléphone';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          AppTextField(
            labelText: 'Mot de passe',
            hintText: 'Au moins 8 caractères',
            controller: _passwordController,
            obscureText: true,
            prefixIcon: Icons.lock_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              if (value.length < 8) {
                return 'Le mot de passe doit contenir au moins 8 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          AppTextField(
            labelText: 'Confirmer le mot de passe',
            hintText: 'Répétez votre mot de passe',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer votre mot de passe';
              }
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Terms acceptance
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'J\'accepte les '),
                      TextSpan(
                        text: 'conditions d\'utilisation',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' et la '),
                      TextSpan(
                        text: 'politique de confidentialité',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Register button
          FadeInWidget(
            delay: 0.5,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return Container(
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
                    onPressed: _acceptTerms && !(state is AuthLoading) ? _handleRegister : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state is AuthLoading
                        ? const AppLoader(size: 20, color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_add, color: Colors.white),
                              const SizedBox(width: 8),
                              const Text(
                                'Créer mon compte',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de compte',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                context,
                'customer',
                'Client',
                'Achetez des bons et économisez',
                Icons.person,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRoleCard(
                context,
                'merchant',
                'Commerçant',
                'Vendez vos bons et services',
                Icons.store,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard(BuildContext context, String role, String title, String subtitle, IconData icon) {
    final isSelected = _selectedRole == role;
    
    return ScaleTapWidget(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
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
          color: isSelected ? null : Colors.white,
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryOrange
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
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
        child: Column(
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
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryOrange : AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous avez déjà un compte? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Se connecter'),
        ),
      ],
    );
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // Registration flow: Request OTP with phone number
      // The backend should handle registration during OTP verification
      final phone = _phoneController.text.trim();
      if (phone.isNotEmpty) {
        context.read<AuthBloc>().add(RequestOtpEvent(phone));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez entrer un numéro de téléphone'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
