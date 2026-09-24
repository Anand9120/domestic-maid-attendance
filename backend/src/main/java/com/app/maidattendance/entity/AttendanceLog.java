package com.app.maidattendance.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "attendance_logs", 
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_maid_household_date_shift", columnNames = {"maid_id", "household_id", "attendance_date", "shift_id"})
    },
    indexes = {
        @Index(name = "idx_attendance_maid_date", columnList = "maid_id, attendance_date"),
        @Index(name = "idx_attendance_household_date", columnList = "household_id, attendance_date")
    }
)
public class AttendanceLog {

    public enum AttendanceStatus {
        PRESENT,
        ABSENT,
        LATE,
        HALF_DAY
    }

    public enum EntryType {
        AUTOMATED_GEOFENCE,
        OFFLINE_SYNC,
        MANUAL_OVERRIDE
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

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shift_id")
    private ShiftSchedule shiftSchedule;

    @Column(name = "attendance_date", nullable = false)
    private LocalDate attendanceDate;

    @Column(name = "check_in_time")
    private LocalTime checkInTime;

    @Column(name = "check_out_time")
    private LocalTime checkOutTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AttendanceStatus status = AttendanceStatus.PRESENT;

    @Enumerated(EnumType.STRING)
    @Column(name = "entry_type", nullable = false, length = 30)
    private EntryType entryType = EntryType.AUTOMATED_GEOFENCE;

    @Column(name = "device_timestamp", nullable = false)
    private LocalDateTime deviceTimestamp;

    @Column(name = "server_timestamp", updatable = false)
    private LocalDateTime serverTimestamp = LocalDateTime.now();

    @Column(name = "is_mock_location")
    private Boolean isMockLocation = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "override_by_employer_id")
    private User overrideByEmployer;

    public AttendanceLog() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getMaid() { return maid; }
    public void setMaid(User maid) { this.maid = maid; }

    public HouseholdLocation getHouseholdLocation() { return householdLocation; }
    public void setHouseholdLocation(HouseholdLocation householdLocation) { this.householdLocation = householdLocation; }

    public ShiftSchedule getShiftSchedule() { return shiftSchedule; }
    public void setShiftSchedule(ShiftSchedule shiftSchedule) { this.shiftSchedule = shiftSchedule; }

    public LocalDate getAttendanceDate() { return attendanceDate; }
    public void setAttendanceDate(LocalDate attendanceDate) { this.attendanceDate = attendanceDate; }

    public LocalTime getCheckInTime() { return checkInTime; }
    public void setCheckInTime(LocalTime checkInTime) { this.checkInTime = checkInTime; }

    public LocalTime getCheckOutTime() { return checkOutTime; }
    public void setCheckOutTime(LocalTime checkOutTime) { this.checkOutTime = checkOutTime; }

    public AttendanceStatus getStatus() { return status; }
    public void setStatus(AttendanceStatus status) { this.status = status; }

    public EntryType getEntryType() { return entryType; }
    public void setEntryType(EntryType entryType) { this.entryType = entryType; }

    public LocalDateTime getDeviceTimestamp() { return deviceTimestamp; }
    public void setDeviceTimestamp(LocalDateTime deviceTimestamp) { this.deviceTimestamp = deviceTimestamp; }

    public LocalDateTime getServerTimestamp() { return serverTimestamp; }
    public void setServerTimestamp(LocalDateTime serverTimestamp) { this.serverTimestamp = serverTimestamp; }

    public Boolean getIsMockLocation() { return isMockLocation; }
    public void setIsMockLocation(Boolean isMockLocation) { this.isMockLocation = isMockLocation; }

    public User getOverrideByEmployer() { return overrideByEmployer; }
    public void setOverrideByEmployer(User overrideByEmployer) { this.overrideByEmployer = overrideByEmployer; }
}
