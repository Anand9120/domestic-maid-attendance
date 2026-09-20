package com.app.maidattendance.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class SalarySettlementRequestDto {

    @NotNull(message = "maidId is required")
    private Long maidId;

    @NotNull(message = "householdId is required")
    private Long householdId;

    @NotNull(message = "year is required")
    private Integer year;

    @NotNull(message = "month is required")
    @Min(1)
    @Max(12)
    private Integer month;

    private String paymentMode = "UPI"; // "UPI", "CASH", "BANK_TRANSFER"

    private String transactionRef; // e.g. UPI UTR number or empty to auto-generate

    private String notes;

    public SalarySettlementRequestDto() {}

    public Long getMaidId() { return maidId; }
    public void setMaidId(Long maidId) { this.maidId = maidId; }

    public Long getHouseholdId() { return householdId; }
    public void setHouseholdId(Long householdId) { this.householdId = householdId; }

    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }

    public Integer getMonth() { return month; }
    public void setMonth(Integer month) { this.month = month; }

    public String getPaymentMode() { return paymentMode; }
    public void setPaymentMode(String paymentMode) { this.paymentMode = paymentMode; }

    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
