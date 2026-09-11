import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> verifyOtp({
    required String phoneNumber,
    required String otp,
    UserRole role = UserRole.maid,
    String? fullName,
  }) async {
    try {
      return await remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
        role: role,
        fullName: fullName,
      );
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> registerFcmToken({
    required int userId,
    required String fcmToken,
  }) async {
    await remoteDataSource.registerFcmToken(userId: userId, fcmToken: fcmToken);
  }

  @override
  Future<void> logout() async {
    // Clear tokens and cached sessions
  }
}
