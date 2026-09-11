import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../utils/location_helper.dart';

typedef OnGeofenceTriggeredCallback = void Function({
  required double latitude,
  required double longitude,
  required DateTime timestamp,
  required bool isMockLocation,
  required int dwellTimeSeconds,
});

class GeofenceTarget {
  final int householdId;
  final String houseName;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final int dwellTimeMinutes;

  GeofenceTarget({
    required this.householdId,
    required this.houseName,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 50.0,
    this.dwellTimeMinutes = 3,
  });
}

class GeofenceService {
  final List<GeofenceTarget> _targets = [];
  Timer? _dwellTimer;
  int _elapsedDwellSeconds = 0;
  GeofenceTarget? _activeInsideTarget;
  StreamSubscription<Position>? _positionSubscription;
  OnGeofenceTriggeredCallback? onGeofenceTriggered;

  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;
  int get elapsedDwellSeconds => _elapsedDwellSeconds;
  GeofenceTarget? get activeTarget => _activeInsideTarget;

  void setTargets(List<GeofenceTarget> targets) {
    _targets.clear();
    _targets.addAll(targets);
  }

  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  void startMonitoring({OnGeofenceTriggeredCallback? onArrival}) {
    if (_isMonitoring) return;
    onGeofenceTriggered = onArrival;
    _isMonitoring = true;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_handlePositionUpdate);
  }

  void _handlePositionUpdate(Position position) {
    GeofenceTarget? matchedTarget;

    for (final target in _targets) {
      final isInside = LocationHelper.isWithinRadius(
        position.latitude,
        position.longitude,
        target.latitude,
        target.longitude,
        target.radiusMeters,
      );

      if (isInside) {
        matchedTarget = target;
        break;
      }
    }

    if (matchedTarget != null) {
      if (_activeInsideTarget?.householdId != matchedTarget.householdId) {
        // Entered new household geofence boundary! Start dwell timer (PRD US-M01 & US-S01)
        _activeInsideTarget = matchedTarget;
        _elapsedDwellSeconds = 0;
        _startDwellTimer(position);
      }
    } else {
      // Exited boundary before dwell threshold: cancel timer (pass-by filter)
      if (_activeInsideTarget != null) {
        _dwellTimer?.cancel();
        _activeInsideTarget = null;
        _elapsedDwellSeconds = 0;
      }
    }
  }

  void _startDwellTimer(Position position) {
    _dwellTimer?.cancel();
    final requiredDwellSeconds = (_activeInsideTarget?.dwellTimeMinutes ?? 3) * 60;

    _dwellTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedDwellSeconds++;

      if (_elapsedDwellSeconds >= requiredDwellSeconds) {
        timer.cancel();

        // 3-minute threshold met! Trigger automated presence logging
        onGeofenceTriggered?.call(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
          isMockLocation: position.isMocked,
          dwellTimeSeconds: _elapsedDwellSeconds,
        );
      }
    });
  }

  void stopMonitoring() {
    _dwellTimer?.cancel();
    _positionSubscription?.cancel();
    _isMonitoring = false;
    _activeInsideTarget = null;
    _elapsedDwellSeconds = 0;
  }
}
