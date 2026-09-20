import 'package:equatable/equatable.dart';

class SalarySettlementEntity extends Equatable {
  final int id;
  final int maidId;
  final String maidName;
  final String? maidUpiId;
  final String? maidPhoneNumber;

  final int employerId;
  final String employerName;

  final int householdId;
  final String houseName;

  final int payoutYear;
  final int payoutMonth;

  final double baseSalary;
  final int totalWorkingDays;
  final int presentDays;
  final int lateDays;
  final int halfDays;
  final int absentDays;
  final int allowedLeaves;

  final double deductionDays;
  final double deductionAmount;
  final double netAmount;

  final String paymentMode;
  final String transactionRef;
  final String status;
  final DateTime settledAt;
  final String? notes;

  const SalarySettlementEntity({
    required this.id,
    required this.maidId,
    required this.maidName,
    this.maidUpiId,
    this.maidPhoneNumber,
    required this.employerId,
    required this.employerName,
    required this.householdId,
    required this.houseName,
    required this.payoutYear,
    required this.payoutMonth,
    required this.baseSalary,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.lateDays,
    required this.halfDays,
    required this.absentDays,
    required this.allowedLeaves,
    required this.deductionDays,
    required this.deductionAmount,
    required this.netAmount,
    required this.paymentMode,
    required this.transactionRef,
    required this.status,
    required this.settledAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        maidId,
        householdId,
        payoutYear,
        payoutMonth,
        netAmount,
        transactionRef,
        status,
        settledAt,
      ];
}
