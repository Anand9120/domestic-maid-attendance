import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/utils/location_helper.dart';
import '../../../household/domain/entities/household_entity.dart';
import '../../../notifications/domain/entities/notification_entity.dart';

enum TrackingStatus {
  idle,
  outsideGeofence,
  dwelling,
  workInProgress,
  departureCountdownActive,
  completedToday,
}

class GeofenceTrackingController extends ChangeNotifier {
  // Multi-Household Registry
  List<HouseholdEntity> assignedHouseholds = [];
  HouseholdEntity? activeHousehold;
  final Map<int, double> householdDistances = {};

  // Active Household Geofence Parameters
  double targetLat = 28.6315000;
  double targetLon = 77.2167000;
  double geofenceRadiusMeters = 50.0;
  int requiredDwellSeconds = 180;

  // Real-time GPS & Telemetry
  Position? currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  double? currentDistanceMeters;
  bool isInsideGeofence = false;
  bool isMockGpsDetected = false;
  bool isLoadingGps = true;
  String gpsStatusInfo = 'Acquiring GPS fix...';

  // Dwell & Work Session State per household (mapped by householdId)
  final Map<int, bool> _householdCheckedIn = {};
  final Map<int, bool> _householdCheckedOut = {};
  final Map<int, String> _householdCheckInTimes = {};
  final Map<int, String> _householdCheckOutTimes = {};
  final Map<int, String> _householdWorkDurations = {};
  int _lastTrackingDay = DateTime.now().day;

  void _checkMidnightRollover() {
    final currentDay = DateTime.now().day;
    if (currentDay != _lastTrackingDay) {
      _lastTrackingDay = currentDay;
      _householdCheckedIn.clear();
      _householdCheckedOut.clear();
      _householdCheckInTimes.clear();
      _householdCheckOutTimes.clear();
      _householdWorkDurations.clear();
      elapsedWorkSeconds = 0;
      workDurationString = '0m';
    }
  }

  int dwellCountdown = 0;
  Timer? _dwellTimer;
  String workDurationString = '';
  int elapsedWorkSeconds = 0;
  Timer? _workElapsedTimer;

  // Departure Buffer State
  int departureCountdown = 0;
  Timer? _departureTimer;

  // Callbacks for Automated Attendance & Timeline
  void Function(Position pos, int dwellSeconds, HouseholdEntity household)? onCheckInRequired;
  void Function(Position pos, HouseholdEntity household)? onCheckOutRequired;
  void Function(HouseholdEntity oldHome, HouseholdEntity newHome)? onHouseholdAutoSwitched;
  void Function(NotificationEntity notif)? onTimelineEventGenerated;

  // Current active household getters
  bool get hasCheckedInToday =>
      activeHousehold != null ? (_householdCheckedIn[activeHousehold!.id] ?? false) : false;

  bool get isCheckedOutToday =>
      activeHousehold != null ? (_householdCheckedOut[activeHousehold!.id] ?? false) : false;

  String? get checkInTimeString =>
      activeHousehold != null ? _householdCheckInTimes[activeHousehold!.id] : null;

  String? get checkOutTimeString =>
      activeHousehold != null ? _householdCheckOutTimes[activeHousehold!.id] : null;

  TrackingStatus get status {
    if (activeHousehold == null) return TrackingStatus.idle;
    if (isCheckedOutToday) return TrackingStatus.completedToday;
    if (hasCheckedInToday) {
      if (isInsideGeofence) return TrackingStatus.workInProgress;
      return TrackingStatus.departureCountdownActive;
    }
    if (isInsideGeofence) return TrackingStatus.dwelling;
    return TrackingStatus.outsideGeofence;
  }

  void updateTarget({
    required double lat,
    required double lon,
    double radiusMeters = 50.0,
    int dwellSeconds = 180,
  }) {
    targetLat = lat;
    targetLon = lon;
    geofenceRadiusMeters = radiusMeters;
    requiredDwellSeconds = dwellSeconds;
    if (activeHousehold != null) {
      activeHousehold = HouseholdEntity(
        id: activeHousehold!.id,
        employerId: activeHousehold!.employerId,
        houseName: activeHousehold!.houseName,
        address: activeHousehold!.address,
        latitude: lat,
        longitude: lon,
        geofenceRadiusMeters: radiusMeters.toInt(),
        dwellTimeMinutes: (dwellSeconds / 60).round(),
      );
    }
    if (currentPosition != null) {
      _evaluateMultiHouseholdPosition(currentPosition!);
    }
    notifyListeners();
  }

