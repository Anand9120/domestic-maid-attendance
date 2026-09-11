package com.app.maidattendance.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "maid_household_assignments", 
       uniqueConstraints = @UniqueConstraint(name = "uq_maid_household", columnNames = {"maid_id", "household_id"}))
public class MaidHouseholdAssignment {

    public enum Status {
        ACTIVE,
        INACTIVE
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "maid_id", nullable = false)
    private User maid;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    private HouseholdLocation householdLocation;

    @Column(name = "assigned_at", updatable = false)
    private LocalDateTime assignedAt = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Status status = Status.ACTIVE;

    public MaidHouseholdAssignment() {}

    public MaidHouseholdAssignment(Long id, User maid, HouseholdLocation householdLocation, Status status) {
        this.id = id;
        this.maid = maid;
        this.householdLocation = householdLocation;
        this.status = status != null ? status : Status.ACTIVE;
        this.assignedAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getMaid() { return maid; }
    public void setMaid(User maid) { this.maid = maid; }

    public HouseholdLocation getHouseholdLocation() { return householdLocation; }
    public void setHouseholdLocation(HouseholdLocation householdLocation) { this.householdLocation = householdLocation; }

    public LocalDateTime getAssignedAt() { return assignedAt; }
    public void setAssignedAt(LocalDateTime assignedAt) { this.assignedAt = assignedAt; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }
}
