package com.app.maidattendance.service;

import com.app.maidattendance.service.impl.GeofenceValidationServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class GeofenceValidationServiceTest {

    private GeofenceValidationService geofenceValidationService;

    @BeforeEach
    void setUp() {
        geofenceValidationService = new GeofenceValidationServiceImpl();
    }

    @Test
    @DisplayName("Should detect coordinates within 50-meter household boundary")
    void testWithinGeofence() {
        // Household center: 28.6315000, 77.2167000
        BigDecimal centerLat = new BigDecimal("28.6315000");
        BigDecimal centerLon = new BigDecimal("77.2167000");

        // Maid location ~20 meters away
        BigDecimal maidLat = new BigDecimal("28.6316500");
        BigDecimal maidLon = new BigDecimal("77.2167800");

        double distance = geofenceValidationService.calculateDistanceMeters(maidLat, maidLon, centerLat, centerLon);
        assertTrue(distance < 50.0, "Distance should be under 50 meters, was: " + distance);

        boolean withinGeofence = geofenceValidationService.isWithinGeofence(maidLat, maidLon, centerLat, centerLon, 50);
        assertTrue(withinGeofence, "Maid should be inside 50m geofence");
    }

    @Test
    @DisplayName("Should reject coordinates outside 50-meter household boundary")
    void testOutsideGeofence() {
        BigDecimal centerLat = new BigDecimal("28.6315000");
        BigDecimal centerLon = new BigDecimal("77.2167000");

        // Maid location ~500 meters away
        BigDecimal farLat = new BigDecimal("28.6360000");
        BigDecimal farLon = new BigDecimal("77.2167000");

        double distance = geofenceValidationService.calculateDistanceMeters(farLat, farLon, centerLat, centerLon);
        assertTrue(distance > 50.0, "Distance should exceed 50 meters, was: " + distance);

        boolean withinGeofence = geofenceValidationService.isWithinGeofence(farLat, farLon, centerLat, centerLon, 50);
        assertFalse(withinGeofence, "Maid should be outside 50m geofence");
    }
}
