import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WorkCompletedCard extends StatelessWidget {
  final String? checkInTimeString;
  final String? checkOutTimeString;
  final String workDurationString;
  final bool isContrast;

  const WorkCompletedCard({
    super.key,
    this.checkInTimeString,
    this.checkOutTimeString,
    required this.workDurationString,
    required this.isContrast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isContrast ? Colors.green.shade900.withOpacity(0.3) : const Color(0xFFE6F4EA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? Colors.greenAccent : const Color(0xFF34A853),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF137333), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'आज का कार्य समाप्त (Work Completed Today)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.white : const Color(0xFF137333),
                      ),
                    ),
                    Text(
                      'Departure verified via zero-touch geofence departure',
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isContrast ? Colors.black45 : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Check-In', style: TextStyle(fontSize: 11, color: isContrast ? Colors.white70 : AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(checkInTimeString ?? '08:00 AM', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text('Check-Out', style: TextStyle(fontSize: 11, color: isContrast ? Colors.white70 : AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(checkOutTimeString ?? '--:--', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text('Total Duration', style: TextStyle(fontSize: 11, color: isContrast ? Colors.white70 : AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      workDurationString.isNotEmpty ? workDurationString : '--',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF137333)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Employer notified via push alert • Total hours recorded in monthly ledger for salary computation.',
            style: TextStyle(fontSize: 10, color: isContrast ? Colors.white70 : const Color(0xFF1E4620)),
          ),
        ],
      ),
    );
  }
}
