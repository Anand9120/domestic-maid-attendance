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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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

            Color bgColor = isDark ? AppColors.darkSurface : Colors.white;
            Color dotColor = Colors.transparent;
            Color textColor = isSunday
                ? (isDark ? Colors.white38 : AppColors.textMuted)
                : (isDark ? Colors.white : AppColors.textPrimary);

            if (log != null) {
              switch (log.status) {
                case AttendanceStatus.present:
                  bgColor = isDark ? AppColors.darkPresent.withOpacity(0.2) : AppColors.presentBg;
                  dotColor = isDark ? AppColors.darkPresent : AppColors.present;
                  break;
                case AttendanceStatus.late:
                  bgColor = isDark ? Colors.amber.withOpacity(0.2) : AppColors.lateBg;
                  dotColor = isDark ? Colors.amberAccent : AppColors.late;
                  break;
                case AttendanceStatus.halfDay:
                  bgColor = isDark ? AppColors.darkPrimary.withOpacity(0.2) : AppColors.halfDayBg;
                  dotColor = isDark ? AppColors.darkPrimary : AppColors.halfDay;
                  break;
                case AttendanceStatus.absent:
                  bgColor = isDark ? AppColors.darkAbsent.withOpacity(0.2) : AppColors.absentBg;
                  dotColor = isDark ? AppColors.darkAbsent : AppColors.absent;
                  break;
              }
            } else if (isSunday) {
              bgColor = isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF1F5F9);
            }

            final statusText = log != null
                ? log.status.name
                : (isSunday ? "Sunday Off" : "Not recorded");
            return Semantics(
              button: true,
              label: "Day $day, $statusText",
              child: InkWell(
                onTap: () => onDateSelected?.call(date, log),
                borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: log != null
                        ? dotColor.withOpacity(0.6)
                        : (isDark ? AppColors.darkBorder : AppColors.border),
                    width: log != null ? 1.5 : 1,
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
                    ] else if (isSunday) ...[
                      const SizedBox(height: 2),
                      Text(
                        'OFF',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white30 : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
        ),
      ],
    );
  }
}
