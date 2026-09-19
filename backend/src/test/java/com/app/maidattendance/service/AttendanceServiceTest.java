package com.app.maidattendance.service;

import com.app.maidattendance.dto.request.CheckInRequestDto;
import com.app.maidattendance.dto.request.ManualOverrideRequestDto;
import com.app.maidattendance.dto.response.AttendanceLogResponseDto;
import com.app.maidattendance.entity.*;
import com.app.maidattendance.exception.GeofenceValidationException;
import com.app.maidattendance.repository.*;
import com.app.maidattendance.service.impl.AttendanceServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Collections;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AttendanceServiceTest {

    @Mock
    private AttendanceLogRepository attendanceLogRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private HouseholdLocationRepository householdLocationRepository;

    @Mock
    private ShiftScheduleRepository shiftScheduleRepository;

    @Mock
    private MaidHouseholdAssignmentRepository assignmentRepository;

    @Mock
    private GeofenceValidationService geofenceValidationService;

    @Mock
    private FcmNotificationService fcmNotificationService;

    @Mock
    private NotificationService notificationService;

    @InjectMocks
    private AttendanceServiceImpl attendanceService;

    private User employer;
    private User maid;
    private HouseholdLocation household;
    private MaidHouseholdAssignment assignment;
    private ShiftSchedule shift;

    @BeforeEach
    void setUp() {
        employer = new User(1L, "Priya Sharma", "+919876543210", User.Role.EMPLOYER, true);
        maid = new User(2L, "Sunita Devi", "+919811122233", User.Role.MAID, true);

        household = new HouseholdLocation(1L, employer, "Sharma Residence", "Delhi",
                new BigDecimal("28.6315000"), new BigDecimal("77.2167000"), 50, 3);

        assignment = new MaidHouseholdAssignment(1L, maid, household, MaidHouseholdAssignment.Status.ACTIVE);

        shift = new ShiftSchedule(1L, household, "Morning Shift",
                LocalTime.of(7, 30), LocalTime.of(9, 30), 15);
    }

    @Test
    @DisplayName("Should successfully check-in when maid is inside 50m radius and meets 3-min dwell time")
    void testCheckInSuccess() {
        CheckInRequestDto request = new CheckInRequestDto(
                2L, 1L, 1L,
                new BigDecimal("28.6315500"), new BigDecimal("77.2167200"),
                LocalDateTime.of(2026, 9, 12, 7, 35, 0),
                false, 180
        );

        when(userRepository.findById(2L)).thenReturn(Optional.of(maid));
        when(householdLocationRepository.findById(1L)).thenReturn(Optional.of(household));
        when(assignmentRepository.findByMaidIdAndHouseholdLocationId(2L, 1L)).thenReturn(Optional.of(assignment));
        when(geofenceValidationService.calculateDistanceMeters(any(), any(), any(), any())).thenReturn(15.0);
        when(shiftScheduleRepository.findById(1L)).thenReturn(Optional.of(shift));

        AttendanceLog savedEntity = new AttendanceLog();
        savedEntity.setId(101L);
        savedEntity.setMaid(maid);
        savedEntity.setHouseholdLocation(household);
        savedEntity.setShiftSchedule(shift);
        savedEntity.setAttendanceDate(LocalDate.of(2026, 9, 12));
        savedEntity.setCheckInTime(LocalTime.of(7, 35));
        savedEntity.setStatus(AttendanceLog.AttendanceStatus.PRESENT);
        savedEntity.setEntryType(AttendanceLog.EntryType.AUTOMATED_GEOFENCE);
        savedEntity.setDeviceTimestamp(request.getDeviceTimestamp());
        savedEntity.setIsMockLocation(false);

        when(attendanceLogRepository.save(any(AttendanceLog.class))).thenReturn(savedEntity);

        AttendanceLogResponseDto result = attendanceService.recordCheckIn(request);

        assertNotNull(result);
        assertEquals(101L, result.getId());
        assertEquals("Sunita Devi", result.getMaidName());
        assertEquals(AttendanceLog.AttendanceStatus.PRESENT, result.getStatus());
        assertEquals(AttendanceLog.EntryType.AUTOMATED_GEOFENCE, result.getEntryType());

        verify(fcmNotificationService, times(1)).sendPushNotification(eq(1L), anyString(), anyString(), anyMap());
    }

    @Test
    @DisplayName("Should reject check-in when maid is outside 50m geofence radius")
    void testCheckInRejectedOutsideGeofence() {
        CheckInRequestDto request = new CheckInRequestDto(
                2L, 1L, 1L,
                new BigDecimal("28.6400000"), new BigDecimal("77.2200000"),
                LocalDateTime.now(), false, 180
        );

        when(userRepository.findById(2L)).thenReturn(Optional.of(maid));
        when(householdLocationRepository.findById(1L)).thenReturn(Optional.of(household));
        when(assignmentRepository.findByMaidIdAndHouseholdLocationId(2L, 1L)).thenReturn(Optional.of(assignment));
        when(geofenceValidationService.calculateDistanceMeters(any(), any(), any(), any())).thenReturn(350.0);

        assertThrows(GeofenceValidationException.class, () -> attendanceService.recordCheckIn(request));
        verify(attendanceLogRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should reject check-in when dwell time is under 3 minutes (pass-by filter)")
    void testCheckInRejectedUnderDwellTime() {
        CheckInRequestDto request = new CheckInRequestDto(
                2L, 1L, 1L,
                new BigDecimal("28.6315500"), new BigDecimal("77.2167200"),
                LocalDateTime.now(), false, 45 // 45 seconds < 180 seconds threshold
        );

        when(userRepository.findById(2L)).thenReturn(Optional.of(maid));
        when(householdLocationRepository.findById(1L)).thenReturn(Optional.of(household));
        when(assignmentRepository.findByMaidIdAndHouseholdLocationId(2L, 1L)).thenReturn(Optional.of(assignment));
        when(geofenceValidationService.calculateDistanceMeters(any(), any(), any(), any())).thenReturn(10.0);

        assertThrows(GeofenceValidationException.class, () -> attendanceService.recordCheckIn(request));
        verify(attendanceLogRepository, never()).save(any());
    }

    @Test
    @DisplayName("Should successfully record manual employer override")
    void testManualEmployerOverride() {
        ManualOverrideRequestDto request = new ManualOverrideRequestDto();
        request.setMaidId(2L);
        request.setHouseholdId(1L);
        request.setEmployerId(1L);
        request.setAttendanceDate(LocalDate.of(2026, 9, 12));
        request.setCheckInTime(LocalTime.of(8, 0));
        request.setStatus(AttendanceLog.AttendanceStatus.PRESENT);

        when(userRepository.findById(2L)).thenReturn(Optional.of(maid));
        when(householdLocationRepository.findById(1L)).thenReturn(Optional.of(household));
        when(userRepository.findById(1L)).thenReturn(Optional.of(employer));

        AttendanceLog savedEntity = new AttendanceLog();
        savedEntity.setId(202L);
        savedEntity.setMaid(maid);
        savedEntity.setHouseholdLocation(household);
        savedEntity.setAttendanceDate(request.getAttendanceDate());
        savedEntity.setCheckInTime(request.getCheckInTime());
        savedEntity.setStatus(AttendanceLog.AttendanceStatus.PRESENT);
        savedEntity.setEntryType(AttendanceLog.EntryType.MANUAL_OVERRIDE);
        savedEntity.setDeviceTimestamp(LocalDateTime.now());
        savedEntity.setOverrideByEmployer(employer);

        when(attendanceLogRepository.save(any(AttendanceLog.class))).thenReturn(savedEntity);

        AttendanceLogResponseDto result = attendanceService.recordManualOverride(request);

        assertNotNull(result);
        assertEquals(202L, result.getId());
        assertEquals(AttendanceLog.EntryType.MANUAL_OVERRIDE, result.getEntryType());
        assertEquals("Priya Sharma", result.getOverrideByEmployerName());
    }

    @Test
    @DisplayName("Should successfully record check-out when maid completes work")
    void testCheckOutSuccess() {
        com.app.maidattendance.dto.request.CheckOutRequestDto request = 
                new com.app.maidattendance.dto.request.CheckOutRequestDto(
                        2L, 1L,
                        new BigDecimal("28.6315500"), new BigDecimal("77.2167200"),
                        LocalDateTime.of(2026, 9, 12, 9, 30, 0),
                        false
                );

        when(userRepository.findById(2L)).thenReturn(Optional.of(maid));
        when(householdLocationRepository.findById(1L)).thenReturn(Optional.of(household));

        AttendanceLog existingLog = new AttendanceLog();
        existingLog.setId(301L);
        existingLog.setMaid(maid);
        existingLog.setHouseholdLocation(household);
        existingLog.setAttendanceDate(LocalDate.of(2026, 9, 12));
        existingLog.setCheckInTime(LocalTime.of(7, 30));
        existingLog.setStatus(AttendanceLog.AttendanceStatus.PRESENT);

        when(attendanceLogRepository.findFirstByMaidIdAndHouseholdLocationIdAndAttendanceDateOrderByCheckInTimeDesc(
                eq(2L), eq(1L), eq(LocalDate.of(2026, 9, 12)))).thenReturn(Optional.of(existingLog));

        when(attendanceLogRepository.save(any(AttendanceLog.class))).thenAnswer(invocation -> invocation.getArgument(0));

        AttendanceLogResponseDto result = attendanceService.recordCheckOut(request);

        assertNotNull(result);
        assertEquals(LocalTime.of(9, 30), result.getCheckOutTime());
        verify(fcmNotificationService, times(1)).sendPushNotification(eq(1L), contains("Maid Departed"), anyString(), anyMap());
    }
}
