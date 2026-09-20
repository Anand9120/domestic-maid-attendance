import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../../core/widgets/ux4g_civic_bar.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../household/presentation/pages/maid_profile_setup_page.dart';
import '../../domain/entities/attendance_log_entity.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../controllers/geofence_tracking_controller.dart';
import '../widgets/departure_countdown_banner.dart';
import '../widgets/hardware_telemetry_card.dart';

import '../widgets/household_selector_tabs.dart';
import '../widgets/manual_override_dialog.dart';
import '../widgets/multi_household_radar_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/work_completed_card.dart';
import '../widgets/work_in_progress_card.dart';
import 'monthly_ledger_page.dart';
import '../../../household/domain/entities/household_entity.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/presentation/widgets/notification_bell_action.dart';

class AttendanceDashboardPage extends StatefulWidget {
  final UserEntity user;

  const AttendanceDashboardPage({super.key, required this.user});

  @override
  State<AttendanceDashboardPage> createState() => _AttendanceDashboardPageState();
}

class _AttendanceDashboardPageState extends State<AttendanceDashboardPage> {
  // Geofence & Hardware Telemetry Controller
  late final GeofenceTrackingController _tracker;

  // Household target metadata
  int _targetHouseholdId = 1;
  String _targetHouseName = 'Sharma Residence';
  String _inviteCode = 'SHARMA402';
  bool _isCalibrating = false;

