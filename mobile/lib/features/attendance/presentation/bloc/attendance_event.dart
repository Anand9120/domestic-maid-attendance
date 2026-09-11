import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_log_entity.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class CheckInEventTriggered extends AttendanceEvent {
  final int maidId;
  final int householdId;
  final int? shiftId;
  final double latitude;
  final double longitude;
  final DateTime deviceTimestamp;
  final bool isMockLocation;
  final int dwellTimeSeconds;

  const CheckInEventTriggered({
    required this.maidId,
    required this.householdId,
    this.shiftId,
    required this.latitude,
    required this.longitude,
    required this.deviceTimestamp,
    this.isMockLocation = false,
    this.dwellTimeSeconds = 180,
  });

  @override
  List<Object?> get props => [
        maidId,
        householdId,
        shiftId,
        latitude,
        longitude,
        deviceTimestamp,
        isMockLocation,
        dwellTimeSeconds,
      ];
}

class SyncOfflineLogsEvent extends AttendanceEvent {}

class FetchMonthlyReportEvent extends AttendanceEvent {
  final int maidId;
  final int year;
  final int month;

  const FetchMonthlyReportEvent({
    required this.maidId,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [maidId, year, month];
}

class ManualOverrideSubmitted extends AttendanceEvent {
  final int maidId;
  final int householdId;
  final int? shiftId;
  final DateTime attendanceDate;
  final String? checkInTime;
  final AttendanceStatus status;
  final int employerId;
  final String? notes;

  const ManualOverrideSubmitted({
    required this.maidId,
    required this.householdId,
    this.shiftId,
    required this.attendanceDate,
    this.checkInTime,
    this.status = AttendanceStatus.present,
    required this.employerId,
    this.notes,
  });

  @override
  List<Object?> get props => [
        maidId,
        householdId,
        shiftId,
        attendanceDate,
        checkInTime,
        status,
        employerId,
        notes,
      ];
}
