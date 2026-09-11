import 'package:equatable/equatable.dart';

enum AttendanceStatus {
  present,
  absent,
  late,
  halfDay,
}

enum EntryType {
  automatedGeofence,
  offlineSync,
  manualOverride,
}

class AttendanceLogEntity extends Equatable {
  final int? id;
  final int maidId;
  final String? maidName;
  final int householdId;
  final String? houseName;
  final int? shiftId;
  final String? shiftName;
  final DateTime attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final AttendanceStatus status;
  final EntryType entryType;
  final DateTime deviceTimestamp;
  final bool isMockLocation;
  final String? overrideByEmployerName;

  const AttendanceLogEntity({
    this.id,
    required this.maidId,
    this.maidName,
    required this.householdId,
    this.houseName,
    this.shiftId,
    this.shiftName,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.status = AttendanceStatus.present,
    this.entryType = EntryType.automatedGeofence,
    required this.deviceTimestamp,
    this.isMockLocation = false,
    this.overrideByEmployerName,
  });

  @override
  List<Object?> get props => [
        id,
        maidId,
        householdId,
        shiftId,
        attendanceDate,
        checkInTime,
        status,
        entryType,
        deviceTimestamp,
        isMockLocation,
      ];
}
