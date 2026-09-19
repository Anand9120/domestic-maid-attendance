import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WorkInProgressCard extends StatelessWidget {
  final String? checkInTimeString;
  final double? distanceMeters;
  final String elapsedDurationString;
  final bool isContrast;

  const WorkInProgressCard({
    super.key,
    this.checkInTimeString,
    this.distanceMeters,
    required this.elapsedDurationString,
    required this.isContrast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcSurface : const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? Colors.lightBlueAccent : const Color(0xFF1A73E8),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work_rounded, color: Color(0xFF1A73E8), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'कार्य प्रगति पर है (Work In Progress)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.white : const Color(0xFF174EA6),
                      ),
                    ),
                    Text(
                      'Arrival at ${checkInTimeString ?? "08:00 AM"} • Inside Geofence (${distanceMeters?.toStringAsFixed(1) ?? "--"}m)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : const Color(0xFF3C4043),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isContrast ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1A73E8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      elapsedDurationString,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Zero-Touch Departure Tracking Active: When work is finished and the maid leaves the 50m boundary, departure is logged automatically after a 60-second buffer.',
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
