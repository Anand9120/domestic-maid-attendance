import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserEntity> execute(int userId) {
    return repository.getUserProfile(userId);
  }
}
