import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/attendance_log_entity.dart';
import '../../domain/entities/monthly_report_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_datasource.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final AttendanceLocalDataSource localDataSource;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AttendanceLogEntity> checkIn({
    required int maidId,
    required int householdId,
    int? shiftId,
    required double latitude,
    required double longitude,
    required DateTime deviceTimestamp,
    bool isMockLocation = false,
    int dwellTimeSeconds = 180,
  }) async {
    final payload = {
      'maidId': maidId,
      'householdId': householdId,
      'shiftId': shiftId,
      'latitude': latitude,
      'longitude': longitude,
      'deviceTimestamp': deviceTimestamp.toIso8601String(),
      'isMockLocation': isMockLocation,
      'dwellTimeSeconds': dwellTimeSeconds,
    };

    try {
      // 1. Try sending to Spring Boot backend directly
      final result = await remoteDataSource.checkIn(payload);
      return result;
    } on NetworkException catch (_) {
      // 2. Offline fallback (PRD US-M02: Offline Queue & Event Buffer)
      // If network is absent or backend unreachable, buffer into Hive with exact device timestamp
      await localDataSource.cacheOfflineCheckIn(payload);

      return AttendanceLogEntity(
        maidId: maidId,
        householdId: householdId,
        shiftId: shiftId,
        attendanceDate: deviceTimestamp,
        checkInTime: '${deviceTimestamp.hour.toString().padLeft(2, '0')}:${deviceTimestamp.minute.toString().padLeft(2, '0')}',
        status: AttendanceStatus.present,
        entryType: EntryType.offlineSync,
        deviceTimestamp: deviceTimestamp,
        isMockLocation: isMockLocation,
      );
    }
  }

  @override
  Future<int> syncOfflineLogs() async {
    final queued = await localDataSource.getQueuedOfflineCheckIns();
    if (queued.isEmpty) return 0;

    int syncedCount = 0;
    final remaining = <Map<String, dynamic>>[];

    for (final log in queued) {
      try {
        await remoteDataSource.checkIn(log);
        syncedCount++;
      } catch (e) {
        remaining.add(log);
      }
    }

    await localDataSource.clearQueue();
    for (final item in remaining) {
      await localDataSource.cacheOfflineCheckIn(item);
    }

    return syncedCount;
  }

  @override
  Future<AttendanceLogEntity> manualOverride({
    required int maidId,
    required int householdId,
    int? shiftId,
    required DateTime attendanceDate,
    String? checkInTime,
    AttendanceStatus status = AttendanceStatus.present,
    required int employerId,
    String? notes,
  }) async {
    final payload = {
      'maidId': maidId,
      'householdId': householdId,
      'shiftId': shiftId,
      'attendanceDate': attendanceDate.toIso8601String().substring(0, 10),
      'checkInTime': checkInTime,
      'status': status.name.toUpperCase(),
      'employerId': employerId,
      'notes': notes,
    };

    return await remoteDataSource.manualOverride(payload);
  }

  @override
  Future<MonthlyReportEntity> getMonthlyReport({
    required int maidId,
    required int year,
    required int month,
  }) async {
    return await remoteDataSource.getMonthlyReport(maidId, year, month);
  }

  @override
  Future<int> getQueuedCount() async {
    return await localDataSource.getQueuedCount();
  }
}
