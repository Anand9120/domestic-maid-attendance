package com.app.maidattendance.controller;

import com.app.maidattendance.dto.request.SalarySettlementRequestDto;
import com.app.maidattendance.dto.response.ApiResponse;
import com.app.maidattendance.dto.response.SalaryCalculationResponseDto;
import com.app.maidattendance.dto.response.SalarySettlementResponseDto;
import com.app.maidattendance.service.SalarySettlementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/salary")
@Tag(name = "Salary & Payouts", description = "Endpoints for dynamic payroll computation, 1-click UPI settlement, and digital receipts")
public class SalarySettlementController {

    private final SalarySettlementService salarySettlementService;

    public SalarySettlementController(SalarySettlementService salarySettlementService) {
        this.salarySettlementService = salarySettlementService;
    }

    @GetMapping("/calculate")
    @Operation(summary = "Calculate payroll metrics and net payable salary for a given month")
    public ResponseEntity<ApiResponse<SalaryCalculationResponseDto>> calculateSalary(
            @RequestParam Long maidId,
            @RequestParam Long householdId,
            @RequestParam int year,
            @RequestParam int month) {
        SalaryCalculationResponseDto result = salarySettlementService.calculateSalary(maidId, householdId, year, month);
        return ResponseEntity.ok(ApiResponse.ok("Salary calculation generated successfully", result));
    }

    @PostMapping("/settle")
    @Operation(summary = "Record and confirm a salary payout transaction with receipt generation")
    public ResponseEntity<ApiResponse<SalarySettlementResponseDto>> settleSalary(
            @Valid @RequestBody SalarySettlementRequestDto request) {
        SalarySettlementResponseDto result = salarySettlementService.settleSalary(request);
        return ResponseEntity.ok(ApiResponse.ok("Salary payout settled successfully", result));
    }

    @GetMapping("/receipt/{id}")
    @Operation(summary = "Fetch a digital salary receipt by settlement ID")
    public ResponseEntity<ApiResponse<SalarySettlementResponseDto>> getReceipt(
            @PathVariable Long id) {
        SalarySettlementResponseDto result = salarySettlementService.getReceiptById(id);
        return ResponseEntity.ok(ApiResponse.ok("Receipt fetched successfully", result));
    }

    @GetMapping("/maid/{maidId}")
    @Operation(summary = "Fetch settlement history for a maid across all households")
    public ResponseEntity<ApiResponse<List<SalarySettlementResponseDto>>> getMaidSettlements(
            @PathVariable Long maidId) {
        List<SalarySettlementResponseDto> list = salarySettlementService.getSettlementHistoryForMaid(maidId);
        return ResponseEntity.ok(ApiResponse.ok("Maid settlement history fetched successfully", list));
    }

    @GetMapping("/household/{householdId}")
    @Operation(summary = "Fetch settlement history for a household")
    public ResponseEntity<ApiResponse<List<SalarySettlementResponseDto>>> getHouseholdSettlements(
            @PathVariable Long householdId) {
        List<SalarySettlementResponseDto> list = salarySettlementService.getSettlementHistoryForHousehold(householdId);
        return ResponseEntity.ok(ApiResponse.ok("Household settlement history fetched successfully", list));
    }
}
