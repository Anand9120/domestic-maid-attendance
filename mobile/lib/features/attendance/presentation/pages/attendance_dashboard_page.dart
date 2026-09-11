import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
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
    // Simulate 3-minute dwell time counter (accelerated to 3 seconds for smooth interactive demo)
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
    final isEmployer = widget.user.role == UserRole.employer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEmployer ? 'Employer Dashboard' : 'Maid Presence Dashboard',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.user.fullName} (${widget.user.role.name.toUpperCase()})',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync Offline Logs',
            onPressed: () {
              context.read<AttendanceBloc>().add(SyncOfflineLogsEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
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
                content: Text('📦 ${state.message} (Total Queued: ${state.totalQueued})'),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Geofence Radar Card
                _buildGeofenceCard(),
                const SizedBox(height: 20),

                // Anti-Spoofing & Simulator Controls
                _buildSimulationControls(),
                const SizedBox(height: 20),

                // Quick Navigation Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: 'Monthly Ledger',
                        subtitle: 'Salary & Presence',
                        icon: Icons.calendar_month_rounded,
                        color: AppColors.primary,
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
                          title: 'Manual Override',
                          subtitle: 'Keypad phone fallback',
                          icon: Icons.edit_calendar_rounded,
                          color: AppColors.secondary,
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
                const SizedBox(height: 24),

                // Recent Status Card
                if (state is CheckInSuccess) ...[
                  _buildRecentCheckInCard(state.log),
                ] else if (state is OfflineLogBuffered) ...[
                  _buildRecentCheckInCard(state.log),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeofenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isInsideGeofence
                      ? AppColors.present.withOpacity(0.1)
                      : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.radar_rounded,
                  size: 28,
                  color: _isInsideGeofence ? AppColors.present : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '50m OS Geofence Boundary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _isInsideGeofence
                          ? 'Inside boundary: Sharma Residence'
                          : 'Monitoring household targets...',
                      style: TextStyle(
                        fontSize: 13,
                        color: _isInsideGeofence ? AppColors.present : AppColors.textSecondary,
                        fontWeight: _isInsideGeofence ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Dwell Progress Indicator
          if (_isInsideGeofence) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _dwellCountdown / 180.0,
                minHeight: 10,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _dwellCountdown >= 180 ? AppColors.present : AppColors.late,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '3-Minute Dwell Validator:',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  '$_dwellCountdown / 180s (${(_dwellCountdown / 180 * 100).toInt()}%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _dwellCountdown >= 180 ? AppColors.present : AppColors.late,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimulationControls() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hardware & Location Simulator',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Test real-time OS geofence trigger, dwell filtering, and spoof detection.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isInsideGeofence ? AppColors.absent : AppColors.present,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(_isInsideGeofence ? Icons.exit_to_app : Icons.login),
                  label: Text(_isInsideGeofence ? 'Exit 50m Boundary' : 'Enter 50m Boundary'),
                  onPressed: _isInsideGeofence ? _simulateGeofenceExit : _simulateGeofenceEntry,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Simulate Mock Location (Fake GPS)'),
            subtitle: const Text('PRD US-S01: Flags security alert if enabled'),
            value: _simulateMockGps,
            activeColor: AppColors.absent,
            onChanged: (val) {
              setState(() => _simulateMockGps = val);
            },
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCheckInCard(dynamic log) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest Attendance Log',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              StatusBadge(
                status: log.status,
                entryType: log.entryType,
                isMock: log.isMockLocation,
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            'Check-in Time: ${log.checkInTime ?? "Recorded"}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Entry Type: ${log.entryType.name.toUpperCase()}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
