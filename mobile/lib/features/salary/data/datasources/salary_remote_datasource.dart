import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/salary_calculation_model.dart';
import '../models/salary_settlement_model.dart';

abstract class SalaryRemoteDataSource {
  Future<SalaryCalculationModel> calculateSalary({
    required int maidId,
    required int householdId,
    required int year,
    required int month,
  });

  Future<SalarySettlementModel> settleSalary(Map<String, dynamic> payload);

  Future<SalarySettlementModel> getReceiptById(int settlementId);

  Future<List<SalarySettlementModel>> getSettlementHistoryForMaid(int maidId);

  Future<List<SalarySettlementModel>> getSettlementHistoryForHousehold(int householdId);
}

class SalaryRemoteDataSourceImpl implements SalaryRemoteDataSource {
  final NetworkClient networkClient;

  SalaryRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<SalaryCalculationModel> calculateSalary({
    required int maidId,
    required int householdId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await networkClient.dio.get(
        ApiConstants.calculateSalary,
        queryParameters: {
          'maidId': maidId,
          'householdId': householdId,
          'year': year,
          'month': month,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SalaryCalculationModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to calculate salary');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SalarySettlementModel> settleSalary(Map<String, dynamic> payload) async {
    try {
      final response = await networkClient.dio.post(
        ApiConstants.settleSalary,
        data: payload,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SalarySettlementModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response.data['message'] ?? 'Salary settlement failed');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SalarySettlementModel> getReceiptById(int settlementId) async {
    try {
      final response = await networkClient.dio.get(
        '${ApiConstants.salary}/receipt/$settlementId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SalarySettlementModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response.data['message'] ?? 'Receipt not found');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<SalarySettlementModel>> getSettlementHistoryForMaid(int maidId) async {
    try {
      final response = await networkClient.dio.get(
        '${ApiConstants.salary}/maid/$maidId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = (response.data['data'] as List<dynamic>?) ?? [];
        return list.map((e) => SalarySettlementModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<SalarySettlementModel>> getSettlementHistoryForHousehold(int householdId) async {
    try {
      final response = await networkClient.dio.get(
        '${ApiConstants.salary}/household/$householdId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = (response.data['data'] as List<dynamic>?) ?? [];
        return list.map((e) => SalarySettlementModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
