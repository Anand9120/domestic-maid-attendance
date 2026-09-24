import '../../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class DepartureCountdownBanner extends StatelessWidget {
  final int departureCountdown;
  final double? distanceMeters;
  final double geofenceRadiusMeters;
  final bool isContrast;

  const DepartureCountdownBanner({
    super.key,
    required this.departureCountdown,
    this.distanceMeters,
    required this.geofenceRadiusMeters,
    required this.isContrast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.darkLateBg : const Color(0xFFFEF7E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? AppColors.darkLate : const Color(0xFFF9AB00),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_walk_rounded, color: Color(0xFFB06000), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maid Stepped Outside Boundary',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? AppColors.darkLate : const Color(0xFFB06000),
                      ),
                    ),
                    Text(
                      'Distance: ${distanceMeters?.toStringAsFixed(1) ?? "--"}m (Geofence: ${geofenceRadiusMeters.toInt()}m)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : const Color(0xFF5F6368),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isContrast ? AppColors.darkSurfaceElevated : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF9AB00)),
                ),
                child: Text(
                  'Auto Out in ${departureCountdown}s',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB06000),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (departureCountdown / 60.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB06000)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '60-second anti-bounce buffer running. If maid re-enters home before timer ends (e.g. from balcony/staircase), check-out is cancelled automatically.',
            style: TextStyle(
              fontSize: 11,
              color: isContrast ? Colors.white70 : const Color(0xFF5F6368),
            ),
          ),
        ],
      ),
    );
  }
}
