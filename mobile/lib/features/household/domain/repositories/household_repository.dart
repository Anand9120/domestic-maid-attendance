import '../entities/household_entity.dart';

abstract class HouseholdRepository {
  Future<HouseholdEntity?> getHouseholdById(int householdId);
  Future<HouseholdEntity?> getAssignedHouseholdForMaid(int maidId);
  Future<List<HouseholdEntity>> getAssignedHouseholdsForMaid(int maidId);
  Future<HouseholdEntity> calibrateGeofence({
    required int employerId,
    required String houseName,
    required double latitude,
    required double longitude,
    int geofenceRadiusMeters = 50,
    int dwellTimeMinutes = 3,
  });
  Future<bool> joinHouseholdByCode({
    required int maidId,
    required String inviteCode,
  });
  Future<HouseholdEntity> setupHousehold(Map<String, dynamic> payload);
}
