package com.app.maidattendance.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;

public class HouseholdSetupRequestDto {

    private Long householdId;

    @NotNull(message = "Employer ID is required")
    private Long employerId;

    @NotBlank(message = "House name is required")
    private String houseName;

    private String address;

    @NotNull(message = "Latitude is required")
    private BigDecimal latitude;

    @NotNull(message = "Longitude is required")
    private BigDecimal longitude;

    private Integer geofenceRadiusMeters = 50;

    private Integer dwellTimeMinutes = 3;

    private String inviteCode;

    private BigDecimal monthlySalary = BigDecimal.ZERO;

    private Integer allowedLeaves = 2;

    private List<ShiftDto> shifts;

    public static class ShiftDto {
        private String shiftName;
        private LocalTime startTime;
        private LocalTime endTime;
        private Integer gracePeriodMinutes = 15;

        public ShiftDto() {}

        public ShiftDto(String shiftName, LocalTime startTime, LocalTime endTime, Integer gracePeriodMinutes) {
            this.shiftName = shiftName;
            this.startTime = startTime;
            this.endTime = endTime;
            this.gracePeriodMinutes = gracePeriodMinutes != null ? gracePeriodMinutes : 15;
        }

        public String getShiftName() { return shiftName; }
        public void setShiftName(String shiftName) { this.shiftName = shiftName; }
        public LocalTime getStartTime() { return startTime; }
        public void setStartTime(LocalTime startTime) { this.startTime = startTime; }
        public LocalTime getEndTime() { return endTime; }
        public void setEndTime(LocalTime endTime) { this.endTime = endTime; }
        public Integer getGracePeriodMinutes() { return gracePeriodMinutes; }
        public void setGracePeriodMinutes(Integer gracePeriodMinutes) { this.gracePeriodMinutes = gracePeriodMinutes; }
    }

    public HouseholdSetupRequestDto() {}

    public Long getHouseholdId() { return householdId; }
    public void setHouseholdId(Long householdId) { this.householdId = householdId; }

    public Long getEmployerId() { return employerId; }
    public void setEmployerId(Long employerId) { this.employerId = employerId; }

    public String getHouseName() { return houseName; }
    public void setHouseName(String houseName) { this.houseName = houseName; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public Integer getGeofenceRadiusMeters() { return geofenceRadiusMeters; }
    public void setGeofenceRadiusMeters(Integer geofenceRadiusMeters) { this.geofenceRadiusMeters = geofenceRadiusMeters; }

    public Integer getDwellTimeMinutes() { return dwellTimeMinutes; }
    public void setDwellTimeMinutes(Integer dwellTimeMinutes) { this.dwellTimeMinutes = dwellTimeMinutes; }

    public String getInviteCode() { return inviteCode; }
    public void setInviteCode(String inviteCode) { this.inviteCode = inviteCode; }

    public BigDecimal getMonthlySalary() { return monthlySalary; }
    public void setMonthlySalary(BigDecimal monthlySalary) { this.monthlySalary = monthlySalary; }

    public Integer getAllowedLeaves() { return allowedLeaves; }
    public void setAllowedLeaves(Integer allowedLeaves) { this.allowedLeaves = allowedLeaves; }

    public List<ShiftDto> getShifts() { return shifts; }
    public void setShifts(List<ShiftDto> shifts) { this.shifts = shifts; }
}
