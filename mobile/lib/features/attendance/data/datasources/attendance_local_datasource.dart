import 'dart:convert';
import 'package:hive/hive.dart';

abstract class AttendanceLocalDataSource {
  Future<void> cacheOfflineCheckIn(Map<String, dynamic> checkInPayload);
  Future<void> cacheOfflineCheckOut(Map<String, dynamic> checkOutPayload);
  Future<List<Map<String, dynamic>>> getQueuedOfflineCheckIns();
  Future<List<Map<String, dynamic>>> getQueuedEntries();
  Future<void> removeQueuedEntryByKey(dynamic key);
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
    final enriched = Map<String, dynamic>.from(checkInPayload);
    enriched['action'] = enriched['action'] ?? 'CHECK_IN';
    final key = 'in_${DateTime.now().microsecondsSinceEpoch}_${checkInPayload['maidId']}_${checkInPayload['householdId']}';
    await box.put(key, jsonEncode(enriched));
  }

  @override
  Future<void> cacheOfflineCheckOut(Map<String, dynamic> checkOutPayload) async {
    final box = await _getBox();
    final enriched = Map<String, dynamic>.from(checkOutPayload);
    enriched['action'] = 'CHECK_OUT';
    final key = 'out_${DateTime.now().microsecondsSinceEpoch}_${checkOutPayload['maidId']}_${checkOutPayload['householdId']}';
    await box.put(key, jsonEncode(enriched));
  }

  @override
  Future<List<Map<String, dynamic>>> getQueuedEntries() async {
    final box = await _getBox();
    final List<Map<String, dynamic>> list = [];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final data = jsonDecode(raw.toString()) as Map<String, dynamic>;
        list.add({
          'key': key,
          'data': data,
        });
      }
    }
    return list;
  }

  @override
  Future<List<Map<String, dynamic>>> getQueuedOfflineCheckIns() async {
    final entries = await getQueuedEntries();
    return entries.map((e) => e['data'] as Map<String, dynamic>).toList();
  }

  @override
  Future<void> removeQueuedEntryByKey(dynamic key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  @override
  Future<void> removeQueuedCheckIn(int index) async {
    final box = await _getBox();
    if (index >= 0 && index < box.length) {
      await box.deleteAt(index);
    }
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
