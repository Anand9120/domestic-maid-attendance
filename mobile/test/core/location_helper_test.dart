import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/core/utils/location_helper.dart';

void main() {
  group('LocationHelper Tests', () {
    test('calculateDistanceMeters should calculate accurate Haversine distance', () {
      // Connaught Place reference: 28.6315000, 77.2167000
      const centerLat = 28.6315000;
      const centerLon = 77.2167000;

      // Nearby point ~20 meters away
      const nearLat = 28.6316500;
      const nearLon = 77.2167800;

      final distance = LocationHelper.calculateDistanceMeters(
        nearLat,
        nearLon,
        centerLat,
        centerLon,
      );

      expect(distance, lessThan(50.0));
      expect(
        LocationHelper.isWithinRadius(nearLat, nearLon, centerLat, centerLon, 50.0),
        isTrue,
      );
    });

    test('isWithinRadius should return false when outside 50-meter radius', () {
      const centerLat = 28.6315000;
      const centerLon = 77.2167000;

      // Point ~500 meters away
      const farLat = 28.6360000;
      const farLon = 77.2167000;

      final distance = LocationHelper.calculateDistanceMeters(
        farLat,
        farLon,
        centerLat,
        centerLon,
      );

      expect(distance, greaterThan(50.0));
      expect(
        LocationHelper.isWithinRadius(farLat, farLon, centerLat, centerLon, 50.0),
        isFalse,
      );
    });
  });
}
