import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../../../domain/entities/user.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../widgets/animations/custom_loader.dart';
import '../../widgets/animations/fade_in_widget.dart';
import '../../widgets/animations/slide_in_widget.dart';
import '../../../core/theme/app_theme.dart';

/// OTP verification page
class OtpVerificationPage extends StatefulWidget {
  final String phone;
  final OtpRequestResponse? otpResponse;

  const OtpVerificationPage({
    super.key,
    required this.phone,
    this.otpResponse,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  late String _phone;

  @override
  void initState() {
    super.initState();
    _phone = widget.phone;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.otpVerification),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated || state is ProfileCompletionRequired) {
            // RouterWrapper will swap to the appropriate home/profile page.
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenWidth < 360 || screenHeight < 600;
            final isTablet = screenWidth > 600;
            
            // Responsive sizing
            final iconSize = isSmallScreen ? 60.0 : (isTablet ? 100.0 : 80.0);
            final titleFontSize = isSmallScreen ? 22.0 : (isTablet ? 32.0 : 28.0);
            final subtitleFontSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
            final phoneFontSize = isSmallScreen ? 16.0 : (isTablet ? 20.0 : 18.0);
            final instructionFontSize = isSmallScreen ? 16.0 : (isTablet ? 20.0 : 18.0);
            final otpFieldWidth = isSmallScreen ? 50.0 : (isTablet ? 70.0 : 60.0);
            final horizontalPadding = isSmallScreen ? 16.0 : (isTablet ? 48.0 : 24.0);
            final verticalSpacing = isSmallScreen ? 16.0 : (isTablet ? 32.0 : 24.0);
            final largeSpacing = isSmallScreen ? 32.0 : (isTablet ? 64.0 : 48.0);
            
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isSmallScreen ? 16.0 : 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - kToolbarHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        child: Icon(
                          Icons.sms,
                          size: iconSize * 0.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing),
                    SlideInWidget(
                      begin: const Offset(-0.3, 0),
                      child: Text(
                        l10n.otpVerification,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 4.0 : 8.0),
                    FadeInWidget(
                      delay: 0.1,
                      child: Text(
                        l10n.weSentCodeTo,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2.0 : 4.0),
                    FadeInWidget(
                      delay: 0.2,
                      child: Text(
                        _phone.isNotEmpty ? _phone : 'votre.numero@exemple.com',
                        style: TextStyle(
                          fontSize: phoneFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryOrange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: largeSpacing),
                    Text(
                      l10n.enterFourDigitCode,
                      style: TextStyle(
                        fontSize: instructionFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: verticalSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          width: otpFieldWidth,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18.0 : 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 3) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: largeSpacing),
                    FadeInWidget(
                      delay: 0.5,
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
                          onPressed: _handleVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12.0 : 16.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const AppLoader(size: 20, color: Colors.white);
                              }
                              return Text(
                                l10n.verify,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14.0 : 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                    TextButton(
                      onPressed: _handleResend,
                      child: Text(
                        l10n.resendCode,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14.0 : 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleVerify() {
    final l10n = AppLocalizations.of(context);
    final otp = _controllers.map((controller) => controller.text).join();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterCompleteCode),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(VerifyOtpEvent(_phone, otp));
  }

  void _handleResend() {
    context.read<AuthBloc>().add(RequestOtpEvent(_phone));
  }
}