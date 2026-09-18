import 'package:flutter/material.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
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
    final a11y = AccessibilityController.instance;
    String label;
    IconData icon;
    Ux4gTagColor colorScheme;

    switch (status) {
      case AttendanceStatus.present:
        label = a11y.tr('status_present');
        icon = Icons.check_circle_rounded;
        colorScheme = Ux4gTagColor.success;
        break;
      case AttendanceStatus.late:
        label = a11y.tr('status_late');
        icon = Icons.access_time_rounded;
        colorScheme = Ux4gTagColor.warning;
        break;
      case AttendanceStatus.halfDay:
        label = a11y.tr('status_half_day');
        icon = Icons.hourglass_bottom_rounded;
        colorScheme = Ux4gTagColor.brand;
        break;
      case AttendanceStatus.absent:
        label = a11y.tr('status_absent');
        icon = Icons.cancel_rounded;
        colorScheme = Ux4gTagColor.error;
        break;
    }

    return Semantics(
      label: 'Attendance Status: $label',
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Ux4gTag(
            text: label,
            leadingContent: Icon(icon, size: 14),
            colorScheme: colorScheme,
            size: Ux4gTagSize.m,
            shape: Ux4gTagShape.circular,
            style: Ux4gTagStyle.tonal,
          ),
          if (entryType == EntryType.offlineSync)
            Semantics(
              label: 'Entry logged via offline synchronization',
              child: Ux4gTag(
                text: a11y.tr('status_offline'),
                leadingContent: const Icon(Icons.cloud_off_rounded, size: 13),
                colorScheme: Ux4gTagColor.info,
                size: Ux4gTagSize.m,
                shape: Ux4gTagShape.circular,
                style: Ux4gTagStyle.tonal,
              ),
            ),
          if (isMock)
            Semantics(
              label: 'Warning: Mock GPS location detected',
              child: Ux4gTag(
                text: a11y.tr('status_mock_gps'),
                leadingContent: const Icon(Icons.warning_amber_rounded, size: 13),
                colorScheme: Ux4gTagColor.error,
                size: Ux4gTagSize.m,
                shape: Ux4gTagShape.circular,
                style: Ux4gTagStyle.filled,
              ),
            ),
        ],
      ),
    );
  }
}
