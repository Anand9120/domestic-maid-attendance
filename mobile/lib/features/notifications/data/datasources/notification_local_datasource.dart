import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<void> saveNotification(NotificationModel notification);
  Future<List<NotificationModel>> getCachedNotifications(int userId);
  Future<void> cacheNotifications(int userId, List<NotificationModel> notifications);
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead(int userId);
  Stream<List<NotificationModel>> watchNotifications(int userId);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String boxName = 'notification_cache_box';
  Box? _box;
  final StreamController<List<NotificationModel>> _streamController =
      StreamController<List<NotificationModel>>.broadcast();
  final List<NotificationModel> _memoryCache = [];

  Future<Box?> _getBox() async {
    try {
      if (_box != null && _box!.isOpen) {
        return _box!;
      }
      _box = await Hive.openBox(boxName);
      return _box!;
    } catch (_) {
      // In-memory fallback if Hive is not initialized (e.g. unit tests)
      return null;
    }
  }

  @override
  Future<void> saveNotification(NotificationModel notification) async {
    _memoryCache.insert(0, notification);
    _streamController.add(List.unmodifiable(_memoryCache));

    final box = await _getBox();
    if (box != null) {
      await box.put(
        'notif_${notification.id ?? DateTime.now().millisecondsSinceEpoch}',
        jsonEncode(notification.toJson()),
      );
    }
  }

  @override
  Future<List<NotificationModel>> getCachedNotifications(int userId) async {
    final box = await _getBox();
    if (box != null && box.isNotEmpty) {
      final List<NotificationModel> loaded = [];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val != null) {
          try {
            final model = NotificationModel.fromJson(jsonDecode(val.toString()));
            if (model.userId == userId) {
              loaded.add(model);
            }
          } catch (_) {}
        }
      }
      loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _memoryCache.clear();
      _memoryCache.addAll(loaded);
      return List.unmodifiable(_memoryCache);
    }
    return List.unmodifiable(_memoryCache.where((n) => n.userId == userId).toList());
  }

  @override
  Future<void> cacheNotifications(int userId, List<NotificationModel> notifications) async {
    _memoryCache.clear();
    _memoryCache.addAll(notifications);
    _streamController.add(List.unmodifiable(_memoryCache));

    final box = await _getBox();
    if (box != null) {
      for (final n in notifications) {
        await box.put('notif_${n.id ?? n.createdAt.millisecondsSinceEpoch}', jsonEncode(n.toJson()));
      }
    }
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    final index = _memoryCache.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _memoryCache[index] = _memoryCache[index].copyWith(isRead: true);
      _streamController.add(List.unmodifiable(_memoryCache));
    }
  }

  @override
  Future<void> markAllAsRead(int userId) async {
    for (int i = 0; i < _memoryCache.length; i++) {
      if (_memoryCache[i].userId == userId) {
        _memoryCache[i] = _memoryCache[i].copyWith(isRead: true);
      }
    }
    _streamController.add(List.unmodifiable(_memoryCache));
  }


  @override
  Stream<List<NotificationModel>> watchNotifications(int userId) {
    return _streamController.stream.map(
      (list) => list.where((n) => n.userId == userId).toList(),
    );
  }
}
