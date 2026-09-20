import '../repositories/auth_repository.dart';

class RegisterFcmTokenUseCase {
  final AuthRepository repository;

  RegisterFcmTokenUseCase(this.repository);

  Future<void> execute({
    required int userId,
    required String fcmToken,
  }) async {
    await repository.registerFcmToken(userId: userId, fcmToken: fcmToken);
  }
}
