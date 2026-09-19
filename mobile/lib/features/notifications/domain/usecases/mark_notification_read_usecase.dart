import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<bool> execute(int notificationId) {
    return repository.markAsRead(notificationId);
  }
}
