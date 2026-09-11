import 'dart:math';

class LocationHelper {
  static const double earthRadiusMeters = 6371000.0;

  /// Calculates Haversine distance in meters between two coordinates
  static double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final rLat1 = _degreesToRadians(lat1);
    final rLat2 = _degreesToRadians(lat2);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(rLat1) * cos(rLat2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Checks if current coordinates are within target radius (default 50 meters)
  static bool isWithinRadius(
    double currentLat,
    double currentLon,
    double targetLat,
    double targetLon, [
    double radiusMeters = 50.0,
  ]) {
    final distance = calculateDistanceMeters(
      currentLat,
      currentLon,
      targetLat,
      targetLon,
    );
    return distance <= radiusMeters;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}
