import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ux4g_civic_bar.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/calendar_view.dart';
import '../widgets/status_badge.dart';

class MonthlyLedgerPage extends StatefulWidget {
  final int maidId;
  final String maidName;

  const MonthlyLedgerPage({
    super.key,
    required this.maidId,
    required this.maidName,
  });

  @override
  State<MonthlyLedgerPage> createState() => _MonthlyLedgerPageState();
}

class _MonthlyLedgerPageState extends State<MonthlyLedgerPage> {
  final int _year = DateTime.now().year;
  final int _month = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<AttendanceBloc>().add(
          FetchMonthlyReportEvent(
            maidId: widget.maidId,
            year: _year,
            month: _month,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;

    return ListenableBuilder(
      listenable: a11y,
      builder: (context, _) {
        final isContrast = a11y.isHighContrast;

        return Scaffold(
          backgroundColor: isContrast ? AppColors.hcBackground : AppColors.background,
          appBar: AppBar(
            backgroundColor: isContrast ? Colors.black : AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
              '${widget.maidName} - ${a11y.tr('view_ledger')}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Ledger',
                onPressed: _loadReport,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const Ux4gCivicBar(showTitle: false),
                Expanded(
                  child: BlocBuilder<AttendanceBloc, AttendanceState>(
                    builder: (context, state) {
                      if (state is AttendanceLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is MonthlyReportLoaded) {
                        final report = state.report;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(18),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Month Header
                                Text(
                                  '$_month/$_year Attendance & Salary Ledger',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isContrast ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Metrics Summary Grid
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('working_days'),
                                        value: '${report.totalWorkingDays}',
                                        color: AppColors.primary,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('present_days'),
                                        value: '${report.presentDays}',
                                        color: AppColors.present,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('late_days'),
                                        value: '${report.lateDays}',
                                        color: AppColors.late,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('status_half_day'),
                                        value: '${report.halfDays}',
                                        color: AppColors.halfDay,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('absent_days'),
                                        value: '${report.absentDays}',
                                        color: AppColors.absent,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: 'Deduction',
                                        value: '${report.calculatedDeductions.toStringAsFixed(1)}d',
                                        color: isContrast ? Colors.yellow : Colors.deepOrange,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Calendar Card
                                Container(
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
                                        'Visual Monthly Calendar',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isContrast ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      MonthlyCalendarGrid(
                                        year: _year,
                                        month: _month,
                                        logs: report.dailyLogs,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Recent Records
                                Text(
                                  'Daily Attendance Entries',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isContrast ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (report.dailyLogs.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isContrast ? AppColors.hcSurface : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isContrast ? AppColors.hcBorder : AppColors.border,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No check-in records found for this month.',
                                        style: TextStyle(
                                          color: isContrast ? Colors.white70 : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...report.dailyLogs.map((log) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isContrast ? AppColors.hcSurface : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isContrast ? AppColors.hcBorder : AppColors.border,
                                          width: isContrast ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${log.attendanceDate.day}/${log.attendanceDate.month}/${log.attendanceDate.year} - ${log.checkInTime ?? "08:00 AM"}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: isContrast ? Colors.white : AppColors.textPrimary,
                                                  ),
                                                ),
                                                if (log.overrideByEmployerName != null) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Overridden: ${log.overrideByEmployerName}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: isContrast ? Colors.yellow : AppColors.secondary,
                                                    ),
                                                  ),
                                                ],
                                              ],
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
                                    );
                                  }),
                              ],
                            ),
                          ),
                        );
                      }

                      return const Center(child: Text('Loading monthly ledger...'));
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

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required bool isContrast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isContrast ? Colors.white10 : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isContrast ? Colors.yellow : color.withOpacity(0.2),
          width: isContrast ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isContrast ? Colors.yellow : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
