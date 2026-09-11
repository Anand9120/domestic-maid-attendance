import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<UserEntity> execute({
    required String phoneNumber,
    required String otp,
    UserRole role = UserRole.maid,
    String? fullName,
  }) {
    return repository.verifyOtp(
      phoneNumber: phoneNumber,
      otp: otp,
      role: role,
      fullName: fullName,
    );
  }
}
