package com.app.maidattendance.dto.response;

import com.app.maidattendance.entity.AttendanceLog;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class AttendanceLogResponseDto {

    private Long id;
    private Long maidId;
    private String maidName;
    private Long householdId;
    private String houseName;
    private Long shiftId;
    private String shiftName;
    private LocalDate attendanceDate;
    private LocalTime checkInTime;
    private LocalTime checkOutTime;
    private AttendanceLog.AttendanceStatus status;
    private AttendanceLog.EntryType entryType;
    private LocalDateTime deviceTimestamp;
    private LocalDateTime serverTimestamp;
    private Boolean isMockLocation;
    private String overrideByEmployerName;

    public AttendanceLogResponseDto() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getMaidId() { return maidId; }
    public void setMaidId(Long maidId) { this.maidId = maidId; }

    public String getMaidName() { return maidName; }
    public void setMaidName(String maidName) { this.maidName = maidName; }

    public Long getHouseholdId() { return householdId; }
    public void setHouseholdId(Long householdId) { this.householdId = householdId; }

    public String getHouseName() { return houseName; }
    public void setHouseName(String houseName) { this.houseName = houseName; }

    public Long getShiftId() { return shiftId; }
    public void setShiftId(Long shiftId) { this.shiftId = shiftId; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }

    public LocalDate getAttendanceDate() { return attendanceDate; }
    public void setAttendanceDate(LocalDate attendanceDate) { this.attendanceDate = attendanceDate; }

    public LocalTime getCheckInTime() { return checkInTime; }
    public void setCheckInTime(LocalTime checkInTime) { this.checkInTime = checkInTime; }

    public LocalTime getCheckOutTime() { return checkOutTime; }
    public void setCheckOutTime(LocalTime checkOutTime) { this.checkOutTime = checkOutTime; }

    public AttendanceLog.AttendanceStatus getStatus() { return status; }
    public void setStatus(AttendanceLog.AttendanceStatus status) { this.status = status; }

    public AttendanceLog.EntryType getEntryType() { return entryType; }
    public void setEntryType(AttendanceLog.EntryType entryType) { this.entryType = entryType; }

    public LocalDateTime getDeviceTimestamp() { return deviceTimestamp; }
    public void setDeviceTimestamp(LocalDateTime deviceTimestamp) { this.deviceTimestamp = deviceTimestamp; }

    public LocalDateTime getServerTimestamp() { return serverTimestamp; }
    public void setServerTimestamp(LocalDateTime serverTimestamp) { this.serverTimestamp = serverTimestamp; }

    public Boolean getIsMockLocation() { return isMockLocation; }
    public void setIsMockLocation(Boolean isMockLocation) { this.isMockLocation = isMockLocation; }

    public String getOverrideByEmployerName() { return overrideByEmployerName; }
    public void setOverrideByEmployerName(String overrideByEmployerName) { this.overrideByEmployerName = overrideByEmployerName; }
}
