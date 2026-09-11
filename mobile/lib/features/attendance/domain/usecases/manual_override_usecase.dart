import '../entities/attendance_log_entity.dart';
import '../repositories/attendance_repository.dart';

class ManualOverrideUseCase {
  final AttendanceRepository repository;

  ManualOverrideUseCase(this.repository);

  Future<AttendanceLogEntity> execute({
    required int maidId,
    required int householdId,
    int? shiftId,
    required DateTime attendanceDate,
    String? checkInTime,
    AttendanceStatus status = AttendanceStatus.present,
    required int employerId,
    String? notes,
  }) {
    return repository.manualOverride(
      maidId: maidId,
      householdId: householdId,
      shiftId: shiftId,
      attendanceDate: attendanceDate,
      checkInTime: checkInTime,
      status: status,
      employerId: employerId,
      notes: notes,
    );
  }
}
