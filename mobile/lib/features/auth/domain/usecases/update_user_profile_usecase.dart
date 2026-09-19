import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<UserEntity> execute({
    required int userId,
    required Map<String, dynamic> data,
  }) {
    return repository.updateUserProfile(userId: userId, data: data);
  }
}
