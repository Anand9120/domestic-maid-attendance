import '../../domain/entities/household_entity.dart';
import '../../domain/repositories/household_repository.dart';
import '../datasources/household_remote_datasource.dart';

class HouseholdRepositoryImpl implements HouseholdRepository {
  final HouseholdRemoteDataSource remoteDataSource;

  HouseholdRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HouseholdEntity?> getHouseholdById(int householdId) async {
    return await remoteDataSource.getHouseholdById(householdId);
  }

  @override
  Future<HouseholdEntity?> getAssignedHouseholdForMaid(int maidId) async {
    return await remoteDataSource.getAssignedHouseholdForMaid(maidId);
  }

  @override
  Future<List<HouseholdEntity>> getAssignedHouseholdsForMaid(int maidId) async {
    return await remoteDataSource.getAssignmentsForMaid(maidId);
  }

  @override
  Future<HouseholdEntity> calibrateGeofence({
    required int employerId,
    required String houseName,
    required double latitude,
    required double longitude,
    int geofenceRadiusMeters = 50,
    int dwellTimeMinutes = 3,
  }) async {
    final payload = {
      'employerId': employerId,
      'houseName': houseName,
      'address': 'Calibrated Physical Location',
      'latitude': latitude,
      'longitude': longitude,
      'geofenceRadiusMeters': geofenceRadiusMeters,
      'dwellTimeMinutes': dwellTimeMinutes,
    };

    return await remoteDataSource.setupHousehold(payload);
  }

  @override
  Future<bool> joinHouseholdByCode({
    required int maidId,
    required String inviteCode,
  }) async {
    return await remoteDataSource.joinHouseholdByCode(maidId, inviteCode);
  }

  @override
  Future<HouseholdEntity> setupHousehold(Map<String, dynamic> payload) async {
    return await remoteDataSource.setupHousehold(payload);
  }
}
