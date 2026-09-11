package com.app.maidattendance.service;

import java.math.BigDecimal;

public interface GeofenceValidationService {
    double calculateDistanceMeters(BigDecimal lat1, BigDecimal lon1, BigDecimal lat2, BigDecimal lon2);
    boolean isWithinGeofence(BigDecimal currentLat, BigDecimal currentLon, 
                            BigDecimal targetLat, BigDecimal targetLon, 
                            int radiusMeters);
}
