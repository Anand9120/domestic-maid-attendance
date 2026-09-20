import '../entities/salary_settlement_entity.dart';
import '../repositories/salary_repository.dart';

class SettleSalaryUseCase {
  final SalaryRepository repository;

  SettleSalaryUseCase(this.repository);

  Future<SalarySettlementEntity> execute({
    required int maidId,
    required int householdId,
    required int year,
    required int month,
    required String paymentMode,
    String? transactionRef,
    String? notes,
  }) {
    return repository.settleSalary(
      maidId: maidId,
      householdId: householdId,
      year: year,
      month: month,
      paymentMode: paymentMode,
      transactionRef: transactionRef,
      notes: notes,
    );
  }
}
