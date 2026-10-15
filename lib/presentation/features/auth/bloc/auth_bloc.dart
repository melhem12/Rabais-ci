import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../core/errors/refresh_token_exception.dart';
import '../../../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RefreshSessionEvent>(_onRefreshSession);
    on<LoginWithPasswordEvent>(_onLoginWithPassword);
    on<SetPasswordEvent>(_onSetPassword);
    on<BackToPhoneEvent>((event, emit) {
      _resettingPassword = false;
      _pendingUser = null;
      emit(const Unauthenticated());
    });
  }

  /// True between "forgot password" and the new password being saved.
  bool _resettingPassword = false;

  /// User from the SMS-code login, kept while they create their password so
  /// we can route them afterwards (profile completion or home).
  User? _pendingUser;

  /// Where to go once signed in (shared by OTP, password and password setup).
  AuthState _stateAfterLogin(User user) {
    if (user.role == 'merchant') return Authenticated(user);
    if (user.firstTimeLogin) return ProfileCompletionRequired(user);
    return Authenticated(user);
  }

  Future<void> _onLoginWithPassword(LoginWithPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final session = await _authRepository.loginWithPassword(event.phone, event.password);
      emit(_stateAfterLogin(session.user));
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Une erreur est survenue'));
    }
  }

  Future<void> _onSetPassword(SetPasswordEvent event, Emitter<AuthState> emit) async {
    final pending = _pendingUser;
    emit(const AuthLoading());
    try {
      final session = await _authRepository.setPassword(event.password);
      _resettingPassword = false;
      _pendingUser = null;
      // Route with the user from the SMS login: the fresh session no longer
      // reports first_time_login.
      emit(_stateAfterLogin(pending ?? session.user));
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Une erreur est survenue'));
    }
  }

  Future<void> _onRequestOtp(RequestOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // "Resend code" during a forgot-password flow must stay on the SMS code.
      final forceOtp = event.forceOtp || _resettingPassword;
      final response = await _authRepository.requestOtp(
        event.phone,
        channel: event.channel,
        forceOtp: forceOtp,
      );
      if (response.requiresPassword) {
        emit(PasswordLoginRequired(event.phone));
        return;
      }
      if (forceOtp) _resettingPassword = true;
      emit(OtpVerificationRequired(event.phone, response));
    } on ServerFailure catch (e) {
      // Backend OTP errors carry a user-facing French `detail`; drop the
      // "Exception: " prefix added by the datasource wrapping.
      emit(AuthError(e.message.replaceFirst(RegExp(r'^Exception:\s*'), '')));
    } catch (e) {
      // Extract user-friendly error message
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Accès refusé. Veuillez vous reconnecter.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Service non trouvé.';
      } else if (e.toString().contains('422')) {
        errorMessage = 'Données invalides. Vérifiez vos informations.';
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final session = await _authRepository.verifyOtp(event.phone, event.otp);

      // First SMS login (or "forgot password"): create the password before
      // anything else. Merchants go home afterwards, new customers to the
      // profile form.
      if (session.user.needsPasswordSetup || _resettingPassword) {
        _pendingUser = session.user;
        emit(PasswordSetupRequired(session.user, isReset: _resettingPassword));
        return;
      }
      emit(_stateAfterLogin(session.user));
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      // Extract user-friendly error message
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Accès refusé. Veuillez vous reconnecter.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Service non trouvé.';
      } else if (e.toString().contains('422')) {
        errorMessage = 'Données invalides. Vérifiez vos informations.';
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final user = await _authRepository.updateProfile(event.profileData);
      emit(Authenticated(user));
    } on ServerFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      // Extract user-friendly error message
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('Network error')) {
        errorMessage = 'Erreur de connexion. Vérifiez votre internet.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Accès refusé. Veuillez vous reconnecter.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Service non trouvé.';
      } else if (e.toString().contains('422')) {
        errorMessage = 'Données invalides. Vérifiez vos informations.';
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      _resettingPassword = false;
      _pendingUser = null;
      await _authRepository.logout();
      // Clear language preference on logout
      await LocalizationService.clearLanguage();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('Erreur lors de la déconnexion: $e'));
    }
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        bool invalidSession = false;
        try {
          await _authRepository.refreshSession();
        } on RefreshTokenException {
          invalidSession = true;
        } on ServerFailure {
          // Ignore network/server issues here; we'll attempt /auth/me with the existing token.
        }

        if (invalidSession) {
          emit(Unauthenticated());
          return;
        }

        // Try to get current user, but handle server errors gracefully
        try {
          final user = await _authRepository.getCurrentUser();
          // Merchants don't need profile completion
          if (user.role == 'merchant') {
            emit(Authenticated(user));
          } else if (user.firstTimeLogin) {
            emit(ProfileCompletionRequired(user));
          } else {
            emit(Authenticated(user));
          }
        } on ServerFailure {
          // If getCurrentUser fails (e.g., 500 error), clear tokens and emit Unauthenticated
          // This prevents the app from trying to use invalid tokens
          try {
            await _authRepository.clearStoredSession();
          } catch (_) {
            // Ignore errors when clearing session
          }
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      // Only emit Unauthenticated for unexpected errors
      // If it's a ServerFailure, it should have been caught above
      if (e is! ServerFailure) {
        emit(Unauthenticated());
      }
    }
  }

  Future<void> _onRefreshSession(RefreshSessionEvent event, Emitter<AuthState> emit) async {
    // Don't override Authenticated state if we're already authenticated
    // This prevents issues after profile completion
    final currentState = state;
    
    // Don't interrupt OTP flow or other active authentication processes
    if (currentState is OtpVerificationRequired || currentState is AuthLoading) {
      return;
    }
    
    if (currentState is Authenticated && event.silent) {
      // If already authenticated and this is a silent refresh, skip to avoid unnecessary state changes
      return;
    }

    try {
      final result = await _authRepository.refreshSession();
      if (result == null) {
        // If refresh returns null and we're already authenticated, keep the current state
        if (currentState is Authenticated) {
          return;
        }
        return;
      }

      // Check state again after refresh - state might have changed to OTP flow
      // This prevents race conditions where refresh starts before OTP state is set
      final stateAfterRefresh = state;
      if (stateAfterRefresh is OtpVerificationRequired || stateAfterRefresh is AuthLoading) {
        // State changed to OTP flow while we were refreshing, don't override it
        return;
      }

      // Try to get current user, but handle server errors gracefully
      try {
        final user = await _authRepository.getCurrentUser();
        
        // Check state one more time before emitting - state might have changed during getCurrentUser
        final finalState = state;
        if (finalState is OtpVerificationRequired || finalState is AuthLoading) {
          // State changed to OTP flow, don't override it
          return;
        }
        
        if (user.role == 'merchant') {
          emit(Authenticated(user));
        } else if (user.firstTimeLogin) {
          emit(ProfileCompletionRequired(user));
        } else {
          emit(Authenticated(user));
        }
      } on ServerFailure {
        // Check state again - it might have changed to OTP flow during getCurrentUser
        final stateAfterError = state;
        if (stateAfterError is OtpVerificationRequired || stateAfterError is AuthLoading) {
          // State changed to OTP flow, don't override it
          return;
        }
        
        // If getCurrentUser fails (e.g., 500 error), preserve the current state
        // Don't interrupt OTP flow or other authentication processes
        if (currentState is OtpVerificationRequired || currentState is AuthLoading) {
          // We're in the middle of OTP flow, don't change state
          return;
        }
        
        // If we have valid tokens but getCurrentUser fails, keep authenticated state in silent mode
        if (event.silent && currentState is Authenticated) {
          // Tokens are valid, just the /auth/me endpoint is having issues
          // Keep the current state to avoid logging out the user
          return;
        }
        
        // If we're not authenticated and getCurrentUser fails, clear tokens
        // This prevents the app from trying to use invalid tokens on next startup
        if (currentState is Unauthenticated || currentState is AuthInitial) {
          try {
            await _authRepository.clearStoredSession();
          } catch (_) {
            // Ignore errors when clearing session
          }
          return;
        }
        
        // In non-silent mode, show error (but don't emit Unauthenticated)
        if (!event.silent) {
          emit(AuthError('Erreur serveur lors de la récupération des informations utilisateur.'));
        } else {
          // Silent mode - preserve current state, don't emit anything
          return;
        }
      }
    } on RefreshTokenException {
      // Check state again - it might have changed to OTP flow
      final stateAfterException = state;
      if (stateAfterException is OtpVerificationRequired || stateAfterException is AuthLoading) {
        // State changed to OTP flow, don't override it
        return;
      }
      
      // Only emit Unauthenticated if we're not in an active authentication flow
      // This prevents logging out users who just completed their profile or are in OTP flow
      if (currentState is! Authenticated && 
          currentState is! OtpVerificationRequired && 
          currentState is! AuthLoading) {
        emit(Unauthenticated());
      }
    } on ServerFailure catch (e) {
      // Check state again - it might have changed to OTP flow
      final stateAfterError = state;
      if (stateAfterError is OtpVerificationRequired || stateAfterError is AuthLoading) {
        // State changed to OTP flow, don't override it
        return;
      }
      
      // This catches ServerFailure from refreshSession
      // Don't interrupt OTP flow
      if (currentState is OtpVerificationRequired || currentState is AuthLoading) {
        return;
      }
      
      if (!event.silent) {
        emit(AuthError(e.message));
      }
      // In silent mode, if we're already authenticated, keep the current state
      if (event.silent && currentState is Authenticated) {
        return;
      }
    } catch (_) {
      // Check state again - it might have changed to OTP flow
      final stateAfterError = state;
      if (stateAfterError is OtpVerificationRequired || stateAfterError is AuthLoading) {
        // State changed to OTP flow, don't override it
        return;
      }
      
      // Don't interrupt OTP flow
      if (currentState is OtpVerificationRequired || currentState is AuthLoading) {
        return;
      }
      
      // Swallow unexpected errors in silent mode
      if (!event.silent) {
        emit(AuthError('Une erreur est survenue lors de la mise à jour de la session.'));
      }
      // In silent mode, if we're already authenticated, keep the current state
      if (event.silent && currentState is Authenticated) {
        return;
      }
    }
  }
}