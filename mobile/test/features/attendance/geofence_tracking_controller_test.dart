import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maid_attendance/features/attendance/presentation/controllers/geofence_tracking_controller.dart';
import 'package:maid_attendance/features/household/domain/entities/household_entity.dart';
import 'package:maid_attendance/features/notifications/domain/entities/notification_entity.dart';

void main() {
  late GeofenceTrackingController controller;

  final home1 = const HouseholdEntity(
    id: 1,
    employerId: 1,
    houseName: 'Sharma Residence (Flat 402)',
    latitude: 28.6315000,
    longitude: 77.2167000,
    geofenceRadiusMeters: 50,
    dwellTimeMinutes: 3,
  );

  final home2 = const HouseholdEntity(
    id: 2,
    employerId: 2,
    houseName: 'Verma Residence (Flat 105)',
    latitude: 28.6400000,
    longitude: 77.2250000,
    geofenceRadiusMeters: 50,
    dwellTimeMinutes: 3,
  );

  final home3 = const HouseholdEntity(
    id: 3,
    employerId: 3,
    houseName: 'Kapoor Residence (Flat 204)',
    latitude: 28.6500000,
    longitude: 77.2350000,
    geofenceRadiusMeters: 50,
    dwellTimeMinutes: 3,
  );

  setUp(() {
    controller = GeofenceTrackingController();
  });

  tearDown(() {
    controller.dispose();
  });

  Position createPosition({required double latitude, required double longitude}) {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 10.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
      isMocked: false,
    );
  }

  group('Multi-Household Auto-Geofence Switching Tests', () {
    test('initializes with assigned households and defaults active household to first', () {
      controller.setAssignedHouseholds([home1, home2, home3]);

      expect(controller.assignedHouseholds.length, 3);
      expect(controller.activeHousehold?.id, 1);
      expect(controller.activeHousehold?.houseName, 'Sharma Residence (Flat 402)');
    });

    test('calculates parallel distances to all assigned society households simultaneously', () {
      controller.setAssignedHouseholds([home1, home2, home3]);

      // Position right at home1
      final pos = createPosition(latitude: home1.latitude, longitude: home1.longitude);
      controller.evaluatePositionForTesting(pos);

      expect(controller.householdDistances.containsKey(1), true);
      expect(controller.householdDistances.containsKey(2), true);
      expect(controller.householdDistances.containsKey(3), true);

      expect(controller.householdDistances[1]!, lessThan(5.0));
      expect(controller.householdDistances[2]!, greaterThan(100.0));
      expect(controller.householdDistances[3]!, greaterThan(500.0));
    });

    test('auto-switches active household when GPS enters another assigned household geofence', () {
      HouseholdEntity? switchedFrom;
      HouseholdEntity? switchedTo;
      final List<NotificationEntity> timelineEvents = [];

      controller.onHouseholdAutoSwitched = (oldH, newH) {
        switchedFrom = oldH;
        switchedTo = newH;
      };
      controller.onTimelineEventGenerated = (notif) {
        timelineEvents.add(notif);
      };

      controller.setAssignedHouseholds([home1, home2, home3]);
      expect(controller.activeHousehold?.id, 1);

      // Maid walks to Flat 105 (Verma Residence)
      final posAtHome2 = createPosition(
        latitude: home2.latitude + 0.0001, // ~11 meters away, inside 50m radius
        longitude: home2.longitude,
      );
      controller.evaluatePositionForTesting(posAtHome2);

      // Verify active household auto-switched to home 2
      expect(controller.activeHousehold?.id, 2);
      expect(controller.activeHousehold?.houseName, 'Verma Residence (Flat 105)');
      expect(switchedFrom?.id, 1);
      expect(switchedTo?.id, 2);

      // Verify auto-switch notification event was generated
      expect(timelineEvents.any((n) => n.type == NotificationType.autoSwitch), true);
      expect(timelineEvents.any((n) => n.type == NotificationType.geofenceEnter), true);
      expect(controller.isInsideGeofence, true);
    });

    test('maintains multi-household check-in and check-out tracking state per household', () {
      controller.setAssignedHouseholds([home1, home2, home3]);

      // Check into Flat 402
      controller.markCheckedIn(householdId: 1, time: '07:35 AM');
      expect(controller.hasCheckedInToday, true);
      expect(controller.checkInTimeString, '07:35 AM');

      // Switch active view to Flat 105
      controller.setActiveHousehold(home2);
      expect(controller.hasCheckedInToday, false);
      expect(controller.checkInTimeString, isNull);

      // Check into Flat 105
      controller.markCheckedIn(householdId: 2, time: '10:02 AM');
      expect(controller.hasCheckedInToday, true);
      expect(controller.checkInTimeString, '10:02 AM');

      // Switch back to Flat 402 - state is preserved
      controller.setActiveHousehold(home1);
      expect(controller.hasCheckedInToday, true);
      expect(controller.checkInTimeString, '07:35 AM');
    });
  });
}
