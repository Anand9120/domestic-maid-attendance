package com.app.maidattendance.dto.request;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CheckOutRequestDto {

    @NotNull(message = "Maid ID is required")
    private Long maidId;

    @NotNull(message = "Household ID is required")
    private Long householdId;

    @NotNull(message = "Latitude is required")
    private BigDecimal latitude;

    @NotNull(message = "Longitude is required")
    private BigDecimal longitude;

    @NotNull(message = "Device timestamp is required")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime deviceTimestamp;

    private Boolean isMockLocation = false;

    public CheckOutRequestDto() {}

    public CheckOutRequestDto(Long maidId, Long householdId, BigDecimal latitude, BigDecimal longitude,
                              LocalDateTime deviceTimestamp, Boolean isMockLocation) {
        this.maidId = maidId;
        this.householdId = householdId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.deviceTimestamp = deviceTimestamp;
        this.isMockLocation = isMockLocation != null ? isMockLocation : false;
    }

    public Long getMaidId() { return maidId; }
    public void setMaidId(Long maidId) { this.maidId = maidId; }

    public Long getHouseholdId() { return householdId; }
    public void setHouseholdId(Long householdId) { this.householdId = householdId; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public LocalDateTime getDeviceTimestamp() { return deviceTimestamp; }
    public void setDeviceTimestamp(LocalDateTime deviceTimestamp) { this.deviceTimestamp = deviceTimestamp; }

    public Boolean getIsMockLocation() { return isMockLocation; }
    public void setIsMockLocation(Boolean mockLocation) { isMockLocation = mockLocation; }
}
