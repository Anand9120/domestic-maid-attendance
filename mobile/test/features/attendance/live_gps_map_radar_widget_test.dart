import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maid_attendance/features/attendance/presentation/widgets/live_gps_map_radar_widget.dart';

void main() {
  Position createPos({
    double lat = 28.6315,
    double lon = 77.2167,
    double accuracy = 8.0,
    double speed = 1.0,
  }) {
    return Position(
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.now(),
      accuracy: accuracy,
      altitude: 10.0,
      altitudeAccuracy: 1.0,
      heading: 0.0,
      headingAccuracy: 1.0,
      speed: speed,
      speedAccuracy: 0.1,
    );
  }

  Widget createWidgetUnderTest({
    double targetLat = 28.6315,
    double targetLon = 77.2167,
    String houseName = 'Sharma Residence',
    double geofenceRadius = 50.0,
    Position? pos,
    double? distanceMeters,
    bool isInside = false,
    int dwellCountdown = 0,
    int requiredDwell = 180,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: LiveGpsMapRadarWidget(
            targetLat: targetLat,
            targetLon: targetLon,
            houseName: houseName,
            geofenceRadiusMeters: geofenceRadius,
            currentPosition: pos,
            distanceMeters: distanceMeters,
            isInsideGeofence: isInside,
            dwellCountdown: dwellCountdown,
            requiredDwellSeconds: requiredDwell,
          ),
        ),
      ),
    );
  }

  testWidgets('renders LiveGpsMapRadarWidget with house name and boundary scale', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      houseName: 'Villa 402 - Green Heights',
      geofenceRadius: 60.0,
    ));
    await tester.pump();

    expect(find.text('Villa 402 - Green Heights'), findsOneWidget);
    expect(find.text('Geofence: 60m'), findsOneWidget);
    expect(find.text('N'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
  });

  testWidgets('displays IN tag when inside geofence boundary', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      isInside: true,
      distanceMeters: 14.5,
      pos: createPos(),
    ));
    await tester.pump();

    expect(find.text('14.5m IN'), findsOneWidget);
  });

  testWidgets('displays AWAY tag when outside geofence boundary', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      isInside: false,
      distanceMeters: 85.0,
      pos: createPos(),
    ));
    await tester.pump();

    expect(find.text('85.0m AWAY'), findsOneWidget);
  });

  testWidgets('shows warning banner when GPS accuracy is degraded (> 40.0m)', (tester) async {
    final badPos = createPos(accuracy: 65.0);
    await tester.pumpWidget(createWidgetUnderTest(
      pos: badPos,
      isInside: false,
    ));
    await tester.pump();

    expect(find.textContaining('GPS degraded (±65m)'), findsOneWidget);
  });

  testWidgets('shows warning banner when vehicular transit speed (> 3.0 m/s) is detected', (tester) async {
    final vehiclePos = createPos(speed: 8.0); // 28.8 km/h
    await tester.pumpWidget(createWidgetUnderTest(
      pos: vehiclePos,
      isInside: true,
    ));
    await tester.pump();

    expect(find.textContaining('In-transit speed (28.8 km/h)'), findsOneWidget);
  });
}
