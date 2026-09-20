import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maid_attendance/features/salary/domain/entities/salary_calculation_entity.dart';
import 'package:maid_attendance/features/salary/domain/repositories/salary_repository.dart';
import 'package:maid_attendance/features/salary/domain/usecases/calculate_salary_usecase.dart';

class MockSalaryRepository extends Mock implements SalaryRepository {}

void main() {
  late CalculateSalaryUseCase useCase;
  late MockSalaryRepository mockRepository;

  setUp(() {
    mockRepository = MockSalaryRepository();
    useCase = CalculateSalaryUseCase(mockRepository);
  });

  const testCalculation = SalaryCalculationEntity(
    maidId: 2,
    maidName: 'Sunita Devi',
    maidUpiId: 'sunita@okhdfcbank',
    householdId: 1,
    houseName: 'Sharma Residence - Flat 402',
    employerId: 1,
    employerName: 'Priya Sharma',
    year: 2026,
    month: 9,
    monthlyBaseSalary: 5000.0,
    totalDaysInMonth: 30,
    totalWorkingDays: 26,
    presentDays: 20,
    lateDays: 0,
    halfDays: 0,
    absentDays: 6,
    allowedLeaves: 2,
    dailyRate: 192.31,
    effectiveDeductionDays: 4.0,
    deductionAmount: 769.24,
    netPayableSalary: 4230.76,
    isAlreadySettled: false,
  );

  test('CalculateSalaryUseCase should delegate calculation to repository', () async {
    when(() => mockRepository.calculateSalary(
          maidId: 2,
          householdId: 1,
          year: 2026,
          month: 9,
        )).thenAnswer((_) async => testCalculation);

    final result = await useCase.execute(
      maidId: 2,
      householdId: 1,
      year: 2026,
      month: 9,
    );

    expect(result, equals(testCalculation));
    expect(result.netPayableSalary, 4230.76);
    expect(result.allowedLeaves, 2);
    expect(result.effectiveDeductionDays, 4.0);
    verify(() => mockRepository.calculateSalary(
          maidId: 2,
          householdId: 1,
          year: 2026,
          month: 9,
        )).called(1);
  });
}
