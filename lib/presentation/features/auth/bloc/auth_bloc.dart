import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../core/errors/refresh_token_exception.dart';
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
  }

  Future<void> _onRequestOtp(RequestOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final response = await _authRepository.requestOtp(event.phone);
      emit(OtpVerificationRequired(event.phone, response));
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

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final session = await _authRepository.verifyOtp(event.phone, event.otp);
      
      // Merchants don't need profile completion, go directly to merchant home
      if (session.user.role == 'merchant') {
        emit(Authenticated(session.user));
      } else if (session.user.firstTimeLogin) {
        // Only customers need profile completion on first login
        emit(ProfileCompletionRequired(session.user));
      } else {
        emit(Authenticated(session.user));
      }
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