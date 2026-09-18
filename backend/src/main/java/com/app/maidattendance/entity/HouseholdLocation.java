package com.app.maidattendance.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "household_locations")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class HouseholdLocation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "employer_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User employer;

    @Column(name = "house_name", length = 100)
    private String houseName = "Home";

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(nullable = false, precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(nullable = false, precision = 11, scale = 8)
    private BigDecimal longitude;

    @Column(name = "geofence_radius_meters")
    private Integer geofenceRadiusMeters = 50;

    @Column(name = "dwell_time_minutes")
    private Integer dwellTimeMinutes = 3;

    public HouseholdLocation() {}

    public HouseholdLocation(Long id, User employer, String houseName, String address, 
                             BigDecimal latitude, BigDecimal longitude, 
                             Integer geofenceRadiusMeters, Integer dwellTimeMinutes) {
        this.id = id;
        this.employer = employer;
        this.houseName = houseName != null ? houseName : "Home";
        this.address = address;
        this.latitude = latitude;
        this.longitude = longitude;
        this.geofenceRadiusMeters = geofenceRadiusMeters != null ? geofenceRadiusMeters : 50;
        this.dwellTimeMinutes = dwellTimeMinutes != null ? dwellTimeMinutes : 3;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getEmployer() { return employer; }
    public void setEmployer(User employer) { this.employer = employer; }

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
}
