import '../entities/attendance_log_entity.dart';
import '../entities/monthly_report_entity.dart';

abstract class AttendanceRepository {
  Future<AttendanceLogEntity> checkIn({
    required int maidId,
    required int householdId,
    int? shiftId,
    required double latitude,
    required double longitude,
    required DateTime deviceTimestamp,
    bool isMockLocation = false,
    int dwellTimeSeconds = 180,
  });

  Future<int> syncOfflineLogs();

  Future<AttendanceLogEntity> manualOverride({
    required int maidId,
    required int householdId,
    int? shiftId,
    required DateTime attendanceDate,
    String? checkInTime,
    AttendanceStatus status = AttendanceStatus.present,
    required int employerId,
    String? notes,
  });

  Future<MonthlyReportEntity> getMonthlyReport({
    required int maidId,
    required int year,
    required int month,
  });

  Future<AttendanceLogEntity> checkOut({
    required int maidId,
    required int householdId,
    required double latitude,
    required double longitude,
    required DateTime deviceTimestamp,
    bool isMockLocation = false,
  });

  Future<List<AttendanceLogEntity>> getTodayAttendance({
    required int maidId,
    required String dateIso,
  });

  Future<int> getQueuedCount();
}
