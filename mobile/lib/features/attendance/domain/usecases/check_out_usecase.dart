import '../entities/attendance_log_entity.dart';
import '../repositories/attendance_repository.dart';

class CheckOutUseCase {
  final AttendanceRepository repository;

  CheckOutUseCase(this.repository);

  Future<AttendanceLogEntity> execute({
    required int maidId,
    required int householdId,
    required double latitude,
    required double longitude,
    required DateTime deviceTimestamp,
    bool isMockLocation = false,
  }) {
    return repository.checkOut(
      maidId: maidId,
      householdId: householdId,
      latitude: latitude,
      longitude: longitude,
      deviceTimestamp: deviceTimestamp,
      isMockLocation: isMockLocation,
    );
  }
}