  void setAssignedHouseholds(List<HouseholdEntity> households) {

    assignedHouseholds = List.from(households);
    if (assignedHouseholds.isNotEmpty && activeHousehold == null) {
      setActiveHousehold(assignedHouseholds.first, shouldNotify: false);
    }
    if (currentPosition != null) {
      _evaluateMultiHouseholdPosition(currentPosition!);
    }
    notifyListeners();
  }

  void setActiveHousehold(HouseholdEntity household, {bool shouldNotify = true}) {
    activeHousehold = household;
    targetLat = household.latitude;
    targetLon = household.longitude;
    geofenceRadiusMeters = household.geofenceRadiusMeters.toDouble();
    requiredDwellSeconds = household.dwellTimeMinutes * 60;

    // Reset dwell if switching
    _dwellTimer?.cancel();
    dwellCountdown = 0;

    if (currentPosition != null) {
      _evaluateMultiHouseholdPosition(currentPosition!);
    }
    if (shouldNotify) {
      notifyListeners();
    }
  }

  @visibleForTesting
  void evaluatePositionForTesting(Position pos) {
    _evaluateMultiHouseholdPosition(pos);
  }


  Future<void> startTracking({
    required void Function(Position pos, int dwellSeconds, HouseholdEntity household) onCheckIn,
    required void Function(Position pos, HouseholdEntity household) onCheckOut,
    void Function(HouseholdEntity oldHome, HouseholdEntity newHome)? onAutoSwitch,
    void Function(NotificationEntity notif)? onTimelineEvent,
  }) async {
    onCheckInRequired = onCheckIn;
    onCheckOutRequired = onCheckOut;
    onHouseholdAutoSwitched = onAutoSwitch;
    onTimelineEventGenerated = onTimelineEvent;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoadingGps = false;
        gpsStatusInfo = 'Location services disabled. Please enable GPS in OS settings.';
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoadingGps = false;
          gpsStatusInfo = 'Location permission denied.';
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isLoadingGps = false;
        gpsStatusInfo = 'Location permission permanently denied.';
        notifyListeners();
        return;
      }

