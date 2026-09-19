import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/household_model.dart';

abstract class HouseholdRemoteDataSource {
  Future<HouseholdModel> setupHousehold(Map<String, dynamic> payload);
  Future<List<HouseholdModel>> getHouseholdsForEmployer(int employerId);
  Future<HouseholdModel?> getHouseholdById(int householdId);
  Future<HouseholdModel?> getAssignedHouseholdForMaid(int maidId);
  Future<List<HouseholdModel>> getAssignmentsForMaid(int maidId);
  Future<bool> joinHouseholdByCode(int maidId, String inviteCode);
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

  @override
  Future<HouseholdModel?> getHouseholdById(int householdId) async {
    try {
      final base = ApiConstants.householdSetup.replaceAll('/setup', '');
      final response = await networkClient.dio.get('$base/$householdId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          return HouseholdModel.fromJson(data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<HouseholdModel?> getAssignedHouseholdForMaid(int maidId) async {
    try {
      final response = await networkClient.dio.get(
        '${ApiConstants.maidAssignments}/$maidId/assignments',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          final first = data[0];
          final hMap = first['householdLocation'] as Map<String, dynamic>? ?? first as Map<String, dynamic>;
          return HouseholdModel.fromJson(hMap);
        } else if (data is Map<String, dynamic>) {
          return HouseholdModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<HouseholdModel>> getAssignmentsForMaid(int maidId) async {
    try {
      final response = await networkClient.dio.get(
        '${ApiConstants.maidAssignments}/$maidId/assignments',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = (response.data['data'] as List<dynamic>?) ?? [];
        return list.map((item) {
          final hMap = item['householdLocation'] as Map<String, dynamic>? ?? item as Map<String, dynamic>;
          return HouseholdModel.fromJson(hMap);
        }).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> joinHouseholdByCode(int maidId, String inviteCode) async {
    try {
      final response = await networkClient.dio.post(
        ApiConstants.joinHouseholdByCode,
        data: {
          'maidId': maidId,
          'inviteCode': inviteCode,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
