package com.app.maidattendance.service.impl;

import com.app.maidattendance.service.GeofenceValidationService;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class GeofenceValidationServiceImpl implements GeofenceValidationService {

    private static final double EARTH_RADIUS_METERS = 6371000.0;

    @Override
    public double calculateDistanceMeters(BigDecimal lat1, BigDecimal lon1, BigDecimal lat2, BigDecimal lon2) {
        if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
            throw new IllegalArgumentException("Latitude and Longitude coordinates cannot be null");
        }

        double dLat = Math.toRadians(lat2.doubleValue() - lat1.doubleValue());
        double dLon = Math.toRadians(lon2.doubleValue() - lon1.doubleValue());

        double rLat1 = Math.toRadians(lat1.doubleValue());
        double rLat2 = Math.toRadians(lat2.doubleValue());

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(rLat1) * Math.cos(rLat2) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_METERS * c;
    }

    @Override
    public boolean isWithinGeofence(BigDecimal currentLat, BigDecimal currentLon, 
                                   BigDecimal targetLat, BigDecimal targetLon, 
                                   int radiusMeters) {
        double distance = calculateDistanceMeters(currentLat, currentLon, targetLat, targetLon);
        return distance <= radiusMeters;
    }
}
