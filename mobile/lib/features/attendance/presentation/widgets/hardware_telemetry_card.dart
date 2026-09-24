import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/ux4g/ux4g.dart';

class HardwareTelemetryCard extends StatelessWidget {
  final Position? currentPosition;
  final bool isLoadingGps;
  final String gpsStatusInfo;
  final double? currentDistanceMeters;
  final double geofenceRadiusMeters;
  final String targetHouseName;
  final double targetLat;
  final double targetLon;
  final bool isInsideGeofence;
  final bool isMockGpsDetected;
  final bool hasCheckedInToday;
  final int requiredDwellSeconds;
  final bool isEmployer;
  final bool isCalibrating;
  final VoidCallback? onCalibrate;
  final AccessibilityController a11y;
  final bool isContrast;

  const HardwareTelemetryCard({
    super.key,
    this.currentPosition,
    required this.isLoadingGps,
    required this.gpsStatusInfo,
    this.currentDistanceMeters,
    required this.geofenceRadiusMeters,
    required this.targetHouseName,
    required this.targetLat,
    required this.targetLon,
    required this.isInsideGeofence,
    required this.isMockGpsDetected,
    required this.hasCheckedInToday,
    required this.requiredDwellSeconds,
    required this.isEmployer,
    required this.isCalibrating,
    this.onCalibrate,
    required this.a11y,
    required this.isContrast,
  });

  @override
  Widget build(BuildContext context) {
    final pos = currentPosition;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? AppColors.hcBorder : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  a11y.tr('realtime_telemetry'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isContrast ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isInsideGeofence
                      ? (isContrast ? AppColors.darkPresentBg : AppColors.present.withOpacity(0.1))
                      : (isContrast ? Colors.white12 : Colors.grey.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isInsideGeofence ? 'IN BOUNDARY' : 'OUT OF RANGE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isInsideGeofence
                        ? (isContrast ? AppColors.darkPresent : AppColors.present)
                        : (isContrast ? Colors.white70 : AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Target: $targetHouseName (${geofenceRadiusMeters.toInt()}m radius at ${targetLat.toStringAsFixed(4)}, ${targetLon.toStringAsFixed(4)})',
            style: TextStyle(
              fontSize: 11,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Live Telemetry Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isContrast ? Colors.black45 : const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isContrast ? AppColors.hcBorder : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _buildTelemetryRow(
                  '🛰️ Device GPS:',
                  pos != null
                      ? '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}'
                      : (isLoadingGps ? 'Fixing...' : gpsStatusInfo),
                  isContrast,
                ),
                const SizedBox(height: 6),
                _buildTelemetryRow(
                  '🎯 Accuracy / Range:',
                  pos != null
                      ? '±${pos.accuracy.toStringAsFixed(1)}m (Range: ${geofenceRadiusMeters.toInt()}m)'
                      : '--',
                  isContrast,
                ),
                const SizedBox(height: 6),
                _buildTelemetryRow(
                  '📏 ${a11y.tr('distance_to_target')}:',
                  currentDistanceMeters != null
                      ? '${currentDistanceMeters!.toStringAsFixed(1)} meters'
                      : '--',
                  isContrast,
                  valueColor: isInsideGeofence ? AppColors.present : AppColors.late,
                  isBold: true,
                ),
                const SizedBox(height: 6),
                _buildTelemetryRow(
                  '🛡️ Hardware Spoof Check:',
                  isMockGpsDetected
                      ? '⚠️ MOCK GPS DETECTED'
                      : '✅ Authentic Hardware GPS',
                  isContrast,
                  valueColor: isMockGpsDetected ? AppColors.absent : AppColors.present,
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Employer Calibration Button: Calibrate Geofence to Tester's Real GPS
          if (isEmployer) ...[
            SizedBox(
              width: double.infinity,
              child: Ux4gButton(
                text: isCalibrating ? a11y.tr('calibrating') : a11y.tr('calibrate_location'),
                variant: Ux4gButtonVariant.secondary,
                size: Ux4gButtonSize.medium,
                leadingIcon: Icons.my_location_rounded,
                isLoading: isCalibrating,
                onPressed: isCalibrating ? null : onCalibrate,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Zero-Touch Automation Status Banner
          if (hasCheckedInToday) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isContrast ? Colors.green.shade900.withOpacity(0.3) : const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isContrast ? Colors.greenAccent : const Color(0xFF34A853),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 22,
                    color: isContrast ? Colors.greenAccent : const Color(0xFF137333),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zero-Touch Attendance Verified',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isContrast ? Colors.white : const Color(0xFF137333),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Arrival recorded with 3-minute physical dwell validation. Employer has been notified.',
                          style: TextStyle(
                            fontSize: 11,
                            color: isContrast ? Colors.white70 : const Color(0xFF1E4620),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isInsideGeofence) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isContrast ? Colors.amber.shade900.withOpacity(0.2) : const Color(0xFFFEF7E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isContrast ? AppColors.darkLate : const Color(0xFFF9AB00),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        size: 20,
                        color: isContrast ? AppColors.darkLate : const Color(0xFFB06000),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Zero-Touch Dwell Verification Active',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isContrast ? AppColors.darkLate : const Color(0xFFB06000),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No buttons needed. Please remain inside the household for ${requiredDwellSeconds ~/ 60} minutes to automatically log verified presence.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isContrast ? Colors.white70 : const Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isContrast ? Colors.white10 : const Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isContrast ? Colors.white24 : const Color(0xFFCBD5E0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_searching_rounded,
                    size: 18,
                    color: isContrast ? AppColors.darkPrimary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Move within ${geofenceRadiusMeters.toInt()}m of household to start automated 3-minute dwell verification.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryRow(
    String label,
    String value,
    bool isContrast, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isContrast ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
