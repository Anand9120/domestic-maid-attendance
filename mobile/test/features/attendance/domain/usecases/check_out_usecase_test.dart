import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/features/attendance/domain/entities/attendance_log_entity.dart';
import 'package:maid_attendance/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:maid_attendance/features/attendance/domain/usecases/check_out_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

void main() {
  late CheckOutUseCase useCase;
  late MockAttendanceRepository mockRepository;

  setUp(() {
    mockRepository = MockAttendanceRepository();
    useCase = CheckOutUseCase(mockRepository);
  });

  group('CheckOutUseCase Unit Tests (TDD)', () {
    final testDate = DateTime(2026, 9, 19, 10, 30);
    final expectedLog = AttendanceLogEntity(
      id: 1,
      maidId: 2,
      maidName: 'Sunita Devi',
      householdId: 1,
      houseName: 'Sharma Residence',
      attendanceDate: testDate,
      checkInTime: '08:00:00',
      checkOutTime: '10:30:00',
      status: AttendanceStatus.present,
      entryType: EntryType.automatedGeofence,
      deviceTimestamp: testDate,
      isMockLocation: false,
    );

    test('should delegate check-out parameters to repository and return log with checkOutTime', () async {
      // Arrange
      when(() => mockRepository.checkOut(
            maidId: 2,
            householdId: 1,
            latitude: 28.6325,
            longitude: 77.2175,
            deviceTimestamp: testDate,
            isMockLocation: false,
          )).thenAnswer((_) async => expectedLog);

      // Act
      final result = await useCase.execute(
        maidId: 2,
        householdId: 1,
        latitude: 28.6325,
        longitude: 77.2175,
        deviceTimestamp: testDate,
        isMockLocation: false,
      );

      // Assert
      expect(result, equals(expectedLog));
      expect(result.checkOutTime, equals('10:30:00'));
      verify(() => mockRepository.checkOut(
            maidId: 2,
            householdId: 1,
            latitude: 28.6325,
            longitude: 77.2175,
            deviceTimestamp: testDate,
            isMockLocation: false,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
