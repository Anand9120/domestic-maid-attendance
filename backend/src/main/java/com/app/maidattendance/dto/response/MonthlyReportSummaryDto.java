package com.app.maidattendance.dto.response;

import java.math.BigDecimal;
import java.util.List;

public class MonthlyReportSummaryDto {

    private Long maidId;
    private String maidName;
    private int month;
    private int year;
    private int totalDaysInMonth;
    private int totalWorkingDays;
    private int presentDays;
    private int lateDays;
    private int halfDays;
    private int absentDays;
    private BigDecimal attendancePercentage;
    private BigDecimal calculatedDeductions; // In days or units
    private List<AttendanceLogResponseDto> dailyLogs;

    public MonthlyReportSummaryDto() {}

    public Long getMaidId() { return maidId; }
    public void setMaidId(Long maidId) { this.maidId = maidId; }

    public String getMaidName() { return maidName; }
    public void setMaidName(String maidName) { this.maidName = maidName; }

    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public int getTotalDaysInMonth() { return totalDaysInMonth; }
    public void setTotalDaysInMonth(int totalDaysInMonth) { this.totalDaysInMonth = totalDaysInMonth; }

    public int getTotalWorkingDays() { return totalWorkingDays; }
    public void setTotalWorkingDays(int totalWorkingDays) { this.totalWorkingDays = totalWorkingDays; }

    public int getPresentDays() { return presentDays; }
    public void setPresentDays(int presentDays) { this.presentDays = presentDays; }

    public int getLateDays() { return lateDays; }
    public void setLateDays(int lateDays) { this.lateDays = lateDays; }

    public int getHalfDays() { return halfDays; }
    public void setHalfDays(int halfDays) { this.halfDays = halfDays; }

    public int getAbsentDays() { return absentDays; }
    public void setAbsentDays(int absentDays) { this.absentDays = absentDays; }

    public BigDecimal getAttendancePercentage() { return attendancePercentage; }
    public void setAttendancePercentage(BigDecimal attendancePercentage) { this.attendancePercentage = attendancePercentage; }

    public BigDecimal getCalculatedDeductions() { return calculatedDeductions; }
    public void setCalculatedDeductions(BigDecimal calculatedDeductions) { this.calculatedDeductions = calculatedDeductions; }

    public List<AttendanceLogResponseDto> getDailyLogs() { return dailyLogs; }
    public void setDailyLogs(List<AttendanceLogResponseDto> dailyLogs) { this.dailyLogs = dailyLogs; }
}
