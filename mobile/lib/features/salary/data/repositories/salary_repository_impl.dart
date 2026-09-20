import '../../domain/entities/salary_calculation_entity.dart';
import '../../domain/entities/salary_settlement_entity.dart';
import '../../domain/repositories/salary_repository.dart';
import '../datasources/salary_local_datasource.dart';
import '../datasources/salary_remote_datasource.dart';

class SalaryRepositoryImpl implements SalaryRepository {
  final SalaryRemoteDataSource remoteDataSource;
  final SalaryLocalDataSource localDataSource;

  SalaryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<SalaryCalculationEntity> calculateSalary({
    required int maidId,
    required int householdId,
    required int year,
    required int month,
  }) async {
    return remoteDataSource.calculateSalary(
      maidId: maidId,
      householdId: householdId,
      year: year,
      month: month,
    );
  }

  @override
  Future<SalarySettlementEntity> settleSalary({
    required int maidId,
    required int householdId,
    required int year,
    required int month,
    required String paymentMode,
    String? transactionRef,
    String? notes,
  }) async {
    final payload = {
      'maidId': maidId,
      'householdId': householdId,
      'year': year,
      'month': month,
      'paymentMode': paymentMode,
      if (transactionRef != null && transactionRef.isNotEmpty) 'transactionRef': transactionRef,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final result = await remoteDataSource.settleSalary(payload);
    await localDataSource.cacheLatestSettlement(result);
    return result;
  }

  @override
  Future<SalarySettlementEntity> getReceiptById(int settlementId) async {
    return remoteDataSource.getReceiptById(settlementId);
  }

  @override
  Future<List<SalarySettlementEntity>> getSettlementHistoryForMaid(int maidId) async {
    try {
      final remote = await remoteDataSource.getSettlementHistoryForMaid(maidId);
      await localDataSource.cacheSettlements(maidId, remote);
      return remote;
    } catch (_) {
      final cached = await localDataSource.getCachedSettlements(maidId);
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  @override
  Future<List<SalarySettlementEntity>> getSettlementHistoryForHousehold(int householdId) async {
    return remoteDataSource.getSettlementHistoryForHousehold(householdId);
  }
}
