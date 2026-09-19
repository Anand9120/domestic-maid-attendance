import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<NotificationEntity>> getNotifications(int userId) async {
    try {
      final remoteList = await remoteDataSource.getNotifications(userId);
      await localDataSource.cacheNotifications(userId, remoteList);
      return remoteList;
    } catch (_) {
      // Offline fallback
      return await localDataSource.getCachedNotifications(userId);
    }
  }

  @override
  Future<int> getUnreadCount(int userId) async {
    try {
      return await remoteDataSource.getUnreadCount(userId);
    } catch (_) {
      final cached = await localDataSource.getCachedNotifications(userId);
      return cached.where((n) => !n.isRead).length;
    }
  }

  @override
  Future<bool> markAsRead(int notificationId) async {
    await localDataSource.markAsRead(notificationId);
    try {
      return await remoteDataSource.markAsRead(notificationId);
    } catch (_) {
      return true; // Marked locally
    }
  }

  @override
  Future<bool> markAllAsRead(int userId) async {
    await localDataSource.markAllAsRead(userId);
    try {
      return await remoteDataSource.markAllAsRead(userId);
    } catch (_) {
      return true; // Marked locally
    }
  }

  @override
  Future<void> saveLocalNotification(NotificationEntity notification) async {
    final model = NotificationModel.fromEntity(notification);
    await localDataSource.saveNotification(model);
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(int userId) {
    return localDataSource.watchNotifications(userId);
  }
}
