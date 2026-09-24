package com.app.maidattendance.service.impl;

import com.app.maidattendance.dto.response.AttendanceLogResponseDto;
import com.app.maidattendance.dto.response.MonthlyReportSummaryDto;
import com.app.maidattendance.entity.AttendanceLog;
import com.app.maidattendance.entity.User;
import com.app.maidattendance.exception.ResourceNotFoundException;
import com.app.maidattendance.repository.AttendanceLogRepository;
import com.app.maidattendance.repository.UserRepository;
import com.app.maidattendance.service.ReportService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class ReportServiceImpl implements ReportService {

    private final AttendanceLogRepository attendanceLogRepository;
    private final UserRepository userRepository;

    public ReportServiceImpl(AttendanceLogRepository attendanceLogRepository, UserRepository userRepository) {
        this.attendanceLogRepository = attendanceLogRepository;
        this.userRepository = userRepository;
    }

    @Override
    public MonthlyReportSummaryDto generateMonthlyReport(Long maidId, int year, int month) {
        return generateMonthlyReport(maidId, null, year, month);
    }

    @Override
    public MonthlyReportSummaryDto generateMonthlyReport(Long maidId, Long householdId, int year, int month) {
        User maid = userRepository.findById(maidId)
                .orElseThrow(() -> new ResourceNotFoundException("Maid not found with ID: " + maidId));

        YearMonth yearMonth = YearMonth.of(year, month);
        LocalDate startDate = yearMonth.atDay(1);
        LocalDate endDate = yearMonth.atEndOfMonth();

        // 1. Fetch logs: Scoped to specific household if provided, or across all households for maid self-view
        List<AttendanceLog> logs;
        if (householdId != null) {
            logs = attendanceLogRepository.findMonthlyLogsForHouseholdAndMaid(householdId, maidId, startDate, endDate);
        } else {
            logs = attendanceLogRepository.findMonthlyLogsForMaid(maidId, startDate, endDate);
        }

        int totalDaysInMonth = yearMonth.lengthOfMonth();
        // Calculate working days in month (standard excluding Sundays)
        int workingDays = 0;
        for (int d = 1; d <= totalDaysInMonth; d++) {
            LocalDate date = yearMonth.atDay(d);
            if (date.getDayOfWeek().getValue() != 7) { // Exclude Sundays
                workingDays++;
            }
        }
        if (workingDays <= 0) {
            workingDays = 26; // Guard against division by zero
        }

        // 2. Group logs by calendar date to avoid multi-shift / multi-household overcounting on single day
        Map<LocalDate, List<AttendanceLog>> logsByDate = logs.stream()
                .collect(Collectors.groupingBy(AttendanceLog::getAttendanceDate));

        int presentCount = 0;
        int lateCount = 0;
        int halfDayCount = 0;
        int absentCount = 0;

        for (Map.Entry<LocalDate, List<AttendanceLog>> entry : logsByDate.entrySet()) {
            List<AttendanceLog> dayLogs = entry.getValue();
            // Determine best status for the day: PRESENT > LATE > HALF_DAY > ABSENT
            if (dayLogs.stream().anyMatch(l -> l.getStatus() == AttendanceLog.AttendanceStatus.PRESENT)) {
                presentCount++;
            } else if (dayLogs.stream().anyMatch(l -> l.getStatus() == AttendanceLog.AttendanceStatus.LATE)) {
                lateCount++;
            } else if (dayLogs.stream().anyMatch(l -> l.getStatus() == AttendanceLog.AttendanceStatus.HALF_DAY)) {
                halfDayCount++;
            } else {
                absentCount++;
            }
        }

        int attendedDays = presentCount + lateCount;

        // Determine elapsed working days for ongoing month to avoid penalizing upcoming dates
        YearMonth currentYearMonth = YearMonth.now();
        int evalWorkingDays = workingDays;
        if (yearMonth.equals(currentYearMonth) && LocalDate.now().getDayOfMonth() < totalDaysInMonth) {
            int elapsedWorkingDays = 0;
            for (int d = 1; d <= LocalDate.now().getDayOfMonth(); d++) {
                if (yearMonth.atDay(d).getDayOfWeek().getValue() != 7) {
                    elapsedWorkingDays++;
                }
            }
            evalWorkingDays = Math.max(attendedDays + halfDayCount + absentCount, Math.max(1, elapsedWorkingDays));
        }

        // Unrecorded working days up to active evaluation horizon count towards absent count
        int unrecordedWorkingDays = Math.max(0, evalWorkingDays - (attendedDays + halfDayCount + absentCount));
        absentCount += unrecordedWorkingDays;

        double weightedAttendance = attendedDays + (halfDayCount * 0.5);
        double attendancePercent = evalWorkingDays > 0 ? Math.min(100.0, (weightedAttendance / evalWorkingDays) * 100.0) : 0.0;
        double salaryDeductionUnits = absentCount + (halfDayCount * 0.5);

        MonthlyReportSummaryDto dto = new MonthlyReportSummaryDto();
        dto.setMaidId(maid.getId());
        dto.setMaidName(maid.getFullName());
        dto.setMonth(month);
        dto.setYear(year);
        dto.setTotalDaysInMonth(totalDaysInMonth);
        dto.setTotalWorkingDays(workingDays);
        dto.setPresentDays(presentCount);
        dto.setLateDays(lateCount);
        dto.setHalfDays(halfDayCount);
        dto.setAbsentDays(absentCount);
        dto.setAttendancePercentage(BigDecimal.valueOf(attendancePercent).setScale(1, RoundingMode.HALF_UP));
        dto.setCalculatedDeductions(BigDecimal.valueOf(salaryDeductionUnits).setScale(1, RoundingMode.HALF_UP));

        List<AttendanceLogResponseDto> logDtos = logs.stream().map(log -> {
            AttendanceLogResponseDto r = new AttendanceLogResponseDto();
            r.setId(log.getId());
            r.setMaidId(maid.getId());
            r.setMaidName(maid.getFullName());
            r.setHouseholdId(log.getHouseholdLocation().getId());
            r.setHouseName(log.getHouseholdLocation().getHouseName());
            if (log.getShiftSchedule() != null) {
                r.setShiftId(log.getShiftSchedule().getId());
                r.setShiftName(log.getShiftSchedule().getShiftName());
            }
            r.setAttendanceDate(log.getAttendanceDate());
            r.setCheckInTime(log.getCheckInTime());
            r.setCheckOutTime(log.getCheckOutTime());
            r.setStatus(log.getStatus());
            r.setEntryType(log.getEntryType());
            r.setDeviceTimestamp(log.getDeviceTimestamp());
            r.setServerTimestamp(log.getServerTimestamp());
            r.setIsMockLocation(log.getIsMockLocation());
            if (log.getOverrideByEmployer() != null) {
                r.setOverrideByEmployerName(log.getOverrideByEmployer().getFullName());
            }
            return r;
        }).collect(Collectors.toList());

        dto.setDailyLogs(logDtos);

        return dto;
    }
}
