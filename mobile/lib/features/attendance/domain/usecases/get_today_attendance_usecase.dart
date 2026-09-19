import '../entities/attendance_log_entity.dart';
import '../repositories/attendance_repository.dart';

class GetTodayAttendanceUseCase {
  final AttendanceRepository repository;

  GetTodayAttendanceUseCase(this.repository);

  Future<List<AttendanceLogEntity>> execute({
    required int maidId,
    required String date,
  }) {
    return repository.getTodayAttendance(maidId: maidId, dateIso: date);
  }
}
