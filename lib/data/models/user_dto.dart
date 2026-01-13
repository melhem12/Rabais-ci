/// Data Transfer Object for User
class UserDto {
  final String id;
  final String name;
  final String phone;
  final String role;
  final bool firstTimeLogin;
  final bool phoneVerified;
  final String? email;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? additionalInfo;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserDto({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.firstTimeLogin,
    required this.phoneVerified,
    this.email,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.additionalInfo,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      firstTimeLogin: json['first_time_login'] as bool,
      phoneVerified: json['phone_verified'] as bool,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String) 
          : null,
      gender: json['gender'] as String?,
      additionalInfo: json['additional_info'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'first_time_login': firstTimeLogin,
      'phone_verified': phoneVerified,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'additional_info': additionalInfo,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Data Transfer Object for Auth Result
class AuthResultDto {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserDto user;

  const AuthResultDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResultDto.fromJson(Map<String, dynamic> json) {
    return AuthResultDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
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

/// Data Transfer Object for Login Request
class LoginRequestDto {
  final String phone;
  final String otp;

  const LoginRequestDto({
    required this.phone,
    required this.otp,
  });

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) {
    return LoginRequestDto(
      phone: json['phone'] as String,
      otp: json['otp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
    };
  }
}

/// Data Transfer Object for Registration Request
class RegistrationRequestDto {
  final String phone;
  final String firstName;
  final String lastName;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final String? additionalInfo;

  const RegistrationRequestDto({
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.additionalInfo,
  });

  factory RegistrationRequestDto.fromJson(Map<String, dynamic> json) {
    return RegistrationRequestDto(
      phone: json['phone'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      additionalInfo: json['additional_info'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'additional_info': additionalInfo,
    };
  }
}

/// Data Transfer Object for Profile Completion Request
class ProfileCompletionRequestDto {
  final String firstName;
  final String lastName;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final String? additionalInfo;

  const ProfileCompletionRequestDto({
    required this.firstName,
    required this.lastName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.additionalInfo,
  });

  factory ProfileCompletionRequestDto.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionRequestDto(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      additionalInfo: json['additional_info'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'additional_info': additionalInfo,
    };
  }
}

/// Data Transfer Object for OTP Verification Request
class OtpVerificationRequestDto {
  final String phone;
  final String otp;

  const OtpVerificationRequestDto({
    required this.phone,
    required this.otp,
  });

  factory OtpVerificationRequestDto.fromJson(Map<String, dynamic> json) {
    return OtpVerificationRequestDto(
      phone: json['phone'] as String,
      otp: json['otp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
    };
  }
}

/// Data Transfer Object for Refresh Token Request
class RefreshTokenRequestDto {
  final String token;

  const RefreshTokenRequestDto({
    required this.token,
  });

  factory RefreshTokenRequestDto.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequestDto(
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}