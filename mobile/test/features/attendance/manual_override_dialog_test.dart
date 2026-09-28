import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/check_in_usecase.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/check_out_usecase.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/get_monthly_report_usecase.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/manual_override_usecase.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/sync_offline_logs_usecase.dart';
import 'package:maid_attendance/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:maid_attendance/features/attendance/presentation/widgets/manual_override_dialog.dart';
import 'package:mocktail/mocktail.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}
class MockCheckInUseCase extends Mock implements CheckInUseCase {}
class MockCheckOutUseCase extends Mock implements CheckOutUseCase {}
class MockSyncOfflineLogsUseCase extends Mock implements SyncOfflineLogsUseCase {}
class MockGetMonthlyReportUseCase extends Mock implements GetMonthlyReportUseCase {}
class MockManualOverrideUseCase extends Mock implements ManualOverrideUseCase {}

void main() {
  late AttendanceBloc attendanceBloc;
  late MockAttendanceRepository mockRepository;
  late MockCheckInUseCase mockCheckIn;
  late MockCheckOutUseCase mockCheckOut;
  late MockSyncOfflineLogsUseCase mockSync;
  late MockGetMonthlyReportUseCase mockReport;
  late MockManualOverrideUseCase mockOverride;

  setUp(() {
    mockRepository = MockAttendanceRepository();
    mockCheckIn = MockCheckInUseCase();
    mockCheckOut = MockCheckOutUseCase();
    mockSync = MockSyncOfflineLogsUseCase();
    mockReport = MockGetMonthlyReportUseCase();
    mockOverride = MockManualOverrideUseCase();

    attendanceBloc = AttendanceBloc(
      checkInUseCase: mockCheckIn,
      checkOutUseCase: mockCheckOut,
      syncOfflineLogsUseCase: mockSync,
      getMonthlyReportUseCase: mockReport,
      manualOverrideUseCase: mockOverride,
      repository: mockRepository,
    );
  });

  tearDown(() {
    attendanceBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<AttendanceBloc>.value(
          value: attendanceBloc,
          child: const ManualOverrideDialog(
            employerId: 1,
            householdId: 101,
            defaultMaidId: 2,
            defaultMaidName: 'Sunita Devi',
          ),
        ),
      ),
    );
  }

  testWidgets('renders ManualOverrideDialog with date selection chips and today as default', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify dialog title and maid name
    expect(find.textContaining('Sunita Devi'), findsOneWidget);

    // Verify date selection chips
    expect(find.widgetWithText(ChoiceChip, 'Today'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Yesterday'), findsOneWidget);
    expect(find.textContaining('Pick Other Date'), findsOneWidget);

    // Past date badge should not be visible when today is selected
    expect(find.text('Past Date Entry'), findsNothing);
  });

  testWidgets('selecting Yesterday updates date and shows Past Date Entry badge', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Tap the Yesterday chip
    final yesterdayChip = find.widgetWithText(ChoiceChip, 'Yesterday');
    expect(yesterdayChip, findsOneWidget);
    await tester.tap(yesterdayChip);
    await tester.pumpAndSettle();

    // Past date badge should now be visible
    expect(find.text('Past Date Entry'), findsOneWidget);
  });

  testWidgets('renders status options and preset reason quick-chips', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('PRESENT'), findsOneWidget);
    expect(find.text('LATE'), findsOneWidget);
    expect(find.text('HALF DAY'), findsOneWidget);
    expect(find.text('ABSENT'), findsOneWidget);
    expect(find.text('Keypad / Feature Phone (No GPS)'), findsOneWidget);
  });
}
