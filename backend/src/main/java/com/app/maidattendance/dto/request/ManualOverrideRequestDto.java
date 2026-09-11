package com.app.maidattendance.dto.request;

import com.app.maidattendance.entity.AttendanceLog;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalTime;

public class ManualOverrideRequestDto {

    @NotNull(message = "Maid ID is required")
    private Long maidId;

    @NotNull(message = "Household ID is required")
    private Long householdId;

    private Long shiftId;

    @NotNull(message = "Attendance date is required")
    private LocalDate attendanceDate;

    private LocalTime checkInTime;

    private LocalTime checkOutTime;

    @NotNull(message = "Status is required (PRESENT, ABSENT, LATE, HALF_DAY)")
    private AttendanceLog.AttendanceStatus status = AttendanceLog.AttendanceStatus.PRESENT;

    @NotNull(message = "Employer ID performing override is required")
    private Long employerId;

    private String notes;

    public ManualOverrideRequestDto() {}

    public Long getMaidId() { return maidId; }
    public void setMaidId(Long maidId) { this.maidId = maidId; }

    public Long getHouseholdId() { return householdId; }
    public void setHouseholdId(Long householdId) { this.householdId = householdId; }

    public Long getShiftId() { return shiftId; }
    public void setShiftId(Long shiftId) { this.shiftId = shiftId; }

    public LocalDate getAttendanceDate() { return attendanceDate; }
    public void setAttendanceDate(LocalDate attendanceDate) { this.attendanceDate = attendanceDate; }

    public LocalTime getCheckInTime() { return checkInTime; }
    public void setCheckInTime(LocalTime checkInTime) { this.checkInTime = checkInTime; }

    public LocalTime getCheckOutTime() { return checkOutTime; }
    public void setCheckOutTime(LocalTime checkOutTime) { this.checkOutTime = checkOutTime; }

    public AttendanceLog.AttendanceStatus getStatus() { return status; }
    public void setStatus(AttendanceLog.AttendanceStatus status) { this.status = status; }

    public Long getEmployerId() { return employerId; }
    public void setEmployerId(Long employerId) { this.employerId = employerId; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
