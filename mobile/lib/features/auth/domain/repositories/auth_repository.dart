import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> verifyOtp({
    required String phoneNumber,
    required String otp,
    UserRole role = UserRole.maid,
    String? fullName,
  });

  Future<void> registerFcmToken({
    required int userId,
    required String fcmToken,
  });

  Future<UserEntity> getUserProfile(int userId);

  Future<UserEntity> updateUserProfile({
    required int userId,
    required Map<String, dynamic> data,
  });

  Future<void> logout();
}
