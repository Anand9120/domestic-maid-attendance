import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/attendance_log_entity.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';

class ManualOverrideDialog extends StatefulWidget {
  final int employerId;
  final int householdId;
  final int defaultMaidId;
  final String defaultMaidName;

  const ManualOverrideDialog({
    super.key,
    required this.employerId,
    required this.householdId,
    this.defaultMaidId = 2,
    this.defaultMaidName = 'Sunita Devi',
  });

  @override
  State<ManualOverrideDialog> createState() => _ManualOverrideDialogState();
}

class _ManualOverrideDialogState extends State<ManualOverrideDialog> {
  AttendanceStatus _selectedStatus = AttendanceStatus.present;
  String _notes = '';
  String _time = '08:00';
  final DateTime _selectedDate = DateTime.now();

  void _submitOverride() {
    context.read<AttendanceBloc>().add(
          ManualOverrideSubmitted(
            maidId: widget.defaultMaidId,
            householdId: widget.householdId,
            attendanceDate: _selectedDate,
            checkInTime: _time.trim(),
            status: _selectedStatus,
            employerId: widget.employerId,
            notes: _notes.trim(),
          ),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;

    return ListenableBuilder(
      listenable: a11y,
      builder: (context, _) {
        final isContrast = a11y.isHighContrast;

        return Dialog(
          backgroundColor: isContrast ? AppColors.hcSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isContrast ? AppColors.hcBorder : AppColors.border,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isContrast
                              ? AppColors.darkPrimary.withOpacity(0.15)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit_calendar_rounded,
                          color: isContrast ? AppColors.darkPrimary : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a11y.tr('manual_override'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isContrast ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              widget.defaultMaidName,
                              style: TextStyle(
                                fontSize: 12,
                                color: isContrast ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Status Selector
                  Text(
                    'Attendance Status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isContrast ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: AttendanceStatus.values.map((status) {
                      final isSelected = _selectedStatus == status;
                      return ChoiceChip(
                        label: Text(status.name.toUpperCase()),
                        selected: isSelected,
                        selectedColor: isContrast ? AppColors.darkPrimary.withOpacity(0.2) : AppColors.primaryLight.withOpacity(0.2),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (isContrast ? Colors.black : AppColors.primary)
                              : (isContrast ? Colors.white : AppColors.textPrimary),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedStatus = status);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Time Input using Ux4gInputField
                  Ux4gInputField(
                    value: _time,
                    onValueChange: (val) => setState(() => _time = val),
                    label: a11y.tr('checkin_time'),
                    required: true,
                    placeholder: '08:00',
                    leadingIcon: Icons.access_time_rounded,
                    size: Ux4gInputFieldSize.large,
                  ),
                  const SizedBox(height: 16),

                  // Reason / Notes Input using Ux4gInputField
                  Ux4gInputField(
                    value: _notes,
                    onValueChange: (val) => setState(() => _notes = val),
                    label: a11y.tr('reason_notes'),
                    placeholder: 'e.g. Phone forgotten at home',
                    leadingIcon: Icons.note_alt_outlined,
                    size: Ux4gInputFieldSize.large,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons (Ux4gButton)
                  Row(
                    children: [
                      Expanded(
                        child: Ux4gButton(
                          text: a11y.tr('cancel'),
                          variant: Ux4gButtonVariant.outline,
                          size: Ux4gButtonSize.large,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Ux4gButton(
                          text: a11y.tr('confirm'),
                          variant: Ux4gButtonVariant.primary,
                          size: Ux4gButtonSize.large,
                          onPressed: _submitOverride,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
