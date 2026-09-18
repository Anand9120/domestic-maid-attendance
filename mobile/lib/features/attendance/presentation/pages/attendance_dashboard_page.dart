import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/location_helper.dart';
import '../../../../core/widgets/ux4g_civic_bar.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../../domain/entities/attendance_log_entity.dart';
import '../widgets/manual_override_dialog.dart';
import '../widgets/status_badge.dart';
import 'monthly_ledger_page.dart';

class AttendanceDashboardPage extends StatefulWidget {
  final UserEntity user;

  const AttendanceDashboardPage({super.key, required this.user});

  @override
  State<AttendanceDashboardPage> createState() => _AttendanceDashboardPageState();
}

class _AttendanceDashboardPageState extends State<AttendanceDashboardPage> {
  // Household Target Parameters
  double _targetLat = 28.6315000;
  double _targetLon = 77.2167000;
  int _targetHouseholdId = 1;
  String _targetHouseName = 'Sharma Residence';
  double _geofenceRadiusMeters = 50.0;
  int _requiredDwellSeconds = 180; // Standard 3-minute dwell requirement (PRD US-S01)

  // Real-Time GPS & Telemetry
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  double? _currentDistanceMeters;
  bool _isInsideGeofence = false;
  bool _isMockGpsDetected = false;
  bool _isLoadingGps = true;
  bool _isCalibrating = false;
  String _gpsStatusInfo = 'Acquiring GPS fix...';

  // Real Dwell State
  int _dwellCountdown = 0;
  Timer? _dwellTimer;
  bool _hasCheckedInToday = false;

