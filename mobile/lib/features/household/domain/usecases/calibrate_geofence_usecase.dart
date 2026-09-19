import '../entities/household_entity.dart';
import '../repositories/household_repository.dart';

class CalibrateGeofenceUseCase {
  final HouseholdRepository repository;

  CalibrateGeofenceUseCase(this.repository);

  Future<HouseholdEntity> execute({
    required int employerId,
    required String houseName,
    required double latitude,
    required double longitude,
    int geofenceRadiusMeters = 50,
    int dwellTimeMinutes = 3,
  }) {
    return repository.calibrateGeofence(
      employerId: employerId,
      houseName: houseName,
      latitude: latitude,
      longitude: longitude,
      geofenceRadiusMeters: geofenceRadiusMeters,
      dwellTimeMinutes: dwellTimeMinutes,
    );
  }
}
