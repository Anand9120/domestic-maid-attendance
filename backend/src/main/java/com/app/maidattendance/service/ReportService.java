package com.app.maidattendance.service;

import com.app.maidattendance.dto.response.MonthlyReportSummaryDto;

public interface ReportService {
    MonthlyReportSummaryDto generateMonthlyReport(Long maidId, int year, int month);
    MonthlyReportSummaryDto generateMonthlyReport(Long maidId, Long householdId, int year, int month);
}
