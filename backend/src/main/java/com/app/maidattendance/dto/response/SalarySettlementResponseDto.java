package com.app.maidattendance.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class SalarySettlementResponseDto {

    private Long id;
    private Long maidId;
    private String maidName;
    private String maidUpiId;
    private String maidPhoneNumber;

    private Long employerId;
    private String employerName;

    private Long householdId;
    private String houseName;

    private Integer payoutYear;
    private Integer payoutMonth;

    private BigDecimal baseSalary;
    private Integer totalWorkingDays;
    private Integer presentDays;
    private Integer lateDays;
    private Integer halfDays;
    private Integer absentDays;
    private Integer allowedLeaves;

    private BigDecimal deductionDays;
    private BigDecimal deductionAmount;
    private BigDecimal netAmount;

    private String paymentMode;
    private String transactionRef;
    private String status;
    private LocalDateTime settledAt;
    private String notes;

    public SalarySettlementResponseDto() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getMaidId() { return maidId; }
    public void setMaidId(Long maidId) { this.maidId = maidId; }

    public String getMaidName() { return maidName; }
    public void setMaidName(String maidName) { this.maidName = maidName; }

    public String getMaidUpiId() { return maidUpiId; }
    public void setMaidUpiId(String maidUpiId) { this.maidUpiId = maidUpiId; }

    public String getMaidPhoneNumber() { return maidPhoneNumber; }
    public void setMaidPhoneNumber(String maidPhoneNumber) { this.maidPhoneNumber = maidPhoneNumber; }

    public Long getEmployerId() { return employerId; }
    public void setEmployerId(Long employerId) { this.employerId = employerId; }

    public String getEmployerName() { return employerName; }
    public void setEmployerName(String employerName) { this.employerName = employerName; }

    public Long getHouseholdId() { return householdId; }
    public void setHouseholdId(Long householdId) { this.householdId = householdId; }

    public String getHouseName() { return houseName; }
    public void setHouseName(String houseName) { this.houseName = houseName; }

    public Integer getPayoutYear() { return payoutYear; }
    public void setPayoutYear(Integer payoutYear) { this.payoutYear = payoutYear; }

    public Integer getPayoutMonth() { return payoutMonth; }
    public void setPayoutMonth(Integer payoutMonth) { this.payoutMonth = payoutMonth; }

    public BigDecimal getBaseSalary() { return baseSalary; }
    public void setBaseSalary(BigDecimal baseSalary) { this.baseSalary = baseSalary; }

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

    public BigDecimal getDeductionDays() { return deductionDays; }
    public void setDeductionDays(BigDecimal deductionDays) { this.deductionDays = deductionDays; }

    public BigDecimal getDeductionAmount() { return deductionAmount; }
    public void setDeductionAmount(BigDecimal deductionAmount) { this.deductionAmount = deductionAmount; }

    public BigDecimal getNetAmount() { return netAmount; }
    public void setNetAmount(BigDecimal netAmount) { this.netAmount = netAmount; }

    public String getPaymentMode() { return paymentMode; }
    public void setPaymentMode(String paymentMode) { this.paymentMode = paymentMode; }

    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getSettledAt() { return settledAt; }
    public void setSettledAt(LocalDateTime settledAt) { this.settledAt = settledAt; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
