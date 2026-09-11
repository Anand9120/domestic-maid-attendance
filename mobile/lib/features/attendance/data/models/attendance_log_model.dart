import '../../domain/entities/attendance_log_entity.dart';

class AttendanceLogModel extends AttendanceLogEntity {
  const AttendanceLogModel({
    super.id,
    required super.maidId,
    super.maidName,
    required super.householdId,
    super.houseName,
    super.shiftId,
    super.shiftName,
    required super.attendanceDate,
    super.checkInTime,
    super.checkOutTime,
    super.status,
    super.entryType,
    required super.deviceTimestamp,
    super.isMockLocation,
    super.overrideByEmployerName,
  });

  factory AttendanceLogModel.fromJson(Map<String, dynamic> json) {
    AttendanceStatus parsedStatus = AttendanceStatus.present;
    final statusStr = json['status']?.toString().toUpperCase();
    if (statusStr == 'LATE') {
      parsedStatus = AttendanceStatus.late;
    } else if (statusStr == 'HALF_DAY') {
      parsedStatus = AttendanceStatus.halfDay;
    } else if (statusStr == 'ABSENT') {
      parsedStatus = AttendanceStatus.absent;
    }

    EntryType parsedEntry = EntryType.automatedGeofence;
    final entryStr = json['entryType']?.toString().toUpperCase();
    if (entryStr == 'OFFLINE_SYNC') {
      parsedEntry = EntryType.offlineSync;
    } else if (entryStr == 'MANUAL_OVERRIDE') {
      parsedEntry = EntryType.manualOverride;
    }

    DateTime parsedDate;
    if (json['attendanceDate'] != null) {
      parsedDate = DateTime.tryParse(json['attendanceDate'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    DateTime parsedDeviceTime;
    if (json['deviceTimestamp'] != null) {
      parsedDeviceTime = DateTime.tryParse(json['deviceTimestamp'].toString()) ?? DateTime.now();
    } else {
      parsedDeviceTime = DateTime.now();
    }

    return AttendanceLogModel(
      id: json['id'] as int?,
      maidId: (json['maidId'] ?? 0) as int,
      maidName: json['maidName'] as String?,
      householdId: (json['householdId'] ?? 0) as int,
      houseName: json['houseName'] as String?,
      shiftId: json['shiftId'] as int?,
      shiftName: json['shiftName'] as String?,
      attendanceDate: parsedDate,
      checkInTime: json['checkInTime']?.toString(),
      checkOutTime: json['checkOutTime']?.toString(),
      status: parsedStatus,
      entryType: parsedEntry,
      deviceTimestamp: parsedDeviceTime,
      isMockLocation: json['isMockLocation'] == true,
      overrideByEmployerName: json['overrideByEmployerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maidId': maidId,
      'maidName': maidName,
      'householdId': householdId,
      'houseName': houseName,
      'shiftId': shiftId,
      'shiftName': shiftName,
      'attendanceDate': attendanceDate.toIso8601String().substring(0, 10),
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status.name.toUpperCase(),
      'entryType': entryType.name.toUpperCase(),
      'deviceTimestamp': deviceTimestamp.toIso8601String(),
      'isMockLocation': isMockLocation,
      'overrideByEmployerName': overrideByEmployerName,
    };
  }
}
