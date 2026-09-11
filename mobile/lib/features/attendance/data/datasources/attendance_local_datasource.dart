import 'dart:convert';
import 'package:hive/hive.dart';

abstract class AttendanceLocalDataSource {
  Future<void> cacheOfflineCheckIn(Map<String, dynamic> checkInPayload);
  Future<List<Map<String, dynamic>>> getQueuedOfflineCheckIns();
  Future<void> removeQueuedCheckIn(int index);
  Future<void> clearQueue();
  Future<int> getQueuedCount();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  static const String boxName = 'offline_attendance_queue';
  Box? _box;

  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox(boxName);
    return _box!;
  }

  @override
  Future<void> cacheOfflineCheckIn(Map<String, dynamic> checkInPayload) async {
    final box = await _getBox();
    await box.add(jsonEncode(checkInPayload));
  }

  @override
  Future<List<Map<String, dynamic>>> getQueuedOfflineCheckIns() async {
    final box = await _getBox();
    final List<Map<String, dynamic>> list = [];
    for (int i = 0; i < box.length; i++) {
      final raw = box.getAt(i);
      if (raw != null) {
        list.add(jsonDecode(raw.toString()) as Map<String, dynamic>);
      }
    }
    return list;
  }

  @override
  Future<void> removeQueuedCheckIn(int index) async {
    final box = await _getBox();
    await box.deleteAt(index);
  }

  @override
  Future<void> clearQueue() async {
    final box = await _getBox();
    await box.clear();
  }

  @override
  Future<int> getQueuedCount() async {
    final box = await _getBox();
    return box.length;
  }
}
