import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications(int userId);
  Future<int> getUnreadCount(int userId);
  Future<bool> markAsRead(int notificationId);
  Future<bool> markAllAsRead(int userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final NetworkClient networkClient;

  NotificationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<List<NotificationModel>> getNotifications(int userId) async {
    try {
      final response = await networkClient.dio.get(
        '${ApiConstants.userNotifications}/$userId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] as List<dynamic>;
        return list
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch notifications');
      }
    } on DioException catch (e) {
      if (e.response == null ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(e.message ?? 'No network connection');
      }
      throw ServerException(e.response?.data?['message'] ?? e.message ?? 'Server error');
    }
  }

  @override
  Future<int> getUnreadCount(int userId) async {
    try {
      final response = await networkClient.dio.get(
        '${ApiConstants.userNotifications}/$userId/unread-count',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data'] as num).toInt();
      } else {
        return 0;
      }
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await networkClient.dio.put(
        '${ApiConstants.notifications}/$notificationId/read',
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> markAllAsRead(int userId) async {
    try {
      final response = await networkClient.dio.put(
        '${ApiConstants.notifications}/read-all',
        queryParameters: {'userId': userId},
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
