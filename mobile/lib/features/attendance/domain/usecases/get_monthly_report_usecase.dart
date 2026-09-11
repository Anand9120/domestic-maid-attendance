import '../entities/monthly_report_entity.dart';
import '../repositories/attendance_repository.dart';

class GetMonthlyReportUseCase {
  final AttendanceRepository repository;

  GetMonthlyReportUseCase(this.repository);

  Future<MonthlyReportEntity> execute({
    required int maidId,
    required int year,
    required int month,
  }) {
    return repository.getMonthlyReport(
      maidId: maidId,
      year: year,
      month: month,
    );
  }
}