  @override
  void initState() {
    super.initState();
    _tracker = GeofenceTrackingController();
    _tracker.addListener(_onTrackerUpdated);

    _fetchHouseholdConfig();
    _checkTodayStatus();
    _initTracker();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationBloc>().add(
              FetchNotificationsEvent(userId: widget.user.id),
            );
      }
    });
  }

  void _onTrackerUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tracker.removeListener(_onTrackerUpdated);
    _tracker.dispose();
    super.dispose();
  }

  /// Initializes continuous hardware GPS stream, multi-household auto-switching and callbacks
  Future<void> _initTracker() async {
    await _tracker.startTracking(
      onCheckIn: (pos, dwell, household) {
        final maidId = widget.user.role == UserRole.employer ? 2 : widget.user.id;
        context.read<AttendanceBloc>().add(
              CheckInEventTriggered(
                maidId: maidId,
                householdId: household.id,
                latitude: pos.latitude,
                longitude: pos.longitude,
                deviceTimestamp: DateTime.now(),
                isMockLocation: pos.isMocked,
                dwellTimeSeconds: dwell,
              ),
            );
      },
      onCheckOut: (pos, household) {
        final maidId = widget.user.role == UserRole.employer ? 2 : widget.user.id;
        context.read<AttendanceBloc>().add(
              CheckOutEventTriggered(
                maidId: maidId,
                householdId: household.id,
                latitude: pos.latitude,
                longitude: pos.longitude,
                deviceTimestamp: DateTime.now(),
                isMockLocation: pos.isMocked,
              ),
            );
      },
      onAutoSwitch: (oldHome, newHome) {
        if (mounted) {
          setState(() {
            _targetHouseholdId = newHome.id;
            _targetHouseName = newHome.houseName;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.sync_alt_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto-Switched to ${newHome.houseName} (${_tracker.householdDistances[newHome.id]?.toStringAsFixed(1)}m away)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF4338CA),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      onTimelineEvent: (notif) {
        if (mounted) {
          context.read<NotificationBloc>().add(
                AddLocalTimelineEvent(notification: notif),
              );
        }
      },
    );
  }

  /// Fetches assigned household configuration via Clean Architecture Use Case
  Future<void> _fetchHouseholdConfig() async {
    try {
      final isEmployer = widget.user.role == UserRole.employer;
      final List<HouseholdEntity> households;

      if (isEmployer) {
        final home = await sl.getAssignedHouseholdUseCase.executeForEmployer(1);
        households = home != null ? [home] : [];
      } else {
        households = await sl.getAssignedHouseholdUseCase.executeListForMaid(widget.user.id);
      }

      if (households.isNotEmpty && mounted) {
        _tracker.setAssignedHouseholds(households);
        final first = households.first;
        setState(() {
          _targetHouseholdId = first.id;
          _targetHouseName = first.houseName;
          if (first.inviteCode != null && first.inviteCode!.isNotEmpty) {
            _inviteCode = first.inviteCode!;
          }
        });
      }
    } catch (_) {
      // Retain default seed config if offline
    }
  }


  /// Checks today's attendance logs via Clean Architecture Use Case
  Future<void> _checkTodayStatus() async {
    try {
      final maidId = widget.user.role == UserRole.employer ? 2 : widget.user.id;
      final todayIso = DateTime.now().toIso8601String().substring(0, 10);
      final logs = await sl.getTodayAttendanceUseCase.execute(
        maidId: maidId,
        date: todayIso,
      );

      if (logs.isNotEmpty && mounted) {
        final latest = logs.last;
        final inTime = latest.checkInTime;
        final outTime = latest.checkOutTime;
        final hid = latest.householdId;

        if (outTime != null) {
          _tracker.markCheckedIn(householdId: hid, time: inTime ?? '--:--');
          _tracker.markCheckedOut(
            householdId: hid,
            time: outTime,
            duration: _computeDuration(inTime, outTime),
          );
        } else if (inTime != null) {
          try {
            final parts = inTime.split(':').map(int.parse).toList();
            final now = DateTime.now();
            final checkInDate = DateTime(
              now.year,
              now.month,
              now.day,
              parts[0],
              parts[1],
              parts.length > 2 ? parts[2] : 0,
            );
            _tracker.markCheckedIn(householdId: hid, time: inTime, checkInDateTime: checkInDate);
          } catch (_) {
            _tracker.markCheckedIn(householdId: hid, time: inTime);
          }
        }
      }
    } catch (_) {
      // Retain local offline state
    }
  }


  String _computeDuration(String? inTime, String? outTime) {
    if (inTime == null || outTime == null) return '';
    try {
      final inParts = inTime.split(':').map(int.parse).toList();
      final outParts = outTime.split(':').map(int.parse).toList();
      int diffMinutes = (outParts[0] * 60 + outParts[1]) - (inParts[0] * 60 + inParts[1]);
      if (diffMinutes < 0) diffMinutes += 24 * 60;
      final hrs = diffMinutes ~/ 60;
      final mins = diffMinutes % 60;
      return hrs > 0 ? '${hrs}h ${mins}m' : '${mins}m';
    } catch (_) {
      return '';
    }
  }

  /// Calibrates household geofence to current GPS coordinates via Clean Architecture Use Case
  Future<void> _calibrateToCurrentLocation() async {
    setState(() => _isCalibrating = true);
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final updatedHousehold = await sl.calibrateGeofenceUseCase.execute(
        employerId: widget.user.id,
        houseName: 'Live Household (Calibrated)',
        latitude: pos.latitude,
        longitude: pos.longitude,
        geofenceRadiusMeters: 50,
        dwellTimeMinutes: 3,
      );

      if (mounted) {
        setState(() {
          _targetHouseholdId = updatedHousehold.id;
          _targetHouseName = updatedHousehold.houseName;
          _isCalibrating = false;
        });

        _tracker.updateTarget(
          lat: pos.latitude,
          lon: pos.longitude,
          radiusMeters: updatedHousehold.geofenceRadiusMeters.toDouble(),
          dwellSeconds: updatedHousehold.dwellTimeMinutes * 60,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📍 Geofence calibrated to live GPS: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}',
            ),
            backgroundColor: AppColors.present,
          ),
        );
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
              if (isEmployer)
                IconButton(
                  icon: const Icon(Icons.qr_code_2_rounded),
                  tooltip: 'Household Invite Code & QR',
                  onPressed: _showHouseholdInviteModal,
                )
              else
                IconButton(
                  icon: const Icon(Icons.account_circle_rounded),
                  tooltip: 'Maid Profile & Work Settings',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MaidProfileSetupPage(
                          maidId: widget.user.id,
                          initialName: widget.user.fullName,
                          initialPhone: widget.user.phoneNumber,
                        ),
                      ),
                    );
                  },
                ),
              NotificationBellAction(
                userId: widget.user.id,
                isContrast: isContrast,
                a11y: a11y,
              ),
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

                // Society Multi-Household Quick Selector Tabs
                if (_tracker.assignedHouseholds.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: HouseholdSelectorTabs(
                      households: _tracker.assignedHouseholds,
                      selectedHousehold: _tracker.activeHousehold,
                      householdDistances: _tracker.householdDistances,
                      isContrast: isContrast,
                      onSelect: (h) {
                        setState(() {
                          _targetHouseholdId = h.id;
                          _targetHouseName = h.houseName;
                        });
                        _tracker.setActiveHousehold(h);
                      },
                    ),
                  ),

                Expanded(
                  child: BlocConsumer<AttendanceBloc, AttendanceState>(

                    listener: (context, state) {
                      if (state is CheckInSuccess) {
                        final timeStr = state.log.checkInTime ??
                            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
                        _tracker.markCheckedIn(householdId: state.log.householdId, time: timeStr);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ ${state.message} (${state.log.status.name.toUpperCase()})'),
                            backgroundColor: AppColors.present,
                          ),
                        );
                      } else if (state is OfflineLogBuffered) {
                        final timeStr = state.log.checkInTime ??
                            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
                        _tracker.markCheckedIn(householdId: state.log.householdId, time: timeStr);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('📦 ${state.message} (${state.totalQueued} ${a11y.tr('pending_sync')})'),
                            backgroundColor: Colors.blueGrey,
                          ),
                        );
                      } else if (state is CheckOutSuccess) {
                        final timeStr = state.log.checkOutTime ??
                            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
                        final durStr = _computeDuration(_tracker.checkInTimeString, timeStr);
                        _tracker.markCheckedOut(
                          householdId: state.log.householdId,
                          time: timeStr,
                          duration: durStr.isNotEmpty ? durStr : _tracker.formatElapsedDuration(_tracker.elapsedWorkSeconds),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🏁 ${state.message}'),
                            backgroundColor: AppColors.present,
                            duration: const Duration(seconds: 5),
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
                          _tracker.markCheckedIn(householdId: _targetHouseholdId, time: '08:00 AM');
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
                              if (_tracker.isInsideGeofence &&
                                  _tracker.dwellCountdown < _tracker.requiredDwellSeconds &&
                                  !_tracker.hasCheckedInToday) ...[
                                Ux4gStatusBanner(
                                  variant: Ux4gBannerVariant.warningLight,
                                  title: '${a11y.tr('dwell_counting')} (${_tracker.dwellCountdown} / ${_tracker.requiredDwellSeconds}s)...',
                                  leadingIcon: const Icon(Icons.timer_outlined, color: Color(0xFFC47400)),
                                ),
                                const SizedBox(height: 12),
                              ],

                              if (_tracker.isMockGpsDetected) ...[
                                const Ux4gStatusBanner(
                                  variant: Ux4gBannerVariant.errorLight,
                                  title: '⚠️ GIGW Security Alert: Real Hardware Mock/Spoofed Location Detected (position.isMocked = true)',
                                  leadingIcon: Icon(Icons.security_outlined, color: Color(0xFFC5221F)),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Active Work Session / Departure Banners & Cards
                              if (_tracker.isCheckedOutToday) ...[
                                WorkCompletedCard(
                                  checkInTimeString: _tracker.checkInTimeString,
                                  checkOutTimeString: _tracker.checkOutTimeString,
                                  workDurationString: _tracker.workDurationString,
                                  isContrast: isContrast,
                                ),
                                const SizedBox(height: 14),
                              ] else if (_tracker.hasCheckedInToday) ...[
                                if (_tracker.isInsideGeofence) ...[
                                  WorkInProgressCard(
                                    checkInTimeString: _tracker.checkInTimeString,
                                    distanceMeters: _tracker.currentDistanceMeters,
                                    elapsedDurationString: _tracker.formatElapsedDuration(_tracker.elapsedWorkSeconds),
                                    isContrast: isContrast,
                                  ),
                                  const SizedBox(height: 14),
                                ] else ...[
                                  DepartureCountdownBanner(
                                    departureCountdown: _tracker.departureCountdown,
                                    distanceMeters: _tracker.currentDistanceMeters,
                                    geofenceRadiusMeters: _tracker.geofenceRadiusMeters,
                                    isContrast: isContrast,
                                  ),
                                  const SizedBox(height: 14),
                                ],
                              ],

                              // UX4G Attendance Verification Pipeline Stepper
                              _buildAttendanceStepper(a11y, isContrast, state),
                              const SizedBox(height: 16),

                              // Multi-Household Society Presence Radar Card (Auto-Switch & Parallel Distances)
                              MultiHouseholdRadarCard(
                                controller: _tracker,
                                isContrast: isContrast,
                                a11y: a11y,
                                onHouseholdSelected: (h) {
                                  setState(() {
                                    _targetHouseholdId = h.id;
                                    _targetHouseName = h.houseName;
                                  });
                                  _tracker.setActiveHousehold(h);
                                },
                              ),
                              const SizedBox(height: 16),


                              // Real-Time GPS & Hardware Telemetry Card (Modularized)
                              HardwareTelemetryCard(
                                currentPosition: _tracker.currentPosition,
                                isLoadingGps: _tracker.isLoadingGps,
                                gpsStatusInfo: _tracker.gpsStatusInfo,
                                currentDistanceMeters: _tracker.currentDistanceMeters,
                                geofenceRadiusMeters: _tracker.geofenceRadiusMeters,
                                targetHouseName: _targetHouseName,
                                targetLat: _tracker.targetLat,
                                targetLon: _tracker.targetLon,
                                isInsideGeofence: _tracker.isInsideGeofence,
                                isMockGpsDetected: _tracker.isMockGpsDetected,
                                hasCheckedInToday: _tracker.hasCheckedInToday,
                                requiredDwellSeconds: _tracker.requiredDwellSeconds,
                                isEmployer: isEmployer,
                                isCalibrating: _isCalibrating,
                                onCalibrate: _calibrateToCurrentLocation,
                                a11y: a11y,
                                isContrast: isContrast,
                              ),
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
                                  ] else ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildActionCard(
                                        title: 'Profile & Payout',
                                        subtitle: 'UPI, Work & Homes',
                                        icon: Icons.account_circle_rounded,
                                        color: AppColors.secondary,
                                        isContrast: isContrast,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MaidProfileSetupPage(
                                                maidId: widget.user.id,
                                                initialName: widget.user.fullName,
                                                initialPhone: widget.user.phoneNumber,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (isEmployer) ...[
                                const SizedBox(height: 12),
                                _buildActionCard(
                                  title: 'Invite Maid (आमंत्रण कोड)',
                                  subtitle: 'Code: $_inviteCode • Tap to view QR & Share',
                                  icon: Icons.qr_code_2_rounded,
                                  color: AppColors.present,
                                  isContrast: isContrast,
                                  onTap: _showHouseholdInviteModal,
                                ),
                              ],
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
    final isStep3Error = _tracker.isMockGpsDetected && _tracker.dwellCountdown >= _tracker.requiredDwellSeconds;

    if (_tracker.isCheckedOutToday) {
      currentStep = 4;
    } else if (_tracker.hasCheckedInToday || state is CheckInSuccess || state is OfflineLogBuffered) {
      currentStep = 3;
    } else if (_tracker.isInsideGeofence) {
      if (_tracker.dwellCountdown >= _tracker.requiredDwellSeconds) {
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
                  color: isContrast ? Colors.yellow : AppColors.primary.withOpacity(0.08),
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
                title: 'Shift Active',
                description: _tracker.hasCheckedInToday
                    ? (_tracker.isCheckedOutToday
                        ? 'Completed'
                        : 'Working ${_tracker.formatElapsedDuration(_tracker.elapsedWorkSeconds)}')
                    : a11y.tr('step_audit_desc'),
                isError: isStep3Error,
              ),
              Ux4gStepItem(
                title: 'Auto Check-Out',
                description: _tracker.isCheckedOutToday
                    ? 'Departure Logged (${_tracker.workDurationString.isNotEmpty ? _tracker.workDurationString : "Verified"})'
                    : '60s Buffer on Exit',
              ),
            ],
          ),
        ],
      ),
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

  void _showHouseholdInviteModal() {
    final a11y = AccessibilityController.instance;
    final isContrast = a11y.isHighContrast;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isContrast ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isContrast ? Colors.yellow : Colors.transparent),
          ),
          title: Row(
            children: [
              Icon(Icons.qr_code_2_rounded, color: isContrast ? Colors.yellow : AppColors.primary, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Household Invite Code',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isContrast ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Have your maid scan this QR or enter the code below in their app to link with "$_targetHouseName".',
                  style: TextStyle(
                    fontSize: 13,
                    color: isContrast ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: QrImageView(
                    data: 'MAID_INVITE:$_inviteCode',
                    version: QrVersions.auto,
                    size: 160.0,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isContrast ? Colors.grey.shade900 : AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isContrast ? Colors.yellow : AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _inviteCode,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              color: isContrast ? Colors.yellow : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Copy Code',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.copy_rounded, color: isContrast ? Colors.yellow : AppColors.primary, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _inviteCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Invite code "$_inviteCode" copied!'),
                              backgroundColor: AppColors.present,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }
}
