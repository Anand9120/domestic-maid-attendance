import 'package:equatable/equatable.dart';
import '../../domain/entities/salary_calculation_entity.dart';
import '../../domain/entities/salary_settlement_entity.dart';

abstract class SalaryState extends Equatable {
  const SalaryState();

  @override
  List<Object?> get props => [];
}

class SalaryInitial extends SalaryState {}

class SalaryLoading extends SalaryState {}

class SalarySettlingLoading extends SalaryState {}

class SalaryCalculatedState extends SalaryState {
  final SalaryCalculationEntity calculation;

  const SalaryCalculatedState({required this.calculation});

  @override
  List<Object?> get props => [calculation];
}

class SalarySettledSuccessState extends SalaryState {
  final SalarySettlementEntity settlement;

  const SalarySettledSuccessState({required this.settlement});

  @override
  List<Object?> get props => [settlement];
}

class SalaryHistoryLoadedState extends SalaryState {
  final List<SalarySettlementEntity> settlements;

  const SalaryHistoryLoadedState({required this.settlements});

  @override
  List<Object?> get props => [settlements];
}

class SalaryErrorState extends SalaryState {
  final String message;

  const SalaryErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