      final initialPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _evaluateMultiHouseholdPosition(initialPos);

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      );

      _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _evaluateMultiHouseholdPosition,
        onError: (err) {
          gpsStatusInfo = 'GPS Stream Error: $err';
          notifyListeners();
        },
      );
    } catch (e) {
      isLoadingGps = false;
      gpsStatusInfo = 'GPS Init Error: $e';
      notifyListeners();
    }
  }

  void _evaluateMultiHouseholdPosition(Position pos) {
    _checkMidnightRollover();
    currentPosition = pos;
    isMockGpsDetected = pos.isMocked;
    isLoadingGps = false;

    // 1. Calculate distances to all assigned households
    HouseholdEntity? insideHousehold;
    double minDistance = double.infinity;
    HouseholdEntity? closestHousehold;

    for (final h in assignedHouseholds) {
      final dist = LocationHelper.calculateDistanceMeters(
        pos.latitude,
        pos.longitude,
        h.latitude,
        h.longitude,
      );
      householdDistances[h.id] = dist;

      if (dist < minDistance) {
        minDistance = dist;
        closestHousehold = h;
      }

      if (dist <= h.geofenceRadiusMeters) {
        insideHousehold = h;
      }
    }

    // 2. Auto-switch active household if inside another household's boundary
    if (insideHousehold != null &&
        (activeHousehold == null || activeHousehold!.id != insideHousehold.id)) {
      final oldHome = activeHousehold;
      activeHousehold = insideHousehold;
      targetLat = insideHousehold.latitude;
      targetLon = insideHousehold.longitude;
      geofenceRadiusMeters = insideHousehold.geofenceRadiusMeters.toDouble();
      requiredDwellSeconds = insideHousehold.dwellTimeMinutes * 60;

      // Emit auto-switch event
      if (oldHome != null) {
        onHouseholdAutoSwitched?.call(oldHome, insideHousehold);
      }

      onTimelineEventGenerated?.call(
        NotificationEntity(
          userId: insideHousehold.employerId,
          householdId: insideHousehold.id,
          title: 'Auto-Switched to ${insideHousehold.houseName}',
          body: 'GPS entered geofence of ${insideHousehold.houseName} (${householdDistances[insideHousehold.id]?.toStringAsFixed(1)}m away).',
          type: NotificationType.autoSwitch,
          createdAt: DateTime.now(),
        ),
      );
    }

    // 3. Update distance info for active household
    if (activeHousehold != null) {
      final dist = householdDistances[activeHousehold!.id] ??
          LocationHelper.calculateDistanceMeters(
            pos.latitude,
            pos.longitude,
            targetLat,
            targetLon,
          );
      currentDistanceMeters = dist;
      final inside = dist <= geofenceRadiusMeters;

      gpsStatusInfo = inside
          ? 'Inside ${activeHousehold!.houseName} (${dist.toStringAsFixed(1)}m)'
          : 'Outside ${activeHousehold!.houseName} (${dist.toStringAsFixed(1)}m away)';

      if (inside && !isInsideGeofence) {
        _onEnteredGeofence(pos, activeHousehold!);
      } else if (!inside && isInsideGeofence) {
        _onExitedGeofence(pos, activeHousehold!);
      }
    } else if (closestHousehold != null) {
      currentDistanceMeters = minDistance;
      gpsStatusInfo = 'Nearest: ${closestHousehold.houseName} (${minDistance.toStringAsFixed(1)}m)';
    }

    notifyListeners();
  }

  void _onEnteredGeofence(Position pos, HouseholdEntity household) {
    _departureTimer?.cancel();
    departureCountdown = 0;
    isInsideGeofence = true;
    dwellCountdown = 0;

    onTimelineEventGenerated?.call(
      NotificationEntity(
        userId: household.employerId,
        householdId: household.id,
        title: 'Entered Geofence: ${household.houseName}',
        body: 'Arrived at ${household.houseName}. 3-minute dwell verification timer initiated.',
        type: NotificationType.geofenceEnter,
        createdAt: DateTime.now(),
      ),
    );

    if (hasCheckedInToday) {
      notifyListeners();
      return;
    }

    // Run dwell verification timer using wall-clock timestamp comparison
    final dwellStartTime = DateTime.now();
    _dwellTimer?.cancel();
    _dwellTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsed = DateTime.now().difference(dwellStartTime).inSeconds;
      dwellCountdown = elapsed;
      notifyListeners();

      if (dwellCountdown >= requiredDwellSeconds) {
        timer.cancel();
        if (!hasCheckedInToday && onCheckInRequired != null && activeHousehold != null) {
          onCheckInRequired!(pos, dwellCountdown, activeHousehold!);
        }
      }
    });

    notifyListeners();
  }

  void _onExitedGeofence(Position pos, HouseholdEntity household) {
    _dwellTimer?.cancel();
    isInsideGeofence = false;
    dwellCountdown = 0;

    onTimelineEventGenerated?.call(
      NotificationEntity(
        userId: household.employerId,
        householdId: household.id,
        title: 'Departed Geofence: ${household.houseName}',
        body: 'Stepped outside ${household.houseName} boundary. Departure confirmation buffer active.',
        type: NotificationType.geofenceExit,
        createdAt: DateTime.now(),
      ),
    );

    if (hasCheckedInToday && !isCheckedOutToday) {
      _startDepartureCountdown(pos, household);
    }

    notifyListeners();
  }

  void _startDepartureCountdown(Position pos, HouseholdEntity household) {
    _departureTimer?.cancel();
    departureCountdown = 60; // 60s confirmation buffer

    _departureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (departureCountdown <= 1) {
        timer.cancel();
        departureCountdown = 0;
        if (onCheckOutRequired != null && activeHousehold != null) {
          onCheckOutRequired!(currentPosition ?? pos, activeHousehold!);
        }
      } else {
        departureCountdown--;
      }
      notifyListeners();
    });
  }

  void markCheckedIn({
    required int householdId,
    required String time,
    DateTime? checkInDateTime,
  }) {
    _householdCheckedIn[householdId] = true;
    _householdCheckInTimes[householdId] = time;
    startWorkTimer(checkInDateTime ?? DateTime.now());
    notifyListeners();
  }

  void markCheckedOut({
    required int householdId,
    required String time,
    required String duration,
  }) {
    _workElapsedTimer?.cancel();
    _departureTimer?.cancel();
    departureCountdown = 0;
    _householdCheckedOut[householdId] = true;
    _householdCheckOutTimes[householdId] = time;
    _householdWorkDurations[householdId] = duration;
    workDurationString = duration;
    notifyListeners();
  }

  void startWorkTimer(DateTime checkInTime) {
    _workElapsedTimer?.cancel();
    elapsedWorkSeconds = DateTime.now().difference(checkInTime).inSeconds;
    if (elapsedWorkSeconds < 0) elapsedWorkSeconds = 0;

    _workElapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isCheckedOutToday) {
        elapsedWorkSeconds++;
        notifyListeners();
      }
    });
  }

  String formatElapsedDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _departureTimer?.cancel();
    _workElapsedTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}
