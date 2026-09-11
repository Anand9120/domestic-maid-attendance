import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attendance_log_entity.dart';
import '../../domain/usecases/check_in_usecase.dart';
import '../../domain/usecases/get_monthly_report_usecase.dart';
import '../../domain/usecases/manual_override_usecase.dart';
import '../../domain/usecases/sync_offline_logs_usecase.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final CheckInUseCase checkInUseCase;
  final SyncOfflineLogsUseCase syncOfflineLogsUseCase;
  final GetMonthlyReportUseCase getMonthlyReportUseCase;
  final ManualOverrideUseCase manualOverrideUseCase;
  final AttendanceRepository repository;

  AttendanceBloc({
    required this.checkInUseCase,
    required this.syncOfflineLogsUseCase,
    required this.getMonthlyReportUseCase,
    required this.manualOverrideUseCase,
    required this.repository,
  }) : super(AttendanceInitial()) {
    on<CheckInEventTriggered>(_onCheckInTriggered);
    on<SyncOfflineLogsEvent>(_onSyncOfflineLogs);
    on<FetchMonthlyReportEvent>(_onFetchMonthlyReport);
    on<ManualOverrideSubmitted>(_onManualOverrideSubmitted);
  }

  Future<void> _onCheckInTriggered(
    CheckInEventTriggered event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final log = await checkInUseCase.execute(
        maidId: event.maidId,
        householdId: event.householdId,
        shiftId: event.shiftId,
        latitude: event.latitude,
        longitude: event.longitude,
        deviceTimestamp: event.deviceTimestamp,
        isMockLocation: event.isMockLocation,
        dwellTimeSeconds: event.dwellTimeSeconds,
      );

      if (log.entryType == EntryType.offlineSync) {
        final count = await repository.getQueuedCount();
        emit(OfflineLogBuffered(log: log, totalQueued: count));
      } else {
        emit(CheckInSuccess(log));
      }
    } catch (e) {
      emit(AttendanceFailure(e.toString()));
    }
  }

  Future<void> _onSyncOfflineLogs(
    SyncOfflineLogsEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final count = await syncOfflineLogsUseCase.execute();
      emit(SyncSuccessState(count));
    } catch (e) {
      emit(AttendanceFailure('Sync error: ${e.toString()}'));
    }
  }

  Future<void> _onFetchMonthlyReport(
    FetchMonthlyReportEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final report = await getMonthlyReportUseCase.execute(
        maidId: event.maidId,
        year: event.year,
        month: event.month,
      );
      emit(MonthlyReportLoaded(report));
    } catch (e) {
      emit(AttendanceFailure('Failed to load monthly ledger: ${e.toString()}'));
    }
  }

  Future<void> _onManualOverrideSubmitted(
    ManualOverrideSubmitted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final log = await manualOverrideUseCase.execute(
        maidId: event.maidId,
        householdId: event.householdId,
        shiftId: event.shiftId,
        attendanceDate: event.attendanceDate,
        checkInTime: event.checkInTime,
        status: event.status,
        employerId: event.employerId,
        notes: event.notes,
      );
      emit(CheckInSuccess(log, 'Manual override saved successfully!'));
    } catch (e) {
      emit(AttendanceFailure('Override failed: ${e.toString()}'));
    }
  }
}
