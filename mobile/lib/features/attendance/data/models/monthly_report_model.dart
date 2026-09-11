import '../../domain/entities/monthly_report_entity.dart';
import 'attendance_log_model.dart';

class MonthlyReportModel extends MonthlyReportEntity {
  const MonthlyReportModel({
    required super.maidId,
    required super.maidName,
    required super.month,
    required super.year,
    required super.totalDaysInMonth,
    required super.totalWorkingDays,
    required super.presentDays,
    required super.lateDays,
    required super.halfDays,
    required super.absentDays,
    required super.attendancePercentage,
    required super.calculatedDeductions,
    required super.dailyLogs,
  });

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    final dailyLogsRaw = (json['dailyLogs'] as List<dynamic>?) ?? [];
    final logs = dailyLogsRaw
        .map((e) => AttendanceLogModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MonthlyReportModel(
      maidId: (json['maidId'] ?? 0) as int,
      maidName: (json['maidName'] ?? '') as String,
      month: (json['month'] ?? 1) as int,
      year: (json['year'] ?? 2026) as int,
      totalDaysInMonth: (json['totalDaysInMonth'] ?? 30) as int,
      totalWorkingDays: (json['totalWorkingDays'] ?? 26) as int,
      presentDays: (json['presentDays'] ?? 0) as int,
      lateDays: (json['lateDays'] ?? 0) as int,
      halfDays: (json['halfDays'] ?? 0) as int,
      absentDays: (json['absentDays'] ?? 0) as int,
      attendancePercentage: (json['attendancePercentage'] is num)
          ? (json['attendancePercentage'] as num).toDouble()
          : 0.0,
      calculatedDeductions: (json['calculatedDeductions'] is num)
          ? (json['calculatedDeductions'] as num).toDouble()
          : 0.0,
      dailyLogs: logs,
    );
  }
}
