/// User entity representing a user in the system
class User {
  final String id;
  final String phone;
  final String role;
  final String? firstName;
  final String? lastName;
  final bool firstTimeLogin;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final Map<String, dynamic>? additionalInfo;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.phone,
    required this.role,
    this.firstName,
    this.lastName,
    required this.firstTimeLogin,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.additionalInfo,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'client',
      firstName: json['first_name'],
      lastName: json['last_name'],
      firstTimeLogin: json['first_time_login'] ?? false,
      email: json['email'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.tryParse(json['date_of_birth']) 
          : null,
      gender: json['gender'],
      additionalInfo: json['additional_info'],
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'first_time_login': firstTimeLogin,
      'email': email,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'additional_info': additionalInfo,
    };
  }
}

/// Authentication session containing tokens and user info
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final User user;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }
}

/// OTP request response
class OtpRequestResponse {
  final bool ok;
  final String otp;
  final bool userExists;
  final String role;
  final bool phoneVerified;

  const OtpRequestResponse({
    required this.ok,
    required this.otp,
    required this.userExists,
    required this.role,
    required this.phoneVerified,
  });

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponse(
      ok: json['ok'] ?? false,
      otp: json['otp'] ?? '',
      userExists: json['user_exists'] ?? false,
      role: json['role'] ?? 'client',
      phoneVerified: json['phone_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'otp': otp,
      'user_exists': userExists,
      'role': role,
      'phone_verified': phoneVerified,
    };
  }
}

/// Login credentials
class LoginCredentials {
  final String phone;
  final String otp;

  const LoginCredentials({
    required this.phone,
    required this.otp,
  });
}

/// Registration data
class RegistrationData {
  final String phone;
  final String firstName;
  final String lastName;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final String? additionalInfo;

  const RegistrationData({
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.additionalInfo,
  });
}

/// Profile completion data
class ProfileCompletionData {
  final String firstName;
  final String lastName;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final String? additionalInfo;

  const ProfileCompletionData({
    required this.firstName,
    required this.lastName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.additionalInfo,
  });
}

/// OTP verification data
class OtpVerificationData {
  final String phone;
  final String otp;

  const OtpVerificationData({
    required this.phone,
    required this.otp,
  });
}

/// Auth result containing session and user info
class AuthResult {
  final AuthSession session;
  final User user;

  const AuthResult({
    required this.session,
    required this.user,
  });
}