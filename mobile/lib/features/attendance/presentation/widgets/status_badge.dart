import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/attendance_log_entity.dart';

class StatusBadge extends StatelessWidget {
  final AttendanceStatus status;
  final EntryType? entryType;
  final bool isMock;

  const StatusBadge({
    super.key,
    required this.status,
    this.entryType,
    this.isMock = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case AttendanceStatus.present:
        bg = AppColors.presentBg;
        fg = AppColors.present;
        label = 'Present';
        icon = Icons.check_circle_rounded;
        break;
      case AttendanceStatus.late:
        bg = AppColors.lateBg;
        fg = AppColors.late;
        label = 'Late';
        icon = Icons.access_time_rounded;
        break;
      case AttendanceStatus.halfDay:
        bg = AppColors.halfDayBg;
        fg = AppColors.halfDay;
        label = 'Half-Day';
        icon = Icons.hourglass_bottom_rounded;
        break;
      case AttendanceStatus.absent:
        bg = AppColors.absentBg;
        fg = AppColors.absent;
        label = 'Absent';
        icon = Icons.cancel_rounded;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: fg.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (entryType == EntryType.offlineSync) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: const Text(
              'Offline',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        if (isMock) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: const Text(
              '⚠️ Mock GPS',
              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
