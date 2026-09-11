import '../repositories/attendance_repository.dart';

class SyncOfflineLogsUseCase {
  final AttendanceRepository repository;

  SyncOfflineLogsUseCase(this.repository);

  Future<int> execute() {
    return repository.syncOfflineLogs();
  }
}
