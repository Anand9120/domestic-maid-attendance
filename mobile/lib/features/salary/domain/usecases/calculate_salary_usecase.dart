import '../entities/salary_calculation_entity.dart';
import '../repositories/salary_repository.dart';

class CalculateSalaryUseCase {
  final SalaryRepository repository;

  CalculateSalaryUseCase(this.repository);

  Future<SalaryCalculationEntity> execute({
    required int maidId,
    required int householdId,
    required int year,
    required int month,
  }) {
    return repository.calculateSalary(
      maidId: maidId,
      householdId: householdId,
      year: year,
      month: month,
    );
  }
}
