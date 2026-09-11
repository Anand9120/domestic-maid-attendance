import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_log_entity.dart';
import '../../domain/entities/monthly_report_entity.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class CheckInSuccess extends AttendanceState {
  final AttendanceLogEntity log;
  final String message;

  const CheckInSuccess(this.log, [this.message = 'Check-in recorded successfully!']);

  @override
  List<Object?> get props => [log, message];
}

class OfflineLogBuffered extends AttendanceState {
  final AttendanceLogEntity log;
  final int totalQueued;
  final String message;

  const OfflineLogBuffered({
    required this.log,
    required this.totalQueued,
    this.message = 'No network connection: Attendance saved in offline queue.',
  });

  @override
  List<Object?> get props => [log, totalQueued, message];
}

class SyncSuccessState extends AttendanceState {
  final int syncedCount;
  const SyncSuccessState(this.syncedCount);

  @override
  List<Object?> get props => [syncedCount];
}

class MonthlyReportLoaded extends AttendanceState {
  final MonthlyReportEntity report;
  const MonthlyReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class AttendanceFailure extends AttendanceState {
  final String error;
  const AttendanceFailure(this.error);

  @override
  List<Object?> get props => [error];
}
