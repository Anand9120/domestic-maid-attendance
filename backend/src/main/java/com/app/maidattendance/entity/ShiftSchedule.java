package com.app.maidattendance.entity;

import jakarta.persistence.*;
import java.time.LocalTime;

@Entity
@Table(name = "shift_schedules")
public class ShiftSchedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "household_id", nullable = false)
    private HouseholdLocation householdLocation;

    @Column(name = "shift_name", nullable = false, length = 50)
    private String shiftName;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime;

    @Column(name = "grace_period_minutes")
    private Integer gracePeriodMinutes = 15;

    public ShiftSchedule() {}

    public ShiftSchedule(Long id, HouseholdLocation householdLocation, String shiftName, 
                         LocalTime startTime, LocalTime endTime, Integer gracePeriodMinutes) {
        this.id = id;
        this.householdLocation = householdLocation;
        this.shiftName = shiftName;
        this.startTime = startTime;
        this.endTime = endTime;
        this.gracePeriodMinutes = gracePeriodMinutes != null ? gracePeriodMinutes : 15;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public HouseholdLocation getHouseholdLocation() { return householdLocation; }
    public void setHouseholdLocation(HouseholdLocation householdLocation) { this.householdLocation = householdLocation; }

    public String getShiftName() { return shiftName; }
    public void setShiftName(String shiftName) { this.shiftName = shiftName; }

    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }

    public LocalTime getEndTime() { return endTime; }
    public void setEndTime(LocalTime endTime) { this.endTime = endTime; }

    public Integer getGracePeriodMinutes() { return gracePeriodMinutes; }
    public void setGracePeriodMinutes(Integer gracePeriodMinutes) { this.gracePeriodMinutes = gracePeriodMinutes; }
}
