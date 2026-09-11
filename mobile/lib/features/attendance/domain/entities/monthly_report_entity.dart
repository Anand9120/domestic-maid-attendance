import 'package:equatable/equatable.dart';
import 'attendance_log_entity.dart';

class MonthlyReportEntity extends Equatable {
  final int maidId;
  final String maidName;
  final int month;
  final int year;
  final int totalDaysInMonth;
  final int totalWorkingDays;
  final int presentDays;
  final int lateDays;
  final int halfDays;
  final int absentDays;
  final double attendancePercentage;
  final double calculatedDeductions;
  final List<AttendanceLogEntity> dailyLogs;

  const MonthlyReportEntity({
    required this.maidId,
    required this.maidName,
    required this.month,
    required this.year,
    required this.totalDaysInMonth,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.lateDays,
    required this.halfDays,
    required this.absentDays,
    required this.attendancePercentage,
    required this.calculatedDeductions,
    required this.dailyLogs,
  });

  @override
  List<Object?> get props => [
        maidId,
        maidName,
        month,
        year,
        totalWorkingDays,
        presentDays,
        lateDays,
        halfDays,
        absentDays,
        attendancePercentage,
        calculatedDeductions,
      ];
}
