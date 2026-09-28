import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maid_attendance/features/attendance/presentation/widgets/manual_override_dialog.dart';
import 'package:maid_attendance/features/attendance/presentation/widgets/bulk_backfill_dialog.dart';
import 'package:maid_attendance/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:maid_attendance/features/attendance/presentation/bloc/attendance_state.dart';

class MockAttendanceBloc extends Mock implements AttendanceBloc {}

void main() {
  late MockAttendanceBloc mockAttendanceBloc;

  setUp(() {
    mockAttendanceBloc = MockAttendanceBloc();
    when(() => mockAttendanceBloc.state).thenReturn(AttendanceInitial());
    when(() => mockAttendanceBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('showDialog ManualOverrideDialog renders cleanly without constraints error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider<AttendanceBloc>.value(
                    value: mockAttendanceBloc,
                    child: const ManualOverrideDialog(
                      employerId: 1,
                      householdId: 1,
                    ),
                  ),
                );
              },
              child: const Text('Open Manual Override'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Manual Override'));
    await tester.pumpAndSettle();
    expect(find.byType(ManualOverrideDialog), findsOneWidget);
  });

  testWidgets('showDialog BulkBackfillDialog renders cleanly without constraints error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider<AttendanceBloc>.value(
                    value: mockAttendanceBloc,
                    child: BulkBackfillDialog(
                      employerId: 1,
                      householdId: 1,
                      maidId: 2,
                      maidName: 'Sunita Devi',
                      year: 2026,
                      month: 9,
                      existingLogs: const [],
                      onCompleted: () {},
                    ),
                  ),
                );
              },
              child: const Text('Open Bulk Backfill'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Bulk Backfill'));
    await tester.pumpAndSettle();
    expect(find.byType(BulkBackfillDialog), findsOneWidget);
  });
}
