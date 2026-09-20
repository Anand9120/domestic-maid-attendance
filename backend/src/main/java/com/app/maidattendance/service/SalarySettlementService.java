package com.app.maidattendance.service;

import com.app.maidattendance.dto.request.SalarySettlementRequestDto;
import com.app.maidattendance.dto.response.SalaryCalculationResponseDto;
import com.app.maidattendance.dto.response.SalarySettlementResponseDto;

import java.util.List;

public interface SalarySettlementService {

    SalaryCalculationResponseDto calculateSalary(Long maidId, Long householdId, int year, int month);

    SalarySettlementResponseDto settleSalary(SalarySettlementRequestDto request);

    SalarySettlementResponseDto getReceiptById(Long settlementId);

    List<SalarySettlementResponseDto> getSettlementHistoryForMaid(Long maidId);

    List<SalarySettlementResponseDto> getSettlementHistoryForHousehold(Long householdId);
}