  @override
  void initState() {
    super.initState();
    _fetchHouseholdFromBackend();
    _initRealTimeGps();
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  /// Fetches assigned household geofence parameters from Spring Boot backend
  Future<void> _fetchHouseholdFromBackend() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 4),
      ));

      final endpoint = widget.user.role == UserRole.employer
          ? '${ApiConstants.householdSetup.replaceAll('/setup', '')}/1'
          : '${ApiConstants.maidAssignments}/${widget.user.id}/assignments';

      final response = await dio.get(endpoint);
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          Map<String, dynamic>? householdMap;
          if (data is List && data.isNotEmpty) {
            householdMap = data[0]['householdLocation'] as Map<String, dynamic>?;
          } else if (data is Map<String, dynamic>) {
            householdMap = data;
          }

          final hMap = householdMap;
          if (hMap != null && mounted) {
            setState(() {
              _targetLat = (hMap['latitude'] as num).toDouble();
              _targetLon = (hMap['longitude'] as num).toDouble();
              _targetHouseholdId = (hMap['id'] as num).toInt();
              _targetHouseName = (hMap['houseName'] ?? 'Sharma Residence').toString();
              if (hMap['geofenceRadiusMeters'] != null) {
                _geofenceRadiusMeters = (hMap['geofenceRadiusMeters'] as num).toDouble();
              }
              if (hMap['dwellTimeMinutes'] != null) {
                _requiredDwellSeconds = (hMap['dwellTimeMinutes'] as num).toInt() * 60;
              }
            });
            if (_currentPosition != null) {
              _evaluatePosition(_currentPosition!);
            }
          }
        }
      }
    } catch (_) {
      // Retain seeded defaults if offline
    }
  }

  /// Initializes device GPS hardware and listens to continuous position stream
  Future<void> _initRealTimeGps() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingGps = false;
            _gpsStatusInfo = 'Device location services are disabled. Please enable GPS in device settings.';
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLoadingGps = false;
              _gpsStatusInfo = 'Location permission denied. Real GPS tracking paused.';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingGps = false;
            _gpsStatusInfo = 'Location permissions permanently denied in OS settings.';
          });
        }
        return;
      }

      // Initial fast fix
      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        _evaluatePosition(initialPosition);
      }

      // Continuous high-precision stream for real-time geofence tracking
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // Update whenever device physically moves by 2m
      );

      _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _evaluatePosition,
        onError: (err) {
          if (mounted) {
            setState(() {
              _gpsStatusInfo = 'GPS Stream Error: $err';
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGps = false;
          _gpsStatusInfo = 'GPS Initialization Error: $e';
        });
      }
    }
  }

  /// Calculates real distance using Haversine algorithm and updates boundary & dwell state
  void _evaluatePosition(Position pos) {
    final distance = LocationHelper.calculateDistanceMeters(
      pos.latitude,
      pos.longitude,
      _targetLat,
      _targetLon,
    );
    final inside = distance <= _geofenceRadiusMeters;
    final isMock = pos.isMocked;

    setState(() {
      _currentPosition = pos;
      _currentDistanceMeters = distance;
      _isMockGpsDetected = isMock;
      _isLoadingGps = false;
      _gpsStatusInfo = inside
          ? 'Inside household boundary (${distance.toStringAsFixed(1)}m)'
          : 'Outside geofence boundary (${distance.toStringAsFixed(1)}m away)';
    });

    if (inside && !_isInsideGeofence) {
      _onEnteredGeofence(pos);
    } else if (!inside && _isInsideGeofence) {
      _onExitedGeofence();
    }
  }

  void _onEnteredGeofence(Position pos) {
    setState(() {
      _isInsideGeofence = true;
      _dwellCountdown = 0;
    });

    _dwellTimer?.cancel();
    _dwellTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _dwellCountdown++;
      });

      if (_dwellCountdown >= _requiredDwellSeconds) {
        timer.cancel();
        if (!_hasCheckedInToday) {
          _triggerCheckIn(pos: pos, dwellSeconds: _dwellCountdown);
        }
      }
    });
  }

  void _onExitedGeofence() {
    _dwellTimer?.cancel();
    setState(() {
      _isInsideGeofence = false;
      _dwellCountdown = 0;
    });
  }

  /// Dispatches arrival check-in event with real device GPS coordinates and hardware spoof flag
  void _triggerCheckIn({Position? pos, int? dwellSeconds}) {
    final effectivePos = pos ?? _currentPosition;
    final effectiveDwell = dwellSeconds ?? (_dwellCountdown >= _requiredDwellSeconds ? _dwellCountdown : _requiredDwellSeconds);
    final maidId = widget.user.role == UserRole.employer ? 2 : widget.user.id;

    context.read<AttendanceBloc>().add(
          CheckInEventTriggered(
            maidId: maidId,
            householdId: _targetHouseholdId,
            latitude: effectivePos?.latitude ?? _targetLat,
            longitude: effectivePos?.longitude ?? _targetLon,
            deviceTimestamp: DateTime.now(),
            isMockLocation: effectivePos?.isMocked ?? _isMockGpsDetected,
            dwellTimeSeconds: effectiveDwell,
          ),
        );
    _hasCheckedInToday = true;
  }

  /// Calibrates household geofence to employer device's actual GPS coordinates
  Future<void> _calibrateToCurrentLocation() async {
    setState(() => _isCalibrating = true);
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 5),
      ));

      final payload = {
        'employerId': widget.user.id,
        'houseName': 'Live Household (Calibrated)',
        'address': 'Current Physical Test Location',
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'geofenceRadiusMeters': 50,
        'dwellTimeMinutes': 3,
      };

      final response = await dio.post(ApiConstants.householdSetup, data: payload);
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (mounted) {
          setState(() {
            _targetLat = pos.latitude;
            _targetLon = pos.longitude;
            _targetHouseholdId = (data['id'] as num).toInt();
            _targetHouseName = (data['houseName'] ?? 'Live Household').toString();
            _isCalibrating = false;
          });
          _evaluatePosition(pos);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 Geofence calibrated to your live GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}'),
              backgroundColor: AppColors.present,
            ),
          );
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Calibration failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCalibrating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Calibration failed: $e'),
            backgroundColor: AppColors.absent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;
    final isEmployer = widget.user.role == UserRole.employer;

    return ListenableBuilder(
      listenable: a11y,
      builder: (context, _) {
        final isContrast = a11y.isHighContrast;

        return Scaffold(
          backgroundColor: isContrast ? AppColors.hcBackground : AppColors.background,
          appBar: AppBar(
            backgroundColor: isContrast ? Colors.black : AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEmployer ? a11y.tr('employer_dashboard') : a11y.tr('maid_dashboard'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.user.fullName} (${widget.user.role == UserRole.employer ? a11y.tr('employer_role') : a11y.tr('maid_role')})',
                  style: TextStyle(
                    fontSize: 11,
                    color: isContrast ? Colors.yellow : Colors.white70,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync_rounded),
                tooltip: a11y.tr('sync_offline'),
                onPressed: () {
                  context.read<AttendanceBloc>().add(SyncOfflineLogsEvent());
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: a11y.tr('logout'),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top UX4G Civic Bar (Tricolor + GIGW Font/Contrast/Lang Controls)
                const Ux4gCivicBar(),

                Expanded(
                  child: BlocConsumer<AttendanceBloc, AttendanceState>(
                    listener: (context, state) {
                      if (state is CheckInSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ ${state.message} (${state.log.status.name.toUpperCase()})'),
                            backgroundColor: AppColors.present,
                          ),
                        );
                      } else if (state is OfflineLogBuffered) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('📦 ${state.message} (${state.totalQueued} ${a11y.tr('pending_sync')})'),
                            backgroundColor: Colors.blueGrey,
                          ),
                        );
                      } else if (state is SyncSuccessState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🔄 Synced ${state.syncedCount} offline record(s) to server!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      } else if (state is AttendanceFailure) {
                        if (state.error.contains('already recorded today')) {
                          setState(() {
                            _hasCheckedInToday = true;
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('⚠️ ${state.error}'),
                            backgroundColor: AppColors.absent,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Active Status Banners
                              if (_isInsideGeofence && _dwellCountdown < _requiredDwellSeconds) ...[
                                Ux4gStatusBanner(
                                  variant: Ux4gBannerVariant.warningLight,
                                  title: '${a11y.tr('dwell_counting')} ($_dwellCountdown / ${_requiredDwellSeconds}s)...',
                                  leadingIcon: const Icon(Icons.timer_outlined, color: Color(0xFFC47400)),
                                ),
                                const SizedBox(height: 12),
                              ],

                              if (_isMockGpsDetected) ...[
                                const Ux4gStatusBanner(
                                  variant: Ux4gBannerVariant.errorLight,
                                  title: '⚠️ GIGW Security Alert: Real Hardware Mock/Spoofed Location Detected (position.isMocked = true)',
                                  leadingIcon: Icon(Icons.security_outlined, color: Color(0xFFC5221F)),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // UX4G Attendance Verification Pipeline Stepper
                              _buildAttendanceStepper(a11y, isContrast, state),
                              const SizedBox(height: 16),

                              // Real-Time Presence Radar Card
                              _buildGeofenceCard(a11y, isContrast),
                              const SizedBox(height: 16),

                              // Real-Time GPS & Hardware Telemetry Card
                              _buildRealTimeTelemetryCard(a11y, isContrast, isEmployer),
                              const SizedBox(height: 16),

                              // Quick Navigation Action Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionCard(
                                      title: a11y.tr('view_ledger'),
                                      subtitle: 'Salary & Monthly Attendance',
                                      icon: Icons.calendar_month_rounded,
                                      color: AppColors.primary,
                                      isContrast: isContrast,
                                      onTap: () {
                                        final maidIdToInspect = isEmployer ? 2 : widget.user.id;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: context.read<AttendanceBloc>(),
                                              child: MonthlyLedgerPage(
                                                maidId: maidIdToInspect,
                                                maidName: isEmployer ? 'Sunita Devi' : widget.user.fullName,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (isEmployer) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildActionCard(
                                        title: a11y.tr('manual_override'),
                                        subtitle: a11y.tr('override_hint'),
                                        icon: Icons.edit_calendar_rounded,
                                        color: AppColors.secondary,
                                        isContrast: isContrast,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => BlocProvider.value(
                                              value: context.read<AttendanceBloc>(),
                                              child: ManualOverrideDialog(
                                                employerId: widget.user.id,
                                                householdId: _targetHouseholdId,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Recent Attendance Log Card
                              if (state is CheckInSuccess) ...[
                                _buildRecentCheckInCard(state.log, a11y, isContrast),
                              ] else if (state is OfflineLogBuffered) ...[
                                _buildRecentCheckInCard(state.log, a11y, isContrast),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceStepper(
    AccessibilityController a11y,
    bool isContrast,
    AttendanceState state,
  ) {
    int currentStep = 1;
    final isStep3Error = _isMockGpsDetected && _dwellCountdown >= _requiredDwellSeconds;

    if (state is CheckInSuccess || state is OfflineLogBuffered) {
      currentStep = 4;
    } else if (_isInsideGeofence) {
      if (_dwellCountdown >= _requiredDwellSeconds) {
        currentStep = 3;
      } else {
        currentStep = 2;
      }
    } else {
      currentStep = 1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? AppColors.hcBorder : AppColors.border,
          width: isContrast ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.linear_scale_rounded,
                size: 18,
                color: isContrast ? Colors.yellow : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  a11y.tr('attendance_pipeline'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isContrast ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isContrast
                      ? Colors.yellow
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Step $currentStep / 4',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isContrast ? Colors.black : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Ux4gStepper(
            totalSteps: 4,
            currentStep: currentStep,
            orientation: StepperOrientation.horizontal,
            lineStyle: StepperLineStyle.solid,
            stepSize: 28,
            steps: [
              Ux4gStepItem(
                title: a11y.tr('step_geofence'),
                description: a11y.tr('step_geofence_desc'),
              ),
              Ux4gStepItem(
                title: a11y.tr('step_dwell'),
                description: a11y.tr('step_dwell_desc'),
              ),
              Ux4gStepItem(
                title: a11y.tr('step_audit'),
                description: a11y.tr('step_audit_desc'),
                isError: isStep3Error,
              ),
              Ux4gStepItem(
                title: a11y.tr('step_verified'),
                description: a11y.tr('step_verified_desc'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeofenceCard(AccessibilityController a11y, bool isContrast) {
    final distanceText = _currentDistanceMeters != null
        ? '${_currentDistanceMeters!.toStringAsFixed(1)}m'
        : '...';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? AppColors.hcBorder : AppColors.border,
          width: isContrast ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isInsideGeofence
                      ? (isContrast ? Colors.yellow.withOpacity(0.2) : AppColors.present.withOpacity(0.1))
                      : (isContrast ? Colors.white12 : AppColors.border),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.radar_rounded,
                  size: 26,
                  color: _isInsideGeofence
                      ? (isContrast ? Colors.yellow : AppColors.present)
                      : (isContrast ? Colors.white60 : AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a11y.tr('live_presence_radar'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isInsideGeofence
                          ? '${a11y.tr('inside_geofence')} ($distanceText)'
                          : '${a11y.tr('outside_geofence')} ($distanceText)',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isInsideGeofence
                            ? (isContrast ? Colors.yellow : AppColors.present)
                            : (isContrast ? Colors.white70 : AppColors.textSecondary),
                        fontWeight: _isInsideGeofence ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isInsideGeofence) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_dwellCountdown / _requiredDwellSeconds).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: isContrast ? Colors.white24 : AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _dwellCountdown >= _requiredDwellSeconds
                      ? (isContrast ? Colors.yellow : AppColors.present)
                      : (isContrast ? Colors.amber : AppColors.late),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _dwellCountdown >= _requiredDwellSeconds ? a11y.tr('dwell_completed') : a11y.tr('dwell_counting'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isContrast ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_dwellCountdown / ${_requiredDwellSeconds}s',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _dwellCountdown >= _requiredDwellSeconds
                        ? (isContrast ? Colors.yellow : AppColors.present)
                        : (isContrast ? Colors.amber : AppColors.late),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRealTimeTelemetryCard(AccessibilityController a11y, bool isContrast, bool isEmployer) {
    final pos = _currentPosition;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? AppColors.hcBorder : AppColors.border,
          width: isContrast ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  a11y.tr('realtime_telemetry'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isContrast ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _isInsideGeofence
                      ? (isContrast ? Colors.yellow.withOpacity(0.2) : AppColors.present.withOpacity(0.1))
                      : (isContrast ? Colors.white12 : Colors.grey.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _isInsideGeofence ? 'IN BOUNDARY' : 'OUT OF RANGE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _isInsideGeofence
                        ? (isContrast ? Colors.yellow : AppColors.present)
                        : (isContrast ? Colors.white70 : AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Target: $_targetHouseName (${_geofenceRadiusMeters.toInt()}m radius at ${_targetLat.toStringAsFixed(4)}, ${_targetLon.toStringAsFixed(4)})',
            style: TextStyle(
              fontSize: 11,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Live Telemetry Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isContrast ? Colors.black45 : const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isContrast ? AppColors.hcBorder : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _buildTelemetryRow(
                  '🛰️ Device GPS:',
                  pos != null
                      ? '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}'
                      : (_isLoadingGps ? 'Fixing...' : _gpsStatusInfo),
                  isContrast,
                ),
                const SizedBox(height: 6),
                _buildTelemetryRow(
                  '🎯 Accuracy / Range:',
                  pos != null
                      ? '±${pos.accuracy.toStringAsFixed(1)}m (Range: ${_geofenceRadiusMeters.toInt()}m)'
                      : '--',
                  isContrast,
                ),
                const SizedBox(height: 6),
                _buildTelemetryRow(
                  '📏 ${a11y.tr('distance_to_target')}:',
                  _currentDistanceMeters != null
                      ? '${_currentDistanceMeters!.toStringAsFixed(1)} meters'
                      : '--',
                  isContrast,
                  valueColor: _isInsideGeofence ? AppColors.present : AppColors.late,
                  isBold: true,
                ),
                const SizedBox(height: 6),
                _buildTelemetryRow(
                  '🛡️ Hardware Spoof Check:',
                  _isMockGpsDetected
                      ? '⚠️ MOCK GPS DETECTED'
                      : '✅ Authentic Hardware GPS',
                  isContrast,
                  valueColor: _isMockGpsDetected ? AppColors.absent : AppColors.present,
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Employer Calibration Button: Calibrate Geofence to Tester's Real GPS
          if (isEmployer) ...[
            SizedBox(
              width: double.infinity,
              child: Ux4gButton(
                text: _isCalibrating ? a11y.tr('calibrating') : a11y.tr('calibrate_location'),
                variant: Ux4gButtonVariant.secondary,
                size: Ux4gButtonSize.medium,
                leadingIcon: Icons.my_location_rounded,
                isLoading: _isCalibrating,
                onPressed: _isCalibrating ? null : _calibrateToCurrentLocation,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Zero-Touch Automation Status Banner
          if (_hasCheckedInToday) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isContrast ? Colors.green.shade900.withOpacity(0.3) : const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isContrast ? Colors.greenAccent : const Color(0xFF34A853),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 22,
                    color: isContrast ? Colors.greenAccent : const Color(0xFF137333),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zero-Touch Attendance Verified',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isContrast ? Colors.white : const Color(0xFF137333),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Arrival recorded with 3-minute physical dwell validation. Employer has been notified.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isContrast ? Colors.white70 : const Color(0xFF1E4620),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_isInsideGeofence) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isContrast ? Colors.amber.shade900.withOpacity(0.2) : const Color(0xFFFEF7E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isContrast ? Colors.yellow : const Color(0xFFF9AB00),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        size: 20,
                        color: isContrast ? Colors.yellow : const Color(0xFFB06000),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Zero-Touch Dwell Verification Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isContrast ? Colors.yellow : const Color(0xFFB06000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No buttons needed. Please remain inside the household for ${_requiredDwellSeconds ~/ 60} minutes to automatically log verified presence.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isContrast ? Colors.white70 : const Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isContrast ? Colors.white10 : const Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isContrast ? Colors.white24 : const Color(0xFFCBD5E0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_searching_rounded,
                    size: 18,
                    color: isContrast ? Colors.yellow : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Move within ${_geofenceRadiusMeters.toInt()}m of household to start automated 3-minute dwell verification.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryRow(
    String label,
    String value,
    bool isContrast, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isContrast ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isContrast,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isContrast ? AppColors.hcSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isContrast ? AppColors.hcBorder : AppColors.border,
              width: isContrast ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isContrast ? Colors.yellow.withOpacity(0.2) : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isContrast ? Colors.yellow : color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isContrast ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isContrast ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCheckInCard(AttendanceLogEntity log, AccessibilityController a11y, bool isContrast) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? AppColors.hcBorder : AppColors.border,
          width: isContrast ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  a11y.tr('latest_log'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isContrast ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                status: log.status,
                isMock: log.isMockLocation,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Check-In: ${log.checkInTime ?? "--:--"}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isContrast ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Location Verified: ${log.isMockLocation ? "⚠️ Flagged Spoofed Location" : "✅ Authentic GPS within 50m"}',
            style: TextStyle(
              fontSize: 11,
              color: log.isMockLocation ? AppColors.absent : AppColors.present,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
