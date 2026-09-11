package com.app.maidattendance.service;

import com.app.maidattendance.dto.request.CheckInRequestDto;
import com.app.maidattendance.dto.request.ManualOverrideRequestDto;
import com.app.maidattendance.dto.response.AttendanceLogResponseDto;

import java.time.LocalDate;
import java.util.List;

public interface AttendanceService {
    AttendanceLogResponseDto recordCheckIn(CheckInRequestDto request);
    AttendanceLogResponseDto recordManualOverride(ManualOverrideRequestDto request);
    List<AttendanceLogResponseDto> getLogsForMaid(Long maidId, LocalDate date);
    List<AttendanceLogResponseDto> getLogsForHousehold(Long householdId, LocalDate startDate, LocalDate endDate);
}
