package com.app.maidattendance.service;

import com.app.maidattendance.dto.request.SalarySettlementRequestDto;
import com.app.maidattendance.dto.response.SalaryCalculationResponseDto;
import com.app.maidattendance.dto.response.SalarySettlementResponseDto;
import com.app.maidattendance.entity.AttendanceLog;
import com.app.maidattendance.entity.HouseholdLocation;
import com.app.maidattendance.entity.SalarySettlement;
import com.app.maidattendance.entity.User;
import com.app.maidattendance.repository.AttendanceLogRepository;
import com.app.maidattendance.repository.HouseholdLocationRepository;
import com.app.maidattendance.repository.SalarySettlementRepository;
import com.app.maidattendance.repository.UserRepository;
import com.app.maidattendance.service.impl.SalarySettlementServiceImpl;
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
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class SalarySettlementServiceTest {

    @Mock
    private SalarySettlementRepository salarySettlementRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private HouseholdLocationRepository householdLocationRepository;

    @Mock
    private AttendanceLogRepository attendanceLogRepository;

    @Mock
    private NotificationService notificationService;

    @Mock
    private FcmNotificationService fcmNotificationService;

    @InjectMocks
    private SalarySettlementServiceImpl salarySettlementService;

    private User employer;
    private User maid;
    private HouseholdLocation household;

    @BeforeEach
    void setUp() {
        employer = new User(1L, "Priya Sharma", "+919876543210", User.Role.EMPLOYER, true);
        maid = new User(2L, "Sunita Devi", "+919811122233", User.Role.MAID, true);
        maid.setUpiId("sunita@okhdfcbank");

        household = new HouseholdLocation(
                1L, employer, "Sharma Residence - Flat 402", "B-Block",
                new BigDecimal("28.6315"), new BigDecimal("77.2167"), 50, 3,
                "SHARMA402", new BigDecimal("5000.00"), 2
        );
    }

    @Test
    @DisplayName("calculateSalary should compute deductions deducting only beyond allowed leaves")
    void testCalculateSalaryWithAllowedLeaves() {
        when(userRepository.findById(2L)).thenReturn(Optional.of(maid));
        when(householdLocationRepository.findById(1L)).thenReturn(Optional.of(household));

        // Create 20 present logs in month of September 2026
        List<AttendanceLog> logs = new ArrayList<>();
        for (int i = 1; i <= 20; i++) {
            AttendanceLog log = new AttendanceLog();
            log.setMaid(maid);
            log.setHouseholdLocation(household);
            log.setAttendanceDate(LocalDate.of(2026, 9, i));
            log.setStatus(AttendanceLog.AttendanceStatus.PRESENT);
            log.setEntryType(AttendanceLog.EntryType.AUTOMATED_GEOFENCE);
            log.setDeviceTimestamp(LocalDateTime.now());
            log.setIsMockLocation(false);
            logs.add(log);
        }
        when(attendanceLogRepository.findMonthlyLogsForMaid(eq(2L), any(), any())).thenReturn(logs);
        when(salarySettlementRepository.findByMaidIdAndYearAndMonth(2L, 2026, 9)).thenReturn(Optional.empty());

        SalaryCalculationResponseDto result = salarySettlementService.calculateSalary(2L, 1L, 2026, 9);

        assertNotNull(result);
        assertEquals(2L, result.getMaidId());
        assertEquals("Sunita Devi", result.getMaidName());
        assertEquals("sunita@okhdfcbank", result.getMaidUpiId());
        assertEquals(new BigDecimal("5000.00"), result.getMonthlyBaseSalary());
        assertEquals(2, result.getAllowedLeaves());
        assertEquals(20, result.getPresentDays());
        assertFalse(result.getIsAlreadySettled());

        // Working days in Sep 2026 (30 days total - 4 Sundays = 26 working days)
        assertEquals(26, result.getTotalWorkingDays());
        // Absent days = 26 - 20 = 6 days.
        // Allowed leaves = 2. Effective deduction days = 6 - 2 = 4.0 days.
        assertEquals(new BigDecimal("4.0"), result.getEffectiveDeductionDays());

        // Daily rate = 5000 / 26 = 192.31
        // Deduction = 4 * 192.31 = 769.24
        // Net payable = 5000 - 769.24 = 4230.76
        assertTrue(result.getNetPayableSalary().compareTo(BigDecimal.ZERO) > 0);
        assertEquals(new BigDecimal("4230.76"), result.getNetPayableSalary());
    }

    @Test
    @DisplayName("settleSalary should persist settlement, generate receipt, and dispatch notifications")
    void testSettleSalarySuccess() {
        when(userRepository.findById(2L)).thenReturn(Optional.of(maid));
        when(householdLocationRepository.findById(1L)).thenReturn(Optional.of(household));
        when(attendanceLogRepository.findMonthlyLogsForMaid(eq(2L), any(), any())).thenReturn(List.of());
        when(salarySettlementRepository.findByMaidIdAndYearAndMonth(2L, 2026, 9)).thenReturn(Optional.empty());

        when(salarySettlementRepository.save(any(SalarySettlement.class))).thenAnswer(inv -> {
            SalarySettlement s = inv.getArgument(0);
            s.setId(99L);
            return s;
        });

        SalarySettlementRequestDto request = new SalarySettlementRequestDto();
        request.setMaidId(2L);
        request.setHouseholdId(1L);
        request.setYear(2026);
        request.setMonth(9);
        request.setPaymentMode("UPI");
        request.setTransactionRef("UPI-REF-12345678");
        request.setNotes("Settled via Google Pay");

        SalarySettlementResponseDto response = salarySettlementService.settleSalary(request);

        assertNotNull(response);
        assertEquals(99L, response.getId());
        assertEquals("UPI-REF-12345678", response.getTransactionRef());
        assertEquals("SETTLED", response.getStatus());

        // Verify notifications logged for both maid and employer
        verify(notificationService, times(1)).recordNotification(
                eq(2L), eq(1L), anyString(), anyString(), eq("PAYOUT"));
        verify(notificationService, times(1)).recordNotification(
                eq(1L), eq(1L), anyString(), anyString(), eq("PAYOUT"));

        // Verify Firebase Cloud Messaging (FCM) real-time push dispatch
        verify(fcmNotificationService, times(1)).sendPushNotification(
                eq(2L), contains("वेतन प्राप्त"), anyString(), anyMap());
        verify(fcmNotificationService, times(1)).sendPushNotification(
                eq(1L), contains("वेतन भुगतान सफल"), anyString(), anyMap());
    }
}
