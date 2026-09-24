import 'package:flutter/material.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';

class GeofencePresenceRadarCard extends StatelessWidget {
  final bool isInsideGeofence;
  final double? distanceMeters;
  final int dwellCountdown;
  final int requiredDwellSeconds;
  final bool isContrast;
  final AccessibilityController a11y;

  const GeofencePresenceRadarCard({
    super.key,
    required this.isInsideGeofence,
    this.distanceMeters,
    required this.dwellCountdown,
    required this.requiredDwellSeconds,
    required this.isContrast,
    required this.a11y,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = distanceMeters != null
        ? '${distanceMeters!.toStringAsFixed(1)}m'
        : '...';

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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isInsideGeofence
                      ? (isContrast ? AppColors.darkPresentBg : AppColors.present.withOpacity(0.1))
                      : (isContrast ? Colors.white12 : AppColors.border),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.radar_rounded,
                  size: 26,
                  color: isInsideGeofence
                      ? (isContrast ? AppColors.darkPresent : AppColors.present)
                      : (isContrast ? Colors.white60 : AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a11y.tr('live_presence_radar'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isInsideGeofence
                          ? '${a11y.tr('inside_geofence')} ($distanceText)'
                          : '${a11y.tr('outside_geofence')} ($distanceText)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isInsideGeofence
                            ? (isContrast ? AppColors.darkPresent : AppColors.present)
                            : (isContrast ? Colors.white70 : AppColors.textSecondary),
                        fontWeight: isInsideGeofence ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isInsideGeofence) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (dwellCountdown / requiredDwellSeconds).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: isContrast ? Colors.white24 : AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  dwellCountdown >= requiredDwellSeconds
                      ? (isContrast ? AppColors.darkPresent : AppColors.present)
                      : (isContrast ? AppColors.darkLate : AppColors.late),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dwellCountdown >= requiredDwellSeconds ? a11y.tr('dwell_completed') : a11y.tr('dwell_counting'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isContrast ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$dwellCountdown / ${requiredDwellSeconds}s',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: dwellCountdown >= requiredDwellSeconds
                        ? (isContrast ? AppColors.darkPresent : AppColors.present)
                        : (isContrast ? AppColors.darkLate : AppColors.late),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
