import 'package:equatable/equatable.dart';

class SalaryCalculationEntity extends Equatable {
  final int maidId;
  final String maidName;
  final String? maidUpiId;
  final String? maidPhoneNumber;

  final int householdId;
  final String houseName;
  final int employerId;
  final String employerName;

  final int year;
  final int month;

  final double monthlyBaseSalary;
  final int totalDaysInMonth;
  final int totalWorkingDays;
  final int presentDays;
  final int lateDays;
  final int halfDays;
  final int absentDays;
  final int allowedLeaves;

  final double dailyRate;
  final double effectiveDeductionDays;
  final double deductionAmount;
  final double netPayableSalary;

  final bool isAlreadySettled;
  final String? settlementReceiptRef;
  final String? settlementStatus;

  const SalaryCalculationEntity({
    required this.maidId,
    required this.maidName,
    this.maidUpiId,
    this.maidPhoneNumber,
    required this.householdId,
    required this.houseName,
    required this.employerId,
    required this.employerName,
    required this.year,
    required this.month,
    required this.monthlyBaseSalary,
    required this.totalDaysInMonth,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.lateDays,
    required this.halfDays,
    required this.absentDays,
    required this.allowedLeaves,
    required this.dailyRate,
    required this.effectiveDeductionDays,
    required this.deductionAmount,
    required this.netPayableSalary,
    required this.isAlreadySettled,
    this.settlementReceiptRef,
    this.settlementStatus,
  });

  @override
  List<Object?> get props => [
        maidId,
        householdId,
        year,
        month,
        monthlyBaseSalary,
        totalWorkingDays,
        presentDays,
        absentDays,
        allowedLeaves,
        netPayableSalary,
        isAlreadySettled,
        settlementReceiptRef,
      ];
}
