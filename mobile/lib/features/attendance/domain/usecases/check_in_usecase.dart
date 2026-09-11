import '../entities/attendance_log_entity.dart';
import '../repositories/attendance_repository.dart';

class CheckInUseCase {
  final AttendanceRepository repository;

  CheckInUseCase(this.repository);

  Future<AttendanceLogEntity> execute({
    required int maidId,
    required int householdId,
    int? shiftId,
    required double latitude,
    required double longitude,
    required DateTime deviceTimestamp,
    bool isMockLocation = false,
    int dwellTimeSeconds = 180,
  }) {
    return repository.checkIn(
      maidId: maidId,
      householdId: householdId,
      shiftId: shiftId,
      latitude: latitude,
      longitude: longitude,
      deviceTimestamp: deviceTimestamp,
      isMockLocation: isMockLocation,
      dwellTimeSeconds: dwellTimeSeconds,
    );
  }
}
