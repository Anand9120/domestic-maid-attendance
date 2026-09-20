import 'package:equatable/equatable.dart';

abstract class SalaryEvent extends Equatable {
  const SalaryEvent();

  @override
  List<Object?> get props => [];
}

class CalculateSalaryEvent extends SalaryEvent {
  final int maidId;
  final int householdId;
  final int year;
  final int month;

  const CalculateSalaryEvent({
    required this.maidId,
    required this.householdId,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [maidId, householdId, year, month];
}

class SettleSalaryEvent extends SalaryEvent {
  final int maidId;
  final int householdId;
  final int year;
  final int month;
  final String paymentMode;
  final String? transactionRef;
  final String? notes;

  const SettleSalaryEvent({
    required this.maidId,
    required this.householdId,
    required this.year,
    required this.month,
    this.paymentMode = 'UPI',
    this.transactionRef,
    this.notes,
  });

  @override
  List<Object?> get props => [maidId, householdId, year, month, paymentMode, transactionRef, notes];
}

class FetchSalaryHistoryEvent extends SalaryEvent {
  final int maidId;

  const FetchSalaryHistoryEvent({required this.maidId});

  @override
  List<Object?> get props => [maidId];
}
