import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../di/service_locator.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../widgets/animations/custom_loader.dart';
import '../../widgets/animations/fade_in_widget.dart';
import '../../widgets/animations/slide_in_widget.dart';

// Phone + password login screens:
// - CreatePasswordPage: after the first SMS-code login (or "forgot password")
// - PasswordLoginPage: next logins, instead of an SMS code
// - ChangePasswordPage: Settings → Compte (current password required)

/// Same rules as the backend (services/phone_password.py).
class PasswordRules {
  static bool length(String p) => p.length >= 8;
  static bool letter(String p) => RegExp(r'[A-Za-z]').hasMatch(p);
  static bool digit(String p) => RegExp(r'\d').hasMatch(p);
  static bool valid(String p) => length(p) && letter(p) && digit(p);
}

String _phoneLabel(String phone) {
  final m = RegExp(r'^\+225(\d{10})$').firstMatch(phone);
  if (m == null) return phone;
  final d = m.group(1)!;
  return '+225 ${[for (var i = 0; i < 10; i += 2) d.substring(i, i + 2)].join(' ')}';
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
}

/// Gradient icon, title and subtitle at the top of each password screen.
class _Header extends StatelessWidget {
  const _Header({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideInWidget(
          begin: const Offset(0, -0.3),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryOrange, AppTheme.primaryTurquoise],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        FadeInWidget(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryOrange,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInWidget(
          delay: 0.1,
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
          ),
        ),
      ],
    );
  }
}

/// Password input with a show/hide toggle.
class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      autofocus: widget.autofocus,
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryTurquoise, width: 2),
        ),
      ),
    );
  }
}

/// Live checklist of the password rules.
class _RulesChecklist extends StatelessWidget {
  const _RulesChecklist({required this.password, this.confirm});

  final String password;
  final String? confirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rules = <(String, bool)>[
      (l10n.passwordRuleLength, PasswordRules.length(password)),
      (l10n.passwordRuleLetter, PasswordRules.letter(password)),
      (l10n.passwordRuleDigit, PasswordRules.digit(password)),
      if (confirm != null) (l10n.passwordRuleMatch, password.isNotEmpty && password == confirm),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          for (final (label, ok) in rules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(ok),
                      size: 20,
                      color: ok ? Colors.green.shade600 : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: ok ? Colors.green.shade800 : Colors.grey.shade700,
                        fontWeight: ok ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-width gradient button with a loading state.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed, this.loading = false});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled || loading ? 1 : 0.5,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primaryOrange, AppTheme.primaryTurquoise]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: loading
              ? const AppLoader(size: 20, color: Colors.white)
              : Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.shield_outlined, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppLocalizations.of(context).passwordSecurityNote,
            style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.35),
          ),
        ),
      ],
    );
  }
}

Widget _page({required Widget child}) {
  return SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: child),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------

/// After the first SMS-code login, or after "forgot password" ([isReset]).
class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key, this.isReset = false});

  final bool isReset;

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _canSubmit => PasswordRules.valid(_password.text) && _password.text == _confirm.text;

  void _submit() {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(SetPasswordEvent(_password.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.isReset ? l10n.resetPasswordTitle : l10n.createPasswordTitle),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) _showError(context, state.message);
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return _page(
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    icon: widget.isReset ? Icons.lock_reset_rounded : Icons.lock_rounded,
                    title: widget.isReset ? l10n.resetPasswordTitle : l10n.createPasswordTitle,
                    subtitle: widget.isReset ? l10n.resetPasswordSubtitle : l10n.createPasswordSubtitle,
                  ),
                  const SizedBox(height: 28),
                  _PasswordField(
                    controller: _password,
                    label: l10n.newPasswordLabel,
                    autofocus: true,
                    autofillHints: const [AutofillHints.newPassword],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: _confirm,
                    label: l10n.confirmPasswordLabel,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 14),
                  _RulesChecklist(password: _password.text, confirm: _confirm.text),
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: l10n.savePasswordButton,
                    loading: loading,
                    onPressed: _canSubmit ? _submit : null,
                  ),
                  const SizedBox(height: 20),
                  const _SecurityNote(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Login for accounts that have a password (no SMS code).
class PasswordLoginPage extends StatefulWidget {
  const PasswordLoginPage({super.key, required this.phone});

  final String phone;

  @override
  State<PasswordLoginPage> createState() => _PasswordLoginPageState();
}

class _PasswordLoginPageState extends State<PasswordLoginPage> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (_password.text.isEmpty) {
      _showError(context, l10n.passwordRequired);
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(LoginWithPasswordEvent(widget.phone, _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<AuthBloc>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) bloc.add(const BackToPhoneEvent());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => bloc.add(const BackToPhoneEvent()),
          ),
          title: Text(l10n.login),
          centerTitle: true,
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              // Keep the text so the user can fix it; select it so typing replaces it.
              _password.selection = TextSelection(baseOffset: 0, extentOffset: _password.text.length);
              _showError(context, state.message);
            }
          },
          builder: (context, state) {
            final loading = state is AuthLoading;
            return _page(
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      icon: Icons.lock_open_rounded,
                      title: l10n.passwordLoginTitle,
                      subtitle: l10n.passwordLoginSubtitle(_phoneLabel(widget.phone)),
                    ),
                    const SizedBox(height: 28),
                    _PasswordField(
                      controller: _password,
                      label: l10n.passwordLabel,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: loading
                            ? null
                            : () => bloc.add(RequestOtpEvent(widget.phone, forceOtp: true)),
                        child: Text(l10n.forgotPasswordLink),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PrimaryButton(label: l10n.signInButton, loading: loading, onPressed: _submit),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: loading ? null : () => bloc.add(const BackToPhoneEvent()),
                      icon: const Icon(Icons.phone_iphone_rounded, size: 18),
                      label: Text(l10n.changePhoneNumberLink),
                    ),
                    const SizedBox(height: 12),
                    const _SecurityNote(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Settings → Compte → Changer le mot de passe. Signs out everywhere afterwards.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _current.text.isNotEmpty && PasswordRules.valid(_password.text) && _password.text == _confirm.text;

  Future<void> _submit() async {
    if (!_canSubmit || _loading) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final bloc = context.read<AuthBloc>();
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await getIt<AuthRepositoryImpl>().changePassword(_current.text, _password.text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(context, e is ServerFailure ? e.message : e.toString());
      return;
    }
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(l10n.passwordChangedRelogin),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
    // The server signed this account out everywhere: back to the login page.
    bloc.add(const LogoutEvent());
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle), centerTitle: true),
      body: _page(
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                icon: Icons.password_rounded,
                title: l10n.changePasswordTitle,
                subtitle: l10n.changePasswordInfo,
              ),
              const SizedBox(height: 28),
              _PasswordField(
                controller: _current,
                label: l10n.currentPasswordLabel,
                autofocus: true,
                autofillHints: const [AutofillHints.password],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              _PasswordField(
                controller: _password,
                label: l10n.newPasswordLabel,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              _PasswordField(
                controller: _confirm,
                label: l10n.confirmPasswordLabel,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 14),
              _RulesChecklist(password: _password.text, confirm: _confirm.text),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: l10n.changePasswordButton,
                loading: _loading,
                onPressed: _canSubmit ? _submit : null,
              ),
              const SizedBox(height: 20),
              const _SecurityNote(),
            ],
          ),
        ),
      ),
    );
  }
}
