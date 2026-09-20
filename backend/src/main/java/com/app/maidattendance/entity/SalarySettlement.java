package com.app.maidattendance.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "salary_settlements")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class SalarySettlement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "maid_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User maid;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "employer_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User employer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private HouseholdLocation household;

    @Column(name = "payout_year", nullable = false)
    private Integer payoutYear;

    @Column(name = "payout_month", nullable = false)
    private Integer payoutMonth;

    @Column(name = "base_salary", nullable = false, precision = 10, scale = 2)
    private BigDecimal baseSalary;

    @Column(name = "total_working_days", nullable = false)
    private Integer totalWorkingDays;

    @Column(name = "present_days", nullable = false)
    private Integer presentDays;

    @Column(name = "late_days", nullable = false)
    private Integer lateDays;

    @Column(name = "half_days", nullable = false)
    private Integer halfDays;

    @Column(name = "absent_days", nullable = false)
    private Integer absentDays;

    @Column(name = "allowed_leaves", nullable = false)
    private Integer allowedLeaves;

    @Column(name = "deduction_days", nullable = false, precision = 4, scale = 1)
    private BigDecimal deductionDays;

    @Column(name = "deduction_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal deductionAmount;

    @Column(name = "net_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal netAmount;

    @Column(name = "payment_mode", nullable = false, length = 20)
    private String paymentMode = "UPI";

    @Column(name = "transaction_ref", nullable = false, unique = true, length = 100)
    private String transactionRef;

    @Column(nullable = false, length = 20)
    private String status = "SETTLED";

    @Column(name = "settled_at")
    private LocalDateTime settledAt = LocalDateTime.now();

    @Column(columnDefinition = "TEXT")
    private String notes;

    public SalarySettlement() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getMaid() { return maid; }
    public void setMaid(User maid) { this.maid = maid; }

    public User getEmployer() { return employer; }
    public void setEmployer(User employer) { this.employer = employer; }

    public HouseholdLocation getHousehold() { return household; }
    public void setHousehold(HouseholdLocation household) { this.household = household; }

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
