package com.app.maidattendance.service.impl;

import com.app.maidattendance.dto.request.SalarySettlementRequestDto;
import com.app.maidattendance.dto.response.SalaryCalculationResponseDto;
import com.app.maidattendance.dto.response.SalarySettlementResponseDto;
import com.app.maidattendance.entity.AttendanceLog;
import com.app.maidattendance.entity.HouseholdLocation;
import com.app.maidattendance.entity.SalarySettlement;
import com.app.maidattendance.entity.User;
import com.app.maidattendance.exception.ResourceNotFoundException;
import com.app.maidattendance.repository.AttendanceLogRepository;
import com.app.maidattendance.repository.HouseholdLocationRepository;
import com.app.maidattendance.repository.SalarySettlementRepository;
import com.app.maidattendance.repository.UserRepository;
import com.app.maidattendance.service.FcmNotificationService;
import com.app.maidattendance.service.NotificationService;
import com.app.maidattendance.service.SalarySettlementService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class SalarySettlementServiceImpl implements SalarySettlementService {

    private final SalarySettlementRepository salarySettlementRepository;
    private final UserRepository userRepository;
    private final HouseholdLocationRepository householdLocationRepository;
    private final AttendanceLogRepository attendanceLogRepository;
    private final NotificationService notificationService;
    private final FcmNotificationService fcmNotificationService;

    public SalarySettlementServiceImpl(SalarySettlementRepository salarySettlementRepository,
                                       UserRepository userRepository,
                                       HouseholdLocationRepository householdLocationRepository,
                                       AttendanceLogRepository attendanceLogRepository,
                                       NotificationService notificationService,
                                       FcmNotificationService fcmNotificationService) {
        this.salarySettlementRepository = salarySettlementRepository;
        this.userRepository = userRepository;
        this.householdLocationRepository = householdLocationRepository;
        this.attendanceLogRepository = attendanceLogRepository;
        this.notificationService = notificationService;
        this.fcmNotificationService = fcmNotificationService;
    }

    @Override
    @Transactional(readOnly = true)
    public SalaryCalculationResponseDto calculateSalary(Long maidId, Long householdId, int year, int month) {
        User maid = userRepository.findById(maidId)
                .orElseThrow(() -> new ResourceNotFoundException("Maid not found with ID: " + maidId));

        HouseholdLocation household = householdLocationRepository.findById(householdId)
                .orElseThrow(() -> new ResourceNotFoundException("Household not found with ID: " + householdId));

        YearMonth yearMonth = YearMonth.of(year, month);
        LocalDate startDate = yearMonth.atDay(1);
        LocalDate endDate = yearMonth.atEndOfMonth();

        List<AttendanceLog> logs = attendanceLogRepository.findMonthlyLogsForMaid(maidId, startDate, endDate);

        int totalDaysInMonth = yearMonth.lengthOfMonth();
        int workingDays = 0;
        for (int d = 1; d <= totalDaysInMonth; d++) {
            LocalDate date = yearMonth.atDay(d);
            if (date.getDayOfWeek().getValue() != 7) { // Exclude Sundays
                workingDays++;
            }
        }
        if (workingDays == 0) workingDays = 26; // safety fallback

        int presentCount = 0;
        int lateCount = 0;
        int halfDayCount = 0;
        int absentCount = 0;

        for (AttendanceLog log : logs) {
            // Filter by household if logged for this house
            if (log.getHouseholdLocation() != null && log.getHouseholdLocation().getId().equals(householdId)) {
                switch (log.getStatus()) {
                    case PRESENT -> presentCount++;
                    case LATE -> lateCount++;
                    case HALF_DAY -> halfDayCount++;
                    case ABSENT -> absentCount++;
                }
            }
        }

        int attendedDays = presentCount + lateCount;
        int unrecordedDays = Math.max(0, workingDays - (attendedDays + halfDayCount + absentCount));
        absentCount += unrecordedDays;

        int allowedLeaves = household.getAllowedLeaves() != null ? household.getAllowedLeaves() : 2;
        BigDecimal baseSalary = household.getMonthlySalary() != null && household.getMonthlySalary().compareTo(BigDecimal.ZERO) > 0
                ? household.getMonthlySalary()
                : BigDecimal.valueOf(5000.00);

        BigDecimal dailyRate = baseSalary.divide(BigDecimal.valueOf(workingDays), 2, RoundingMode.HALF_UP);

        // Effective Absent Days = max(0, absentCount + 0.5 * halfDayCount - allowedLeaves)
        double rawDeductionDays = absentCount + (halfDayCount * 0.5);
        double effectiveDeductionDays = Math.max(0.0, rawDeductionDays - allowedLeaves);

        BigDecimal deductionAmount = dailyRate.multiply(BigDecimal.valueOf(effectiveDeductionDays))
                .setScale(2, RoundingMode.HALF_UP);

        BigDecimal netPayable = baseSalary.subtract(deductionAmount);
        if (netPayable.compareTo(BigDecimal.ZERO) < 0) {
            netPayable = BigDecimal.ZERO;
        }

        SalaryCalculationResponseDto dto = new SalaryCalculationResponseDto();
        dto.setMaidId(maid.getId());
        dto.setMaidName(maid.getFullName());
        dto.setMaidUpiId(maid.getUpiId());
        dto.setMaidPhoneNumber(maid.getPhoneNumber());

        dto.setHouseholdId(household.getId());
        dto.setHouseName(household.getHouseName());
        dto.setEmployerId(household.getEmployer().getId());
        dto.setEmployerName(household.getEmployer().getFullName());

        dto.setYear(year);
        dto.setMonth(month);
        dto.setMonthlyBaseSalary(baseSalary);
        dto.setTotalDaysInMonth(totalDaysInMonth);
        dto.setTotalWorkingDays(workingDays);
        dto.setPresentDays(presentCount);
        dto.setLateDays(lateCount);
        dto.setHalfDays(halfDayCount);
        dto.setAbsentDays(absentCount);
        dto.setAllowedLeaves(allowedLeaves);

        dto.setDailyRate(dailyRate);
        dto.setEffectiveDeductionDays(BigDecimal.valueOf(effectiveDeductionDays).setScale(1, RoundingMode.HALF_UP));
        dto.setDeductionAmount(deductionAmount);
        dto.setNetPayableSalary(netPayable.setScale(2, RoundingMode.HALF_UP));

        // Check if settlement already exists
        Optional<SalarySettlement> existingSettlement = salarySettlementRepository
                .findByMaidIdAndYearAndMonth(maidId, year, month);
        if (existingSettlement.isPresent()) {
            SalarySettlement s = existingSettlement.get();
            dto.setIsAlreadySettled(true);
            dto.setSettlementReceiptRef(s.getTransactionRef());
            dto.setSettlementStatus(s.getStatus());
        } else {
            dto.setIsAlreadySettled(false);
            dto.setSettlementReceiptRef(null);
            dto.setSettlementStatus("PENDING");
        }

        return dto;
    }

    @Override
    public SalarySettlementResponseDto settleSalary(SalarySettlementRequestDto request) {
        User maid = userRepository.findById(request.getMaidId())
                .orElseThrow(() -> new ResourceNotFoundException("Maid not found with ID: " + request.getMaidId()));

        HouseholdLocation household = householdLocationRepository.findById(request.getHouseholdId())
                .orElseThrow(() -> new ResourceNotFoundException("Household not found with ID: " + request.getHouseholdId()));

        User employer = household.getEmployer();

        // Calculate latest numbers
        SalaryCalculationResponseDto calc = calculateSalary(
                request.getMaidId(), request.getHouseholdId(), request.getYear(), request.getMonth());

        // Check if already settled
        SalarySettlement settlement = salarySettlementRepository
                .findByMaidIdAndYearAndMonth(request.getMaidId(), request.getYear(), request.getMonth())
                .orElse(new SalarySettlement());

        settlement.setMaid(maid);
        settlement.setEmployer(employer);
        settlement.setHousehold(household);
        settlement.setPayoutYear(request.getYear());
        settlement.setPayoutMonth(request.getMonth());
        settlement.setBaseSalary(calc.getMonthlyBaseSalary());
        settlement.setTotalWorkingDays(calc.getTotalWorkingDays());
        settlement.setPresentDays(calc.getPresentDays());
        settlement.setLateDays(calc.getLateDays());
        settlement.setHalfDays(calc.getHalfDays());
        settlement.setAbsentDays(calc.getAbsentDays());
        settlement.setAllowedLeaves(calc.getAllowedLeaves());
        settlement.setDeductionDays(calc.getEffectiveDeductionDays());
        settlement.setDeductionAmount(calc.getDeductionAmount());
        settlement.setNetAmount(calc.getNetPayableSalary());
        settlement.setPaymentMode(request.getPaymentMode() != null ? request.getPaymentMode() : "UPI");

        String txRef = request.getTransactionRef();
        if (txRef == null || txRef.trim().isEmpty()) {
            txRef = String.format("REC-%04d%02d-%d-%s",
                    request.getYear(), request.getMonth(), maid.getId(),
                    UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        settlement.setTransactionRef(txRef);
        settlement.setStatus("SETTLED");
        settlement.setSettledAt(LocalDateTime.now());
        settlement.setNotes(request.getNotes());

        SalarySettlement saved = salarySettlementRepository.save(settlement);

        // Record Notifications
        String monthName = YearMonth.of(request.getYear(), request.getMonth())
                .getMonth().getDisplayName(TextStyle.FULL, Locale.ENGLISH);

        // 1. Notification to Maid
        String maidNotifTitle = "वेतन प्राप्त (Salary Received): ₹" + saved.getNetAmount().intValue();
        String maidNotifBody = String.format("₹%s salary for %s %d settled via %s by %s. Ref: %s",
                saved.getNetAmount().toPlainString(), monthName, saved.getPayoutYear(),
                saved.getPaymentMode(), employer.getFullName(), saved.getTransactionRef());

        notificationService.recordNotification(
                maid.getId(),
                household.getId(),
                maidNotifTitle,
                maidNotifBody,
                "PAYOUT"
        );

        // 2. Notification to Employer
        String employerNotifTitle = "वेतन भुगतान सफल (Salary Paid): ₹" + saved.getNetAmount().intValue();
        String employerNotifBody = String.format("₹%s salary paid to %s for %s %d via %s. Receipt: %s",
                saved.getNetAmount().toPlainString(), maid.getFullName(), monthName,
                saved.getPayoutYear(), saved.getPaymentMode(), saved.getTransactionRef());

        notificationService.recordNotification(
                employer.getId(),
                household.getId(),
                employerNotifTitle,
                employerNotifBody,
                "PAYOUT"
        );

        // 3. Real-time Firebase Cloud Messaging (FCM) Push Notifications
        Map<String, String> fcmPayload = new HashMap<>();
        fcmPayload.put("type", "PAYOUT");
        fcmPayload.put("settlementId", String.valueOf(saved.getId()));
        fcmPayload.put("amount", saved.getNetAmount().toPlainString());
        fcmPayload.put("transactionRef", saved.getTransactionRef());
        fcmPayload.put("paymentMode", saved.getPaymentMode());
        fcmPayload.put("maidId", String.valueOf(maid.getId()));
        fcmPayload.put("householdId", String.valueOf(household.getId()));
        fcmPayload.put("year", String.valueOf(saved.getPayoutYear()));
        fcmPayload.put("month", String.valueOf(saved.getPayoutMonth()));

        fcmNotificationService.sendPushNotification(maid.getId(), maidNotifTitle, maidNotifBody, fcmPayload);
        fcmNotificationService.sendPushNotification(employer.getId(), employerNotifTitle, employerNotifBody, fcmPayload);

        return mapToDto(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public SalarySettlementResponseDto getReceiptById(Long settlementId) {
        SalarySettlement settlement = salarySettlementRepository.findById(settlementId)
                .orElseThrow(() -> new ResourceNotFoundException("Salary settlement receipt not found with ID: " + settlementId));
        return mapToDto(settlement);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SalarySettlementResponseDto> getSettlementHistoryForMaid(Long maidId) {
        return salarySettlementRepository.findByMaidIdOrderBySettledAtDesc(maidId)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<SalarySettlementResponseDto> getSettlementHistoryForHousehold(Long householdId) {
        return salarySettlementRepository.findByHouseholdIdOrderBySettledAtDesc(householdId)
                .stream().map(this::mapToDto).collect(Collectors.toList());
    }

    private SalarySettlementResponseDto mapToDto(SalarySettlement s) {
        SalarySettlementResponseDto dto = new SalarySettlementResponseDto();
        dto.setId(s.getId());
        dto.setMaidId(s.getMaid().getId());
        dto.setMaidName(s.getMaid().getFullName());
        dto.setMaidUpiId(s.getMaid().getUpiId());
        dto.setMaidPhoneNumber(s.getMaid().getPhoneNumber());

        dto.setEmployerId(s.getEmployer().getId());
        dto.setEmployerName(s.getEmployer().getFullName());

        dto.setHouseholdId(s.getHousehold().getId());
        dto.setHouseName(s.getHousehold().getHouseName());

        dto.setPayoutYear(s.getPayoutYear());
        dto.setPayoutMonth(s.getPayoutMonth());
        dto.setBaseSalary(s.getBaseSalary());
        dto.setTotalWorkingDays(s.getTotalWorkingDays());
        dto.setPresentDays(s.getPresentDays());
        dto.setLateDays(s.getLateDays());
        dto.setHalfDays(s.getHalfDays());
        dto.setAbsentDays(s.getAbsentDays());
        dto.setAllowedLeaves(s.getAllowedLeaves());
        dto.setDeductionDays(s.getDeductionDays());
        dto.setDeductionAmount(s.getDeductionAmount());
        dto.setNetAmount(s.getNetAmount());
        dto.setPaymentMode(s.getPaymentMode());
        dto.setTransactionRef(s.getTransactionRef());
        dto.setStatus(s.getStatus());
        dto.setSettledAt(s.getSettledAt());
        dto.setNotes(s.getNotes());
        return dto;
    }
}
