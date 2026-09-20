import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maid_attendance/features/salary/domain/entities/salary_calculation_entity.dart';
import 'package:maid_attendance/features/salary/domain/entities/salary_settlement_entity.dart';
import 'package:maid_attendance/features/salary/domain/usecases/calculate_salary_usecase.dart';
import 'package:maid_attendance/features/salary/domain/usecases/get_salary_settlements_usecase.dart';
import 'package:maid_attendance/features/salary/domain/usecases/settle_salary_usecase.dart';
import 'package:maid_attendance/features/salary/presentation/bloc/salary_bloc.dart';
import 'package:maid_attendance/features/salary/presentation/bloc/salary_event.dart';
import 'package:maid_attendance/features/salary/presentation/bloc/salary_state.dart';

class MockCalculateSalaryUseCase extends Mock implements CalculateSalaryUseCase {}
class MockSettleSalaryUseCase extends Mock implements SettleSalaryUseCase {}
class MockGetSalarySettlementsUseCase extends Mock implements GetSalarySettlementsUseCase {}

void main() {
  late SalaryBloc bloc;
  late MockCalculateSalaryUseCase mockCalculateSalaryUseCase;
  late MockSettleSalaryUseCase mockSettleSalaryUseCase;
  late MockGetSalarySettlementsUseCase mockGetSalarySettlementsUseCase;

  setUp(() {
    mockCalculateSalaryUseCase = MockCalculateSalaryUseCase();
    mockSettleSalaryUseCase = MockSettleSalaryUseCase();
    mockGetSalarySettlementsUseCase = MockGetSalarySettlementsUseCase();

    bloc = SalaryBloc(
      calculateSalaryUseCase: mockCalculateSalaryUseCase,
      settleSalaryUseCase: mockSettleSalaryUseCase,
      getSalarySettlementsUseCase: mockGetSalarySettlementsUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const testCalc = SalaryCalculationEntity(
    maidId: 2,
    maidName: 'Sunita Devi',
    householdId: 1,
    houseName: 'Sharma Residence - Flat 402',
    employerId: 1,
    employerName: 'Priya Sharma',
    year: 2026,
    month: 9,
    monthlyBaseSalary: 5000.0,
    totalDaysInMonth: 30,
    totalWorkingDays: 26,
    presentDays: 22,
    lateDays: 0,
    halfDays: 0,
    absentDays: 4,
    allowedLeaves: 2,
    dailyRate: 192.31,
    effectiveDeductionDays: 2.0,
    deductionAmount: 384.62,
    netPayableSalary: 4615.38,
    isAlreadySettled: false,
  );

  final testSettlement = SalarySettlementEntity(
    id: 1,
    maidId: 2,
    maidName: 'Sunita Devi',
    employerId: 1,
    employerName: 'Priya Sharma',
    householdId: 1,
    houseName: 'Sharma Residence - Flat 402',
    payoutYear: 2026,
    payoutMonth: 9,
    baseSalary: 5000.0,
    totalWorkingDays: 26,
    presentDays: 22,
    lateDays: 0,
    halfDays: 0,
    absentDays: 4,
    allowedLeaves: 2,
    deductionDays: 2.0,
    deductionAmount: 384.62,
    netAmount: 4615.38,
    paymentMode: 'UPI',
    transactionRef: 'REC-202609-2-TEST1234',
    status: 'SETTLED',
    settledAt: DateTime(2026, 9, 20, 10, 0),
  );

  group('SalaryBloc Tests', () {
    test('initial state is SalaryInitial', () {
      expect(bloc.state, isA<SalaryInitial>());
    });

    blocTest<SalaryBloc, SalaryState>(
      'emits [SalaryLoading, SalaryCalculatedState] on successful CalculateSalaryEvent',
      build: () {
        when(() => mockCalculateSalaryUseCase.execute(
              maidId: 2,
              householdId: 1,
              year: 2026,
              month: 9,
            )).thenAnswer((_) async => testCalc);
        return bloc;
      },
      act: (b) => b.add(const CalculateSalaryEvent(
        maidId: 2,
        householdId: 1,
        year: 2026,
        month: 9,
      )),
      expect: () => [
        isA<SalaryLoading>(),
        const SalaryCalculatedState(calculation: testCalc),
      ],
    );

    blocTest<SalaryBloc, SalaryState>(
      'emits [SalarySettlingLoading, SalarySettledSuccessState] on successful SettleSalaryEvent',
      build: () {
        when(() => mockSettleSalaryUseCase.execute(
              maidId: 2,
              householdId: 1,
              year: 2026,
              month: 9,
              paymentMode: 'UPI',
              transactionRef: 'UTR-98765432',
              notes: 'Paid via GPay',
            )).thenAnswer((_) async => testSettlement);
        return bloc;
      },
      act: (b) => b.add(const SettleSalaryEvent(
        maidId: 2,
        householdId: 1,
        year: 2026,
        month: 9,
        paymentMode: 'UPI',
        transactionRef: 'UTR-98765432',
        notes: 'Paid via GPay',
      )),
      expect: () => [
        isA<SalarySettlingLoading>(),
        SalarySettledSuccessState(settlement: testSettlement),
      ],
    );
  });
}
