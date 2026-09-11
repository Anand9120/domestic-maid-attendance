import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/household_model.dart';

abstract class HouseholdRemoteDataSource {
  Future<HouseholdModel> setupHousehold(Map<String, dynamic> payload);
  Future<List<HouseholdModel>> getHouseholdsForEmployer(int employerId);
}

class HouseholdRemoteDataSourceImpl implements HouseholdRemoteDataSource {
  final NetworkClient networkClient;

  HouseholdRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<HouseholdModel> setupHousehold(Map<String, dynamic> payload) async {
    try {
      final response = await networkClient.dio.post(
        ApiConstants.householdSetup,
        data: payload,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return HouseholdModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response.data['message'] ?? 'Household setup failed');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<HouseholdModel>> getHouseholdsForEmployer(int employerId) async {
    try {
      final response = await networkClient.dio.get(
        '${ApiConstants.householdSetup}/employer/$employerId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = (response.data['data'] as List<dynamic>?) ?? [];
        return list.map((e) => HouseholdModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
