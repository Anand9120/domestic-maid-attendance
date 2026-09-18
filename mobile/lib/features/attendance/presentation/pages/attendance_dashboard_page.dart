import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
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
  bool _isInsideGeofence = false;
  int _dwellCountdown = 0;
  Timer? _timer;
  bool _simulateMockGps = false;

  // Household coordinates (Sharma Residence: 28.6315000, 77.2167000)
  final double _targetLat = 28.6315000;
  final double _targetLon = 77.2167000;
  final int _targetHouseholdId = 1;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _simulateGeofenceEntry() {
    setState(() {
      _isInsideGeofence = true;
      _dwellCountdown = 0;
    });

    _timer?.cancel();
    // Simulate 3-minute dwell time counter (accelerated for interactive demo)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _dwellCountdown += 60; // 60s per tick -> reaches 180s in 3 seconds
      });

      if (_dwellCountdown >= 180) {
        timer.cancel();
        // 3-minute dwell time met! Dispatch automated arrival check-in (PRD US-M01)
        context.read<AttendanceBloc>().add(
              CheckInEventTriggered(
                maidId: widget.user.id,
                householdId: _targetHouseholdId,
                latitude: _targetLat,
                longitude: _targetLon,
                deviceTimestamp: DateTime.now(),
                isMockLocation: _simulateMockGps,
                dwellTimeSeconds: 180,
              ),
            );
      }
    });
  }

  void _simulateGeofenceExit() {
    _timer?.cancel();
    setState(() {
      _isInsideGeofence = false;
      _dwellCountdown = 0;
    });
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
                              if (_isInsideGeofence && _dwellCountdown < 180) ...[
                                Ux4gStatusBanner(
                                  variant: Ux4gBannerVariant.warningLight,
                                  title: '${a11y.tr('dwell_counting')} ($_dwellCountdown / 180s)...',
                                  leadingIcon: const Icon(Icons.timer_outlined, color: Color(0xFFC47400)),
                                ),
                                const SizedBox(height: 12),
                              ],

                              if (_simulateMockGps) ...[
                                const Ux4gStatusBanner(
                                  variant: Ux4gBannerVariant.errorLight,
                                  title: '⚠️ GIGW Security Alert: Mock GPS Location Simulation Active',
                                  leadingIcon: Icon(Icons.security_outlined, color: Color(0xFFC5221F)),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // UX4G Attendance Verification Pipeline Stepper
                              _buildAttendanceStepper(a11y, isContrast, state),
                              const SizedBox(height: 16),

                              // Geofence Radar Card
                              _buildGeofenceCard(a11y, isContrast),
                              const SizedBox(height: 16),

                              // Hardware & Location Simulator Card
                              _buildSimulationControls(a11y, isContrast),
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
    final isStep3Error = _simulateMockGps && _dwellCountdown >= 180;

    if (state is CheckInSuccess || state is OfflineLogBuffered) {
      currentStep = 4;
    } else if (_isInsideGeofence) {
      if (_dwellCountdown >= 180) {
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
                          ? a11y.tr('inside_geofence')
                          : a11y.tr('outside_geofence'),
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
                value: _dwellCountdown / 180.0,
                minHeight: 8,
                backgroundColor: isContrast ? Colors.white24 : AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _dwellCountdown >= 180
                      ? (isContrast ? Colors.yellow : AppColors.present)
                      : (isContrast ? Colors.amber : AppColors.late),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dwellCountdown >= 180 ? a11y.tr('dwell_completed') : a11y.tr('dwell_counting'),
                  style: TextStyle(
                    fontSize: 11,
                    color: isContrast ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$_dwellCountdown / 180s',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _dwellCountdown >= 180
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

  Widget _buildSimulationControls(AccessibilityController a11y, bool isContrast) {
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
          Text(
            '50m OS Geofence & Location Simulator',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isContrast ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Simulate device location entry into 50m radius with 3-minute dwell verification.',
            style: TextStyle(
              fontSize: 12,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Primary Simulator Button (Ux4gButton)
          SizedBox(
            width: double.infinity,
            child: Ux4gButton(
              text: _isInsideGeofence ? a11y.tr('exit_geofence') : a11y.tr('enter_geofence'),
              variant: _isInsideGeofence ? Ux4gButtonVariant.secondary : Ux4gButtonVariant.primary,
              size: Ux4gButtonSize.large,
              leadingIcon: _isInsideGeofence ? Icons.exit_to_app : Icons.login,
              onPressed: _isInsideGeofence ? _simulateGeofenceExit : _simulateGeofenceEntry,
            ),
          ),
          const SizedBox(height: 12),

          // Mock Location Switch
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Simulate Fake / Mock GPS Location',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isContrast ? Colors.white : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'PRD US-S01: Flags security alert if spoofing detected',
                style: TextStyle(
                  fontSize: 11,
                  color: isContrast ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              value: _simulateMockGps,
              activeColor: isContrast ? Colors.yellow : AppColors.absent,
              onChanged: (val) {
                setState(() => _simulateMockGps = val);
              },
            ),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isContrast ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: StatusBadge(
                  status: log.status,
                  entryType: log.entryType,
                  isMock: log.isMockLocation,
                ),
              ),
            ],
          ),
          Divider(height: 20, color: isContrast ? Colors.white24 : AppColors.border),
          Text(
            '${a11y.tr('checkin_time')}: ${log.checkInTime ?? "Recorded"}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isContrast ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${a11y.tr('entry_type')}: ${log.entryType.name.toUpperCase()}',
            style: TextStyle(
              fontSize: 12,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
