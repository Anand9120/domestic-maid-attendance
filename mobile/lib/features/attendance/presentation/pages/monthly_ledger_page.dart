import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.maidName} - Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MonthlyReportLoaded) {
            final report = state.report;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Month Header
                  Text(
                    'Attendance & Salary Ledger ($_month/$_year)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metrics Summary Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Working Days',
                          value: '${report.totalWorkingDays}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Present Days',
                          value: '${report.presentDays}',
                          color: AppColors.present,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Late Check-ins',
                          value: '${report.lateDays}',
                          color: AppColors.late,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Half Days',
                          value: '${report.halfDays}',
                          color: AppColors.halfDay,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Absent Days',
                          value: '${report.absentDays}',
                          color: AppColors.absent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'Deduction Days',
                          value: '${report.calculatedDeductions.toStringAsFixed(1)}d',
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Calendar Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visual Monthly Calendar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        MonthlyCalendarGrid(
                          year: _year,
                          month: _month,
                          logs: report.dailyLogs,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recent Records
                  const Text(
                    'Daily Attendance Entries',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (report.dailyLogs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'No check-in records found for this month.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...report.dailyLogs.map((log) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${log.attendanceDate.day}/${log.attendanceDate.month}/${log.attendanceDate.year} - ${log.checkInTime ?? "08:00 AM"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (log.overrideByEmployerName != null) ...[
                                  Text(
                                    'Overridden by: ${log.overrideByEmployerName}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                                  ),
                                ],
                              ],
                            ),
                            StatusBadge(
                              status: log.status,
                              entryType: log.entryType,
                              isMock: log.isMockLocation,
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          }

          return const Center(child: Text('Loading monthly ledger...'));
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
