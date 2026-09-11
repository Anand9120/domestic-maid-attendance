import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/features/attendance/domain/entities/attendance_log_entity.dart';
import 'package:maid_attendance/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/check_in_usecase.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/get_monthly_report_usecase.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/manual_override_usecase.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/sync_offline_logs_usecase.dart';
import 'package:maid_attendance/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:maid_attendance/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:maid_attendance/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}
class MockCheckInUseCase extends Mock implements CheckInUseCase {}
class MockSyncOfflineLogsUseCase extends Mock implements SyncOfflineLogsUseCase {}
class MockGetMonthlyReportUseCase extends Mock implements GetMonthlyReportUseCase {}
class MockManualOverrideUseCase extends Mock implements ManualOverrideUseCase {}

void main() {
  late MockAttendanceRepository mockRepository;
  late MockCheckInUseCase mockCheckInUseCase;
  late MockSyncOfflineLogsUseCase mockSyncOfflineLogsUseCase;
  late MockGetMonthlyReportUseCase mockGetMonthlyReportUseCase;
  late MockManualOverrideUseCase mockManualOverrideUseCase;
  late AttendanceBloc attendanceBloc;

  setUp(() {
    mockRepository = MockAttendanceRepository();
    mockCheckInUseCase = MockCheckInUseCase();
    mockSyncOfflineLogsUseCase = MockSyncOfflineLogsUseCase();
    mockGetMonthlyReportUseCase = MockGetMonthlyReportUseCase();
    mockManualOverrideUseCase = MockManualOverrideUseCase();

    attendanceBloc = AttendanceBloc(
      checkInUseCase: mockCheckInUseCase,
      syncOfflineLogsUseCase: mockSyncOfflineLogsUseCase,
      getMonthlyReportUseCase: mockGetMonthlyReportUseCase,
      manualOverrideUseCase: mockManualOverrideUseCase,
      repository: mockRepository,
    );
  });

  tearDown(() {
    attendanceBloc.close();
  });

  group('AttendanceBloc Tests', () {
    final testDate = DateTime(2026, 9, 12, 7, 35);
    final successLog = AttendanceLogEntity(
      id: 101,
      maidId: 2,
      maidName: 'Sunita Devi',
      householdId: 1,
      houseName: 'Sharma Residence',
      attendanceDate: testDate,
      checkInTime: '07:35',
      status: AttendanceStatus.present,
      entryType: EntryType.automatedGeofence,
      deviceTimestamp: testDate,
      isMockLocation: false,
    );

    blocTest<AttendanceBloc, AttendanceState>(
      'emits [AttendanceLoading, CheckInSuccess] on successful geofenced check-in',
      build: () {
        when(() => mockCheckInUseCase.execute(
              maidId: 2,
              householdId: 1,
              shiftId: any(named: 'shiftId'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              deviceTimestamp: any(named: 'deviceTimestamp'),
              isMockLocation: false,
              dwellTimeSeconds: 180,
            )).thenAnswer((_) async => successLog);
        return attendanceBloc;
      },
      act: (bloc) => bloc.add(CheckInEventTriggered(
        maidId: 2,
        householdId: 1,
        latitude: 28.6315,
        longitude: 77.2167,
        deviceTimestamp: testDate,
        isMockLocation: false,
        dwellTimeSeconds: 180,
      )),
      expect: () => [
        AttendanceLoading(),
        CheckInSuccess(successLog),
      ],
    );

    blocTest<AttendanceBloc, AttendanceState>(
      'emits [AttendanceLoading, OfflineLogBuffered] when check-in is buffered offline',
      build: () {
        final offlineLog = AttendanceLogEntity(
          maidId: 2,
          householdId: 1,
          attendanceDate: testDate,
          checkInTime: '07:35',
          status: AttendanceStatus.present,
          entryType: EntryType.offlineSync,
          deviceTimestamp: testDate,
        );
        when(() => mockCheckInUseCase.execute(
              maidId: 2,
              householdId: 1,
              shiftId: any(named: 'shiftId'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              deviceTimestamp: any(named: 'deviceTimestamp'),
              isMockLocation: false,
              dwellTimeSeconds: 180,
            )).thenAnswer((_) async => offlineLog);
        when(() => mockRepository.getQueuedCount()).thenAnswer((_) async => 1);
        return attendanceBloc;
      },
      act: (bloc) => bloc.add(CheckInEventTriggered(
        maidId: 2,
        householdId: 1,
        latitude: 28.6315,
        longitude: 77.2167,
        deviceTimestamp: testDate,
        isMockLocation: false,
        dwellTimeSeconds: 180,
      )),
      expect: () => [
        AttendanceLoading(),
        isA<OfflineLogBuffered>(),
      ],
    );

    blocTest<AttendanceBloc, AttendanceState>(
      'emits [AttendanceLoading, SyncSuccessState] on SyncOfflineLogsEvent',
      build: () {
        when(() => mockSyncOfflineLogsUseCase.execute()).thenAnswer((_) async => 2);
        return attendanceBloc;
      },
      act: (bloc) => bloc.add(SyncOfflineLogsEvent()),
      expect: () => [
        AttendanceLoading(),
        const SyncSuccessState(2),
      ],
    );
  });
}
