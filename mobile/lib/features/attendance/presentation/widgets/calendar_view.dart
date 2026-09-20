import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/attendance_log_entity.dart';

class MonthlyCalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final List<AttendanceLogEntity> logs;
  final Function(DateTime date, AttendanceLogEntity? log)? onDateSelected;

  const MonthlyCalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.logs,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayWeekday = DateTime(year, month, 1).weekday; // 1 = Mon, 7 = Sun

    final Map<int, AttendanceLogEntity> dayLogMap = {};
    for (final log in logs) {
      if (log.attendanceDate.year == year && log.attendanceDate.month == month) {
        dayLogMap[log.attendanceDate.day] = log;
      }
    }

    final List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays
              .map((d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        // Grid of days
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (firstDayWeekday - 1) + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            if (index < firstDayWeekday - 1) {
              return const SizedBox.shrink(); // Empty slot before first day of month
            }

            final day = index - (firstDayWeekday - 1) + 1;
            final date = DateTime(year, month, day);
            final log = dayLogMap[day];
            final isSunday = date.weekday == 7;

            Color bgColor = Colors.white;
            Color dotColor = Colors.transparent;
            Color textColor = isSunday ? AppColors.textMuted : AppColors.textPrimary;

            if (log != null) {
              switch (log.status) {
                case AttendanceStatus.present:
                  bgColor = AppColors.presentBg;
                  dotColor = AppColors.present;
                  break;
                case AttendanceStatus.late:
                  bgColor = AppColors.lateBg;
                  dotColor = AppColors.late;
                  break;
                case AttendanceStatus.halfDay:
                  bgColor = AppColors.halfDayBg;
                  dotColor = AppColors.halfDay;
                  break;
                case AttendanceStatus.absent:
                  bgColor = AppColors.absentBg;
                  dotColor = AppColors.absent;
                  break;
              }
            }

            return InkWell(
              onTap: () => onDateSelected?.call(date, log),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: log != null ? dotColor.withOpacity(0.4) : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: log != null ? FontWeight.bold : FontWeight.normal,
                        color: textColor,
                      ),
                    ),
                    if (log != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
