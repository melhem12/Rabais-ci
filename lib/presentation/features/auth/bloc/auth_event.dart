import 'package:equatable/equatable.dart';

/// Base authentication event class
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

/// Request OTP event
class RequestOtpEvent extends AuthEvent {
  final String phone;
  /// Optional delivery channel override (sms | whatsapp).
  final String? channel;
  /// "Forgot password": always send an SMS code, then ask for a new password.
  final bool forceOtp;
  const RequestOtpEvent(this.phone, {this.channel, this.forceOtp = false});

  @override
  List<Object?> get props => [phone, channel, forceOtp];
}

/// Sign in with phone + password.
class LoginWithPasswordEvent extends AuthEvent {
  final String phone;
  final String password;
  const LoginWithPasswordEvent(this.phone, this.password);

  @override
  List<Object?> get props => [phone, password];
}

/// Create the password (first login) or a new one (forgot password).
class SetPasswordEvent extends AuthEvent {
  final String password;
  const SetPasswordEvent(this.password);

  @override
  List<Object?> get props => [password];
}

/// Leave the password / OTP step and go back to the phone number screen.
class BackToPhoneEvent extends AuthEvent {
  const BackToPhoneEvent();
}

/// Verify OTP event
class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  const VerifyOtpEvent(this.phone, this.otp);
  
  @override
  List<Object?> get props => [phone, otp];
}

/// Logout event
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Update profile event
class UpdateProfileEvent extends AuthEvent {
  final Map<String, dynamic> profileData;
  const UpdateProfileEvent(this.profileData);
  
  @override
  List<Object?> get props => [profileData];
}

/// Check auth status event
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Refresh session event
class RefreshSessionEvent extends AuthEvent {
  final bool silent;

  const RefreshSessionEvent({this.silent = true});

  @override
  List<Object?> get props => [silent];
}
