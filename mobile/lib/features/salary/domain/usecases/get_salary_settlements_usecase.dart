import '../entities/salary_settlement_entity.dart';
import '../repositories/salary_repository.dart';

class GetSalarySettlementsUseCase {
  final SalaryRepository repository;

  GetSalarySettlementsUseCase(this.repository);

  Future<List<SalarySettlementEntity>> executeForMaid(int maidId) {
    return repository.getSettlementHistoryForMaid(maidId);
  }

  Future<List<SalarySettlementEntity>> executeForHousehold(int householdId) {
    return repository.getSettlementHistoryForHousehold(householdId);
  }

  Future<SalarySettlementEntity> executeForReceipt(int settlementId) {
    return repository.getReceiptById(settlementId);
  }
}
