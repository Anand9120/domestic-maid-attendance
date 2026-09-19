import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<NotificationEntity>> execute(int userId) {
    return repository.getNotifications(userId);
  }

  Stream<List<NotificationEntity>> watch(int userId) {
    return repository.watchNotifications(userId);
  }
}
