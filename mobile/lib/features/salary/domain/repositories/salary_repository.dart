import '../entities/salary_calculation_entity.dart';
import '../entities/salary_settlement_entity.dart';

abstract class SalaryRepository {
  Future<SalaryCalculationEntity> calculateSalary({
    required int maidId,
    required int householdId,
    required int year,
    required int month,
  });

  Future<SalarySettlementEntity> settleSalary({
    required int maidId,
    required int householdId,
    required int year,
    required int month,
    required String paymentMode,
    String? transactionRef,
    String? notes,
  });

  Future<SalarySettlementEntity> getReceiptById(int settlementId);

  Future<List<SalarySettlementEntity>> getSettlementHistoryForMaid(int maidId);

  Future<List<SalarySettlementEntity>> getSettlementHistoryForHousehold(int householdId);
}
