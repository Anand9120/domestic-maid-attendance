import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository repository;

  MarkAllNotificationsReadUseCase(this.repository);

  Future<bool> execute(int userId) {
    return repository.markAllAsRead(userId);
  }
}
