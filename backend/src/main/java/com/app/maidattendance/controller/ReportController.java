package com.app.maidattendance.controller;

import com.app.maidattendance.dto.response.ApiResponse;
import com.app.maidattendance.dto.response.MonthlyReportSummaryDto;
import com.app.maidattendance.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/reports")
@Tag(name = "Reports", description = "Endpoints for monthly visual attendance ledger and salary deductions calculation")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/monthly")
    @Operation(summary = "Get Visual Monthly Attendance Ledger", 
               description = "Calculates total working days, present/late/half-day counts, and salary deductions for the month")
    public ResponseEntity<ApiResponse<MonthlyReportSummaryDto>> getMonthlyReport(
            @RequestParam Long maidId,
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer month) {

        int targetYear = (year != null) ? year : LocalDate.now().getYear();
        int targetMonth = (month != null) ? month : LocalDate.now().getMonthValue();

        MonthlyReportSummaryDto report = reportService.generateMonthlyReport(maidId, targetYear, targetMonth);
        return ResponseEntity.ok(ApiResponse.ok("Monthly report generated successfully", report));
    }
}
