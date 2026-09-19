package com.app.maidattendance.controller;

import com.app.maidattendance.dto.request.CheckInRequestDto;
import com.app.maidattendance.dto.request.CheckOutRequestDto;
import com.app.maidattendance.dto.request.ManualOverrideRequestDto;
import com.app.maidattendance.dto.response.ApiResponse;
import com.app.maidattendance.dto.response.AttendanceLogResponseDto;
import com.app.maidattendance.service.AttendanceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/attendance")
@Tag(name = "Attendance", description = "Endpoints for geofenced check-in, check-out, dwell validation, manual override, and daily logs")
public class AttendanceController {

    private final AttendanceService attendanceService;

    public AttendanceController(AttendanceService attendanceService) {
        this.attendanceService = attendanceService;
    }

    @PostMapping("/check-in")
    @Operation(summary = "Automated / Offline Geofence Check-in", 
               description = "Validates 50m radius geofence, 3-min dwell-time, mock location flag, records presence, and sends FCM push to employer")
    public ResponseEntity<ApiResponse<AttendanceLogResponseDto>> checkIn(@Valid @RequestBody CheckInRequestDto request) {
        AttendanceLogResponseDto response = attendanceService.recordCheckIn(request);
        return ResponseEntity.ok(ApiResponse.ok("Check-in recorded successfully", response));
    }

    @PostMapping("/check-out")
    @Operation(summary = "Automated Departure Check-out",
               description = "Logs departure when maid leaves geofence, computes total work duration, and notifies employer")
    public ResponseEntity<ApiResponse<AttendanceLogResponseDto>> checkOut(@Valid @RequestBody CheckOutRequestDto request) {
        AttendanceLogResponseDto response = attendanceService.recordCheckOut(request);
        return ResponseEntity.ok(ApiResponse.ok("Check-out recorded successfully", response));
    }

    @PostMapping("/manual-override")
    @Operation(summary = "Manual Employer Override", 
               description = "Allows employers to manually mark attendance for feature-phone users or forgotten devices")
    public ResponseEntity<ApiResponse<AttendanceLogResponseDto>> manualOverride(@Valid @RequestBody ManualOverrideRequestDto request) {
        AttendanceLogResponseDto response = attendanceService.recordManualOverride(request);
        return ResponseEntity.ok(ApiResponse.ok("Manual attendance override recorded successfully", response));
    }

    @GetMapping("/maid/{maidId}")
    @Operation(summary = "Get Daily Logs for Maid", description = "Returns attendance records for a maid on a specific date")
    public ResponseEntity<ApiResponse<List<AttendanceLogResponseDto>>> getLogsForMaid(
            @PathVariable Long maidId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        LocalDate queryDate = (date != null) ? date : LocalDate.now();
        List<AttendanceLogResponseDto> logs = attendanceService.getLogsForMaid(maidId, queryDate);
        return ResponseEntity.ok(ApiResponse.ok("Fetched logs successfully", logs));
    }

    @GetMapping("/household/{householdId}")
    @Operation(summary = "Get Logs for Household", description = "Returns attendance records for a household between dates")
    public ResponseEntity<ApiResponse<List<AttendanceLogResponseDto>>> getLogsForHousehold(
            @PathVariable Long householdId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        List<AttendanceLogResponseDto> logs = attendanceService.getLogsForHousehold(householdId, startDate, endDate);
        return ResponseEntity.ok(ApiResponse.ok("Fetched household logs successfully", logs));
    }
}
