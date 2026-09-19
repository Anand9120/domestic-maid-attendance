import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(int userId);
  Future<int> getUnreadCount(int userId);
  Future<bool> markAsRead(int notificationId);
  Future<bool> markAllAsRead(int userId);
  Future<void> saveLocalNotification(NotificationEntity notification);
  Stream<List<NotificationEntity>> watchNotifications(int userId);
}
