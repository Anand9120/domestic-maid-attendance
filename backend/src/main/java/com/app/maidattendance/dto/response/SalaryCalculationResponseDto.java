package com.app.maidattendance.dto.response;

import java.math.BigDecimal;

public class SalaryCalculationResponseDto {

    private Long maidId;
    private String maidName;
    private String maidUpiId;
    private String maidPhoneNumber;

    private Long householdId;
    private String houseName;
    private Long employerId;
    private String employerName;

    private Integer year;
    private Integer month;

    private BigDecimal monthlyBaseSalary;
    private Integer totalDaysInMonth;
    private Integer totalWorkingDays;
    private Integer presentDays;
    private Integer lateDays;
    private Integer halfDays;
    private Integer absentDays;
    private Integer allowedLeaves;

    private BigDecimal dailyRate;
    private BigDecimal effectiveDeductionDays;
    private BigDecimal deductionAmount;
    private BigDecimal netPayableSalary;

    private Boolean isAlreadySettled;
    private String settlementReceiptRef;
    private String settlementStatus;

    public SalaryCalculationResponseDto() {}

    public Long getMaidId() { return maidId; }
    public void setMaidId(Long maidId) { this.maidId = maidId; }

    public String getMaidName() { return maidName; }
    public void setMaidName(String maidName) { this.maidName = maidName; }

    public String getMaidUpiId() { return maidUpiId; }
    public void setMaidUpiId(String maidUpiId) { this.maidUpiId = maidUpiId; }

    public String getMaidPhoneNumber() { return maidPhoneNumber; }
    public void setMaidPhoneNumber(String maidPhoneNumber) { this.maidPhoneNumber = maidPhoneNumber; }

    public Long getHouseholdId() { return householdId; }
    public void setHouseholdId(Long householdId) { this.householdId = householdId; }

    public String getHouseName() { return houseName; }
    public void setHouseName(String houseName) { this.houseName = houseName; }

    public Long getEmployerId() { return employerId; }
    public void setEmployerId(Long employerId) { this.employerId = employerId; }

    public String getEmployerName() { return employerName; }
    public void setEmployerName(String employerName) { this.employerName = employerName; }

    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }

    public Integer getMonth() { return month; }
    public void setMonth(Integer month) { this.month = month; }

    public BigDecimal getMonthlyBaseSalary() { return monthlyBaseSalary; }
    public void setMonthlyBaseSalary(BigDecimal monthlyBaseSalary) { this.monthlyBaseSalary = monthlyBaseSalary; }

    public Integer getTotalDaysInMonth() { return totalDaysInMonth; }
    public void setTotalDaysInMonth(Integer totalDaysInMonth) { this.totalDaysInMonth = totalDaysInMonth; }

    public Integer getTotalWorkingDays() { return totalWorkingDays; }
    public void setTotalWorkingDays(Integer totalWorkingDays) { this.totalWorkingDays = totalWorkingDays; }

    public Integer getPresentDays() { return presentDays; }
    public void setPresentDays(Integer presentDays) { this.presentDays = presentDays; }

    public Integer getLateDays() { return lateDays; }
    public void setLateDays(Integer lateDays) { this.lateDays = lateDays; }

    public Integer getHalfDays() { return halfDays; }
    public void setHalfDays(Integer halfDays) { this.halfDays = halfDays; }

    public Integer getAbsentDays() { return absentDays; }
    public void setAbsentDays(Integer absentDays) { this.absentDays = absentDays; }

    public Integer getAllowedLeaves() { return allowedLeaves; }
    public void setAllowedLeaves(Integer allowedLeaves) { this.allowedLeaves = allowedLeaves; }

    public BigDecimal getDailyRate() { return dailyRate; }
    public void setDailyRate(BigDecimal dailyRate) { this.dailyRate = dailyRate; }

    public BigDecimal getEffectiveDeductionDays() { return effectiveDeductionDays; }
    public void setEffectiveDeductionDays(BigDecimal effectiveDeductionDays) { this.effectiveDeductionDays = effectiveDeductionDays; }

    public BigDecimal getDeductionAmount() { return deductionAmount; }
    public void setDeductionAmount(BigDecimal deductionAmount) { this.deductionAmount = deductionAmount; }

    public BigDecimal getNetPayableSalary() { return netPayableSalary; }
    public void setNetPayableSalary(BigDecimal netPayableSalary) { this.netPayableSalary = netPayableSalary; }

    public Boolean getIsAlreadySettled() { return isAlreadySettled; }
    public void setIsAlreadySettled(Boolean alreadySettled) { isAlreadySettled = alreadySettled; }

    public String getSettlementReceiptRef() { return settlementReceiptRef; }
    public void setSettlementReceiptRef(String settlementReceiptRef) { this.settlementReceiptRef = settlementReceiptRef; }

    public String getSettlementStatus() { return settlementStatus; }
    public void setSettlementStatus(String settlementStatus) { this.settlementStatus = settlementStatus; }
}
