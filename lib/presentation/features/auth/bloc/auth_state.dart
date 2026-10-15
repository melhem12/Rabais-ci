import 'package:equatable/equatable.dart';

import 'package:rabais_ci/domain/entities/user.dart';

/// Base class for authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// OTP verification required state
class OtpVerificationRequired extends AuthState {
  final String phone;
  final OtpRequestResponse response;

  const OtpVerificationRequired(this.phone, this.response);

  @override
  List<Object?> get props => [phone, response];
}

/// The account has a password: ask for it instead of sending an SMS.
class PasswordLoginRequired extends AuthState {
  final String phone;

  const PasswordLoginRequired(this.phone);

  @override
  List<Object?> get props => [phone];
}

/// After an SMS-code login: the user must create a password (first login) or
/// choose a new one ([isReset], forgot password).
class PasswordSetupRequired extends AuthState {
  final User user;
  final bool isReset;

  const PasswordSetupRequired(this.user, {this.isReset = false});

  @override
  List<Object?> get props => [user, isReset];
}

/// Profile completion required state
class ProfileCompletionRequired extends AuthState {
  final User user;

  const ProfileCompletionRequired(this.user);

  @override
  List<Object?> get props => [user];
}

/// Authentication error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
