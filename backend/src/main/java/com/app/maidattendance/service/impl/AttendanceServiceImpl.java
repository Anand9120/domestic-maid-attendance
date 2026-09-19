package com.app.maidattendance.service.impl;

import com.app.maidattendance.dto.request.CheckInRequestDto;
import com.app.maidattendance.dto.request.CheckOutRequestDto;
import com.app.maidattendance.dto.request.ManualOverrideRequestDto;
import com.app.maidattendance.dto.response.AttendanceLogResponseDto;
import com.app.maidattendance.entity.*;
import com.app.maidattendance.exception.DuplicateCheckInException;
import com.app.maidattendance.exception.GeofenceValidationException;
import com.app.maidattendance.exception.ResourceNotFoundException;
import com.app.maidattendance.repository.*;
import com.app.maidattendance.service.AttendanceService;
import com.app.maidattendance.service.FcmNotificationService;
import com.app.maidattendance.service.GeofenceValidationService;
import com.app.maidattendance.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class AttendanceServiceImpl implements AttendanceService {

    private static final Logger log = LoggerFactory.getLogger(AttendanceServiceImpl.class);

    private final AttendanceLogRepository attendanceLogRepository;
    private final UserRepository userRepository;
    private final HouseholdLocationRepository householdLocationRepository;
    private final ShiftScheduleRepository shiftScheduleRepository;
    private final MaidHouseholdAssignmentRepository assignmentRepository;
    private final GeofenceValidationService geofenceValidationService;
    private final FcmNotificationService fcmNotificationService;
    private final NotificationService notificationService;

    public AttendanceServiceImpl(
            AttendanceLogRepository attendanceLogRepository,
            UserRepository userRepository,
            HouseholdLocationRepository householdLocationRepository,
            ShiftScheduleRepository shiftScheduleRepository,
            MaidHouseholdAssignmentRepository assignmentRepository,
            GeofenceValidationService geofenceValidationService,
            FcmNotificationService fcmNotificationService,
            NotificationService notificationService) {
        this.attendanceLogRepository = attendanceLogRepository;
        this.userRepository = userRepository;
        this.householdLocationRepository = householdLocationRepository;
        this.shiftScheduleRepository = shiftScheduleRepository;
        this.assignmentRepository = assignmentRepository;
        this.geofenceValidationService = geofenceValidationService;
        this.fcmNotificationService = fcmNotificationService;
        this.notificationService = notificationService;
    }

    @Override
    public AttendanceLogResponseDto recordCheckIn(CheckInRequestDto request) {
        // 1. Verify Maid exists
        User maid = userRepository.findById(request.getMaidId())
                .orElseThrow(() -> new ResourceNotFoundException("Maid not found with ID: " + request.getMaidId()));

        if (maid.getRole() != User.Role.MAID) {
            throw new IllegalArgumentException("User with ID " + request.getMaidId() + " is not a domestic maid");
        }

        // 2. Verify Household exists
        HouseholdLocation household = householdLocationRepository.findById(request.getHouseholdId())
                .orElseThrow(() -> new ResourceNotFoundException("Household location not found with ID: " + request.getHouseholdId()));

        // 3. Verify Active Assignment
        MaidHouseholdAssignment assignment = assignmentRepository
                .findByMaidIdAndHouseholdLocationId(maid.getId(), household.getId())
                .orElseThrow(() -> new IllegalArgumentException("Maid is not assigned to this household location"));

        if (assignment.getStatus() != MaidHouseholdAssignment.Status.ACTIVE) {
            throw new IllegalArgumentException("Maid assignment to this household is currently inactive");
        }

        // 4. Geofence Distance Validation (PRD US-M01: 50m radius)
        double distanceMeters = geofenceValidationService.calculateDistanceMeters(
                request.getLatitude(), request.getLongitude(),
                household.getLatitude(), household.getLongitude());

        int allowedRadius = household.getGeofenceRadiusMeters() != null ? household.getGeofenceRadiusMeters() : 50;
        if (distanceMeters > allowedRadius) {
            throw new GeofenceValidationException(String.format(
                    "Check-in rejected: Device is %.1f meters away from household boundary (Allowed radius: %d meters)",
                    distanceMeters, allowedRadius));
        }

        // 5. Dwell Time Validation (PRD US-S01: 3-minute dwell time)
        int minDwellSeconds = (household.getDwellTimeMinutes() != null ? household.getDwellTimeMinutes() : 3) * 60;
        int reportedDwellSeconds = request.getDwellTimeSeconds() != null ? request.getDwellTimeSeconds() : 0;
        if (reportedDwellSeconds < minDwellSeconds) {
            throw new GeofenceValidationException(String.format(
                    "Check-in rejected: Dwell time was %d seconds, but at least %d seconds (3 minutes) inside the geofence is required to prevent pass-by false alarms",
                    reportedDwellSeconds, minDwellSeconds));
        }

        // 6. Anti-Spoofing / Mock Location Check
        boolean isMock = Boolean.TRUE.equals(request.getIsMockLocation());
        if (isMock) {
            log.warn("[SECURITY FLAG] Mock location detected during check-in for maid ID {} at household ID {}",
                    maid.getId(), household.getId());
        }

        // 7. Determine Shift & Timing Status
        LocalDateTime deviceTime = request.getDeviceTimestamp();
        LocalDate attendanceDate = deviceTime.toLocalDate();
        LocalTime checkInTime = deviceTime.toLocalTime();

        List<ShiftSchedule> shifts = shiftScheduleRepository.findByHouseholdLocationId(household.getId());
        ShiftSchedule matchingShift = null;

        if (request.getShiftId() != null) {
            matchingShift = shiftScheduleRepository.findById(request.getShiftId()).orElse(null);
        } else if (!shifts.isEmpty()) {
            // Match closest shift based on current time
            matchingShift = shifts.get(0);
            for (ShiftSchedule s : shifts) {
                if (checkInTime.isAfter(s.getStartTime().minusMinutes(60)) && checkInTime.isBefore(s.getEndTime().plusMinutes(60))) {
                    matchingShift = s;
                    break;
                }
            }
        }

        // 8. Prevent duplicate check-in for same shift on same day
        if (matchingShift != null) {
            Optional<AttendanceLog> existing = attendanceLogRepository
                    .findByMaidIdAndHouseholdLocationIdAndAttendanceDateAndShiftScheduleId(
                            maid.getId(), household.getId(), attendanceDate, matchingShift.getId());
            if (existing.isPresent()) {
                throw new DuplicateCheckInException("Check-in already recorded today for shift: " + matchingShift.getShiftName());
            }
        }

        AttendanceLog.AttendanceStatus status = AttendanceLog.AttendanceStatus.PRESENT;
        if (matchingShift != null) {
            int grace = matchingShift.getGracePeriodMinutes() != null ? matchingShift.getGracePeriodMinutes() : 15;
            LocalTime threshold = matchingShift.getStartTime().plusMinutes(grace);
            if (checkInTime.isAfter(threshold)) {
                status = AttendanceLog.AttendanceStatus.LATE;
            }
        }

        // 9. Save Attendance Log
        AttendanceLog logEntity = new AttendanceLog();
        logEntity.setMaid(maid);
        logEntity.setHouseholdLocation(household);
        logEntity.setShiftSchedule(matchingShift);
        logEntity.setAttendanceDate(attendanceDate);
        logEntity.setCheckInTime(checkInTime);
        logEntity.setStatus(status);
        logEntity.setEntryType(AttendanceLog.EntryType.AUTOMATED_GEOFENCE);
        logEntity.setDeviceTimestamp(deviceTime);
        logEntity.setIsMockLocation(isMock);

        AttendanceLog saved = attendanceLogRepository.save(logEntity);

        // 10. Real-time Push Notification to Employer (PRD US-E01)
        User employer = household.getEmployer();
        String timeStr = checkInTime.format(DateTimeFormatter.ofPattern("hh:mm a"));
        String notifTitle = "Maid Arrived: " + maid.getFullName();
        String notifBody = String.format("%s arrived at %s at %s (%s)",
                maid.getFullName(), household.getHouseName(), timeStr, status.name());

        Map<String, String> payloadData = new HashMap<>();
        payloadData.put("attendanceId", String.valueOf(saved.getId()));
        payloadData.put("maidId", String.valueOf(maid.getId()));
        payloadData.put("maidName", maid.getFullName());
        payloadData.put("householdId", String.valueOf(household.getId()));
        payloadData.put("status", status.name());
        fcmNotificationService.sendPushNotification(employer.getId(), notifTitle, notifBody, payloadData);

        // Record in-app notifications for Employer & Maid
        notificationService.recordNotification(
                employer.getId(),
                household.getId(),
                notifTitle,
                notifBody,
                "CHECK_IN"
        );
        String maidNotifTitle = "Arrival Verified: " + household.getHouseName();
        String maidNotifBody = String.format("Checked into %s at %s (%s). Dwell verified.",
                household.getHouseName(), timeStr, status.name());
        notificationService.recordNotification(
                maid.getId(),
                household.getId(),
                maidNotifTitle,
                maidNotifBody,
                "CHECK_IN"
        );

        return mapToDto(saved);
    }

    @Override
    public AttendanceLogResponseDto recordCheckOut(CheckOutRequestDto request) {
        User maid = userRepository.findById(request.getMaidId())
                .orElseThrow(() -> new ResourceNotFoundException("Maid not found with ID: " + request.getMaidId()));

        HouseholdLocation household = householdLocationRepository.findById(request.getHouseholdId())
                .orElseThrow(() -> new ResourceNotFoundException("Household location not found with ID: " + request.getHouseholdId()));

        LocalDate attendanceDate = request.getDeviceTimestamp().toLocalDate();

        AttendanceLog logEntity = attendanceLogRepository
                .findFirstByMaidIdAndHouseholdLocationIdAndAttendanceDateOrderByCheckInTimeDesc(
                        maid.getId(), household.getId(), attendanceDate)
                .orElseThrow(() -> new IllegalStateException("Cannot check-out: No check-in record found for today (" + attendanceDate + ")"));

        LocalTime checkOutTime = request.getDeviceTimestamp().toLocalTime();
        logEntity.setCheckOutTime(checkOutTime);

        String durationStr = "N/A";
        if (logEntity.getCheckInTime() != null) {
            long minutesWorked = java.time.Duration.between(logEntity.getCheckInTime(), checkOutTime).toMinutes();
            long hours = minutesWorked / 60;
            long mins = minutesWorked % 60;
            durationStr = (hours > 0 ? hours + "h " : "") + mins + "m";
        }

        AttendanceLog saved = attendanceLogRepository.save(logEntity);

        // Send Departure Push Notification to Employer
        User employer = household.getEmployer();
        String timeStr = checkOutTime.format(DateTimeFormatter.ofPattern("hh:mm a"));
        String notifTitle = "Maid Departed: " + maid.getFullName();
        String notifBody = String.format("%s completed work and departed from %s at %s (Total Time: %s)",
                maid.getFullName(), household.getHouseName(), timeStr, durationStr);

        Map<String, String> payloadData = new HashMap<>();
        payloadData.put("attendanceId", String.valueOf(saved.getId()));
        payloadData.put("maidId", String.valueOf(maid.getId()));
        payloadData.put("maidName", maid.getFullName());
        payloadData.put("householdId", String.valueOf(household.getId()));
        payloadData.put("status", saved.getStatus().name());
        payloadData.put("checkInTime", saved.getCheckInTime() != null ? saved.getCheckInTime().format(DateTimeFormatter.ofPattern("hh:mm a")) : "");
        payloadData.put("checkOutTime", timeStr);
        payloadData.put("duration", durationStr);

        fcmNotificationService.sendPushNotification(employer.getId(), notifTitle, notifBody, payloadData);

        // Record in-app notifications for Employer & Maid
        notificationService.recordNotification(
                employer.getId(),
                household.getId(),
                notifTitle,
                notifBody,
                "CHECK_OUT"
        );
        String maidNotifTitle = "Shift Completed: " + household.getHouseName();
        String maidNotifBody = String.format("Departure logged at %s from %s. Work duration: %s.",
                timeStr, household.getHouseName(), durationStr);
        notificationService.recordNotification(
                maid.getId(),
                household.getId(),
                maidNotifTitle,
                maidNotifBody,
                "CHECK_OUT"
        );

        return mapToDto(saved);
    }

    @Override
    public AttendanceLogResponseDto recordManualOverride(ManualOverrideRequestDto request) {
        User maid = userRepository.findById(request.getMaidId())
                .orElseThrow(() -> new ResourceNotFoundException("Maid not found with ID: " + request.getMaidId()));

        HouseholdLocation household = householdLocationRepository.findById(request.getHouseholdId())
                .orElseThrow(() -> new ResourceNotFoundException("Household location not found with ID: " + request.getHouseholdId()));

        User employer = userRepository.findById(request.getEmployerId())
                .orElseThrow(() -> new ResourceNotFoundException("Employer not found with ID: " + request.getEmployerId()));

        ShiftSchedule shift = null;
        if (request.getShiftId() != null) {
            shift = shiftScheduleRepository.findById(request.getShiftId()).orElse(null);
        }

        AttendanceLog logEntity = new AttendanceLog();
        logEntity.setMaid(maid);
        logEntity.setHouseholdLocation(household);
        logEntity.setShiftSchedule(shift);
        logEntity.setAttendanceDate(request.getAttendanceDate());
        logEntity.setCheckInTime(request.getCheckInTime() != null ? request.getCheckInTime() : LocalTime.now());
        logEntity.setCheckOutTime(request.getCheckOutTime());
        logEntity.setStatus(request.getStatus());
        logEntity.setEntryType(AttendanceLog.EntryType.MANUAL_OVERRIDE);
        logEntity.setDeviceTimestamp(LocalDateTime.now());
        logEntity.setIsMockLocation(false);
        logEntity.setOverrideByEmployer(employer);

        AttendanceLog saved = attendanceLogRepository.save(logEntity);

        notificationService.recordNotification(
                maid.getId(),
                household.getId(),
                "Manual Attendance Recorded: " + household.getHouseName(),
                String.format("Employer %s manually recorded attendance for %s (%s).",
                        employer.getFullName(), request.getAttendanceDate(), request.getStatus().name()),
                "MANUAL_OVERRIDE"
        );

        return mapToDto(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AttendanceLogResponseDto> getLogsForMaid(Long maidId, LocalDate date) {
        return attendanceLogRepository.findByMaidIdAndAttendanceDate(maidId, date)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<AttendanceLogResponseDto> getLogsForHousehold(Long householdId, LocalDate startDate, LocalDate endDate) {
        return attendanceLogRepository.findMonthlyLogsForHousehold(householdId, startDate, endDate)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    private AttendanceLogResponseDto mapToDto(AttendanceLog entity) {
        AttendanceLogResponseDto dto = new AttendanceLogResponseDto();
        dto.setId(entity.getId());
        dto.setMaidId(entity.getMaid().getId());
        dto.setMaidName(entity.getMaid().getFullName());
        dto.setHouseholdId(entity.getHouseholdLocation().getId());
        dto.setHouseName(entity.getHouseholdLocation().getHouseName());

        if (entity.getShiftSchedule() != null) {
            dto.setShiftId(entity.getShiftSchedule().getId());
            dto.setShiftName(entity.getShiftSchedule().getShiftName());
        }

        dto.setAttendanceDate(entity.getAttendanceDate());
        dto.setCheckInTime(entity.getCheckInTime());
        dto.setCheckOutTime(entity.getCheckOutTime());
        dto.setStatus(entity.getStatus());
        dto.setEntryType(entity.getEntryType());
        dto.setDeviceTimestamp(entity.getDeviceTimestamp());
        dto.setServerTimestamp(entity.getServerTimestamp());
        dto.setIsMockLocation(entity.getIsMockLocation());

        if (entity.getOverrideByEmployer() != null) {
            dto.setOverrideByEmployerName(entity.getOverrideByEmployer().getFullName());
        }

        return dto;
    }
}
