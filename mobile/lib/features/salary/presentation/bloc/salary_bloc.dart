import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/calculate_salary_usecase.dart';
import '../../domain/usecases/get_salary_settlements_usecase.dart';
import '../../domain/usecases/settle_salary_usecase.dart';
import 'salary_event.dart';
import 'salary_state.dart';

class SalaryBloc extends Bloc<SalaryEvent, SalaryState> {
  final CalculateSalaryUseCase calculateSalaryUseCase;
  final SettleSalaryUseCase settleSalaryUseCase;
  final GetSalarySettlementsUseCase getSalarySettlementsUseCase;

  SalaryBloc({
    required this.calculateSalaryUseCase,
    required this.settleSalaryUseCase,
    required this.getSalarySettlementsUseCase,
  }) : super(SalaryInitial()) {
    on<CalculateSalaryEvent>(_onCalculateSalary);
    on<SettleSalaryEvent>(_onSettleSalary);
    on<FetchSalaryHistoryEvent>(_onFetchSalaryHistory);
  }

  Future<void> _onCalculateSalary(
    CalculateSalaryEvent event,
    Emitter<SalaryState> emit,
  ) async {
    emit(SalaryLoading());
    try {
      final calc = await calculateSalaryUseCase.execute(
        maidId: event.maidId,
        householdId: event.householdId,
        year: event.year,
        month: event.month,
      );
      emit(SalaryCalculatedState(calculation: calc));
    } catch (e) {
      emit(SalaryErrorState(message: e.toString()));
    }
  }

  Future<void> _onSettleSalary(
    SettleSalaryEvent event,
    Emitter<SalaryState> emit,
  ) async {
    emit(SalarySettlingLoading());
    try {
      final settlement = await settleSalaryUseCase.execute(
        maidId: event.maidId,
        householdId: event.householdId,
        year: event.year,
        month: event.month,
        paymentMode: event.paymentMode,
        transactionRef: event.transactionRef,
        notes: event.notes,
      );
      emit(SalarySettledSuccessState(settlement: settlement));
    } catch (e) {
      emit(SalaryErrorState(message: e.toString()));
    }
  }

  Future<void> _onFetchSalaryHistory(
    FetchSalaryHistoryEvent event,
    Emitter<SalaryState> emit,
  ) async {
    emit(SalaryLoading());
    try {
      final history = await getSalarySettlementsUseCase.executeForMaid(event.maidId);
      emit(SalaryHistoryLoadedState(settlements: history));
    } catch (e) {
      emit(SalaryErrorState(message: e.toString()));
    }
  }
}
