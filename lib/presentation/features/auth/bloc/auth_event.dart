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
  const RequestOtpEvent(this.phone);
  
  @override
  List<Object?> get props => [phone];
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
