package com.app.maidattendance.dto.request;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CheckInRequestDto {

    @NotNull(message = "Maid ID is required")
    private Long maidId;

    @NotNull(message = "Household ID is required")
    private Long householdId;

    private Long shiftId;

    @NotNull(message = "Latitude is required")
    private BigDecimal latitude;

    @NotNull(message = "Longitude is required")
    private BigDecimal longitude;

    @NotNull(message = "Device timestamp is required")
    private LocalDateTime deviceTimestamp;

    private Boolean isMockLocation = false;

    private Integer dwellTimeSeconds = 180; // Default 3 mins = 180 seconds

    public CheckInRequestDto() {}

    public CheckInRequestDto(Long maidId, Long householdId, Long shiftId, BigDecimal latitude, 
                             BigDecimal longitude, LocalDateTime deviceTimestamp, 
                             Boolean isMockLocation, Integer dwellTimeSeconds) {
        this.maidId = maidId;
        this.householdId = householdId;
        this.shiftId = shiftId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.deviceTimestamp = deviceTimestamp;
        this.isMockLocation = isMockLocation != null ? isMockLocation : false;
        this.dwellTimeSeconds = dwellTimeSeconds != null ? dwellTimeSeconds : 180;
    }

    public Long getMaidId() { return maidId; }
    public void setMaidId(Long maidId) { this.maidId = maidId; }

    public Long getHouseholdId() { return householdId; }
    public void setHouseholdId(Long householdId) { this.householdId = householdId; }

    public Long getShiftId() { return shiftId; }
    public void setShiftId(Long shiftId) { this.shiftId = shiftId; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public LocalDateTime getDeviceTimestamp() { return deviceTimestamp; }
    public void setDeviceTimestamp(LocalDateTime deviceTimestamp) { this.deviceTimestamp = deviceTimestamp; }

    public Boolean getIsMockLocation() { return isMockLocation; }
    public void setIsMockLocation(Boolean isMockLocation) { this.isMockLocation = isMockLocation; }

    public Integer getDwellTimeSeconds() { return dwellTimeSeconds; }
    public void setDwellTimeSeconds(Integer dwellTimeSeconds) { this.dwellTimeSeconds = dwellTimeSeconds; }
}
