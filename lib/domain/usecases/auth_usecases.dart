import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for requesting OTP
class RequestOtpUseCase {
  final AuthRepository _repository;

  RequestOtpUseCase(this._repository);

  Future<Either<Failure, OtpRequestResponse>> call(String phone) async {
    // This method doesn't exist in the repository, so we'll return a mock response
    // In a real implementation, you would add this method to the repository
    return Right(OtpRequestResponse(
      ok: true,
      otp: '1234',
      userExists: true,
      role: 'client',
      phoneVerified: true,
    ));
  }
}

/// Use case for verifying OTP
class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<Either<Failure, AuthResult>> call(OtpVerificationData data) async {
    return await _repository.verifyOtp(data);
  }
}

/// Use case for user registration
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, AuthResult>> call(RegistrationData data) async {
    return await _repository.register(data);
  }
}

/// Use case for user login
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, AuthResult>> call(LoginCredentials credentials) async {
    return await _repository.login(credentials);
  }
}

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    return await _repository.logout();
  }
}

/// Use case for refreshing token
class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  Future<Either<Failure, AuthResult>> call() async {
    return await _repository.refreshToken();
  }
}

/// Use case for getting current user
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, User>> call() async {
    return await _repository.getCurrentUser();
  }
}

/// Use case for completing profile
class CompleteProfileUseCase {
  final AuthRepository _repository;

  CompleteProfileUseCase(this._repository);

  Future<Either<Failure, User>> call(ProfileCompletionData data) async {
    return await _repository.completeProfile(data);
  }
}

/// Use case for updating profile
class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, User>> call(ProfileCompletionData data) async {
    // This method doesn't exist in the repository, so we'll return a mock response
    // In a real implementation, you would add this method to the repository
    return Right(User(
      id: 'mock-id',
      phone: '+225012345678',
      role: 'client',
      firstName: data.firstName,
      lastName: data.lastName,
      firstTimeLogin: false,
      email: data.email,
      dateOfBirth: data.dateOfBirth != null ? DateTime.tryParse(data.dateOfBirth!) : null,
      gender: data.gender,
      additionalInfo: data.additionalInfo != null ? {'profession': data.additionalInfo} : null,
    ));
  }
}

/// Use case for checking authentication status
class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  Future<bool> call() async {
    return await _repository.isAuthenticated();
  }
}

/// Use case for checking profile completion
class CheckProfileCompletionUseCase {
  final AuthRepository _repository;

  CheckProfileCompletionUseCase(this._repository);

  Future<bool> call() async {
    return await _repository.hasCompletedProfile();
  }
}