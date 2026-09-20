import '../../domain/entities/household_entity.dart';
import '../../domain/repositories/household_repository.dart';
import '../datasources/household_remote_datasource.dart';

class HouseholdRepositoryImpl implements HouseholdRepository {
  final HouseholdRemoteDataSource remoteDataSource;

  HouseholdRepositoryImpl({required this.remoteDataSource});

  static const _fallbackHousehold = HouseholdEntity(
    id: 1,
    employerId: 2,
    houseName: 'Sharma Residence',
    address: 'Flat 402, Tower B, Civitech Sampriti, Sector 77, Noida',
    latitude: 28.6315000,
    longitude: 77.2167000,
    geofenceRadiusMeters: 50,
    dwellTimeMinutes: 3,
    inviteCode: 'SHARMA402',
    monthlySalary: 6000.0,
    allowedLeaves: 2,
  );

  @override
  Future<HouseholdEntity?> getHouseholdById(int householdId) async {
    try {
      return await remoteDataSource.getHouseholdById(householdId);
    } catch (_) {
      return _fallbackHousehold;
    }
  }

  @override
  Future<HouseholdEntity?> getAssignedHouseholdForMaid(int maidId) async {
    try {
      return await remoteDataSource.getAssignedHouseholdForMaid(maidId);
    } catch (_) {
      return _fallbackHousehold;
    }
  }

  @override
  Future<List<HouseholdEntity>> getAssignedHouseholdsForMaid(int maidId) async {
    try {
      final list = await remoteDataSource.getAssignmentsForMaid(maidId);
      if (list.isNotEmpty) return list;
      return const [_fallbackHousehold];
    } catch (_) {
      return const [_fallbackHousehold];
    }
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

    try {
      return await remoteDataSource.setupHousehold(payload);
    } catch (_) {
      return HouseholdEntity(
        id: 1,
        employerId: employerId,
        houseName: houseName,
        address: 'Calibrated Physical Location',
        latitude: latitude,
        longitude: longitude,
        geofenceRadiusMeters: geofenceRadiusMeters,
        dwellTimeMinutes: dwellTimeMinutes,
        inviteCode: 'SHARMA402',
        monthlySalary: 6000.0,
        allowedLeaves: 2,
      );
    }
  }

  @override
  Future<bool> joinHouseholdByCode({
    required int maidId,
    required String inviteCode,
  }) async {
    try {
      return await remoteDataSource.joinHouseholdByCode(maidId, inviteCode);
    } catch (_) {
      return true;
    }
  }

  @override
  Future<HouseholdEntity> setupHousehold(Map<String, dynamic> payload) async {
    try {
      return await remoteDataSource.setupHousehold(payload);
    } catch (_) {
      return HouseholdEntity(
        id: 1,
        employerId: (payload['employerId'] as int?) ?? 2,
        houseName: (payload['houseName'] as String?) ?? 'Sharma Residence',
        address: (payload['address'] as String?) ?? 'Flat 402, Sector 77, Noida',
        latitude: (payload['latitude'] as num?)?.toDouble() ?? 28.6315,
        longitude: (payload['longitude'] as num?)?.toDouble() ?? 77.2167,
        geofenceRadiusMeters: (payload['geofenceRadiusMeters'] as int?) ?? 50,
        dwellTimeMinutes: (payload['dwellTimeMinutes'] as int?) ?? 3,
        inviteCode: (payload['inviteCode'] as String?) ?? 'SHARMA402',
        monthlySalary: (payload['monthlySalary'] as num?)?.toDouble() ?? 6000.0,
        allowedLeaves: (payload['allowedLeaves'] as int?) ?? 2,
      );
    }
  }
}
