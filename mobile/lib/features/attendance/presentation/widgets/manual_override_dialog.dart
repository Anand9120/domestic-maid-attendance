import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../domain/entities/attendance_log_entity.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';

/// UX4G & GIGW 3.0 Compliant Manual Attendance Override Dialog
///
/// Designed for domestic employers to manually log presence when
/// the worker has a keypad feature phone, battery discharged, or GPS failure.
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
  String? _timeError;
  final DateTime _selectedDate = DateTime.now();

  static const List<({String labelEn, String labelHi})> _presetReasons = [
    (labelEn: 'Keypad / Feature Phone (No GPS)', labelHi: 'कीपैड फोन (GPS अनुपलब्ध)'),
    (labelEn: 'Phone Battery Discharged', labelHi: 'फोन की बैटरी समाप्त'),
    (labelEn: 'Device Left at Home', labelHi: 'फोन घर पर छूट गया'),
    (labelEn: 'Cellular Network Glitch', labelHi: 'नेटवर्क / GPS सिग्नल समस्या'),
    (labelEn: 'Direct Verbal Confirmation', labelHi: 'नियोक्ता द्वारा प्रत्यक्ष पुष्टि'),
  ];

  Future<void> _selectTime(BuildContext context) async {
    final parts = _time.split(':');
    final initialHour = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 8) : 8;
    final initialMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _time = '$h:$m';
        _timeError = null;
      });
    }
  }

  void _submitOverride(bool isHindi) {
    final err = FormValidators.validateTime24h(_time, isHindi: isHindi);
    if (err != null) {
      setState(() => _timeError = err);
      return;
    }

    context.read<AttendanceBloc>().add(
          ManualOverrideSubmitted(
            maidId: widget.defaultMaidId,
            householdId: widget.householdId,
            attendanceDate: _selectedDate,
            checkInTime: _time.trim(),
            status: _selectedStatus,
            employerId: widget.employerId,
            notes: _notes.trim().isNotEmpty ? _notes.trim() : 'Manual Employer Override',
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
        final isHindi = a11y.isHindi;

        return Dialog(
          backgroundColor: isContrast ? AppColors.hcSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isContrast ? AppColors.hcBorder : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isContrast
                              ? AppColors.darkPrimary.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.edit_calendar_rounded,
                          color: isContrast ? AppColors.darkPrimary : AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi ? 'मैन्युअल उपस्थिति सुधार' : 'Manual Attendance Override',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isContrast ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${widget.defaultMaidName} (${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year})',
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

                  // Status Selector Label
                  Text(
                    isHindi ? 'उपस्थिति स्थिति चुनें' : 'Select Attendance Status',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isContrast ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AttendanceStatus.values.map((status) {
                      final isSelected = _selectedStatus == status;
                      String statusLabel;
                      switch (status) {
                        case AttendanceStatus.present:
                          statusLabel = isHindi ? 'उपस्थित (Present)' : 'PRESENT';
                          break;
                        case AttendanceStatus.late:
                          statusLabel = isHindi ? 'विलंब (Late)' : 'LATE';
                          break;
                        case AttendanceStatus.halfDay:
                          statusLabel = isHindi ? 'आधा दिन (Half-Day)' : 'HALF DAY';
                          break;
                        case AttendanceStatus.absent:
                          statusLabel = isHindi ? 'अनुपस्थित (Absent)' : 'ABSENT';
                          break;
                      }

                      return ChoiceChip(
                        label: Text(statusLabel),
                        selected: isSelected,
                        selectedColor: isContrast
                            ? AppColors.darkPrimary.withOpacity(0.3)
                            : AppColors.primaryLight.withOpacity(0.2),
                        side: BorderSide(
                          color: isSelected
                              ? (isContrast ? AppColors.darkPrimary : AppColors.primary)
                              : (isContrast ? Colors.white24 : AppColors.border),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? (isContrast ? Colors.white : AppColors.primary)
                              : (isContrast ? Colors.white70 : AppColors.textPrimary),
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

                  // Time Input with Picker Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Ux4gInputField(
                          value: _time,
                          onValueChange: (val) {
                            setState(() {
                              _time = val;
                              if (_timeError != null) {
                                _timeError = FormValidators.validateTime24h(val, isHindi: isHindi);
                              }
                            });
                          },
                          label: isHindi ? 'चेक-इन समय (HH:mm)' : 'Check-In Time (HH:mm)',
                          required: true,
                          placeholder: '08:00',
                          caption: _timeError,
                          status: _timeError != null
                              ? Ux4gInputFieldStatus.error
                              : Ux4gInputFieldStatus.defaultStatus,
                          leadingIcon: Icons.access_time_rounded,
                          size: Ux4gInputFieldSize.large,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: IconButton.outlined(
                          tooltip: isHindi ? 'घड़ी से समय चुनें' : 'Pick time from clock',
                          icon: const Icon(Icons.schedule_rounded),
                          onPressed: () => _selectTime(context),
                          style: IconButton.styleFrom(
                            side: BorderSide(color: isContrast ? Colors.white38 : AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Preset Reason Quick-Chips
                  Text(
                    isHindi ? 'त्वरित कारण चुनें (Quick Reasons)' : 'Quick Preset Reasons',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isContrast ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _presetReasons.map((reason) {
                      final title = isHindi ? reason.labelHi : reason.labelEn;
                      final isCurrentNote = _notes == title;
                      return ActionChip(
                        avatar: Icon(
                          Icons.touch_app_outlined,
                          size: 14,
                          color: isCurrentNote
                              ? (isContrast ? AppColors.darkPrimary : AppColors.primary)
                              : (isContrast ? Colors.white60 : AppColors.textSecondary),
                        ),
                        label: Text(
                          title,
                          style: TextStyle(
                            fontSize: 11,
                            color: isCurrentNote
                                ? (isContrast ? Colors.white : AppColors.primary)
                                : (isContrast ? Colors.white70 : AppColors.textPrimary),
                            fontWeight: isCurrentNote ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        backgroundColor: isCurrentNote
                            ? (isContrast ? AppColors.darkPrimary.withOpacity(0.2) : AppColors.primaryLight.withOpacity(0.2))
                            : (isContrast ? Colors.white12 : const Color(0xFFF1F5F9)),
                        onPressed: () {
                          setState(() => _notes = title);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Reason / Notes Input using Ux4gInputField
                  Ux4gInputField(
                    value: _notes,
                    onValueChange: (val) => setState(() => _notes = val),
                    label: isHindi ? 'टिप्पणी / विवरण (वैकल्पिक)' : 'Override Reason / Note (Optional)',
                    placeholder: isHindi ? 'उदा. फोन घर पर छूट गया था' : 'e.g. Phone battery died or keypad user',
                    leadingIcon: Icons.note_alt_outlined,
                    size: Ux4gInputFieldSize.large,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons (Ux4gButton)
                  Row(
                    children: [
                      Expanded(
                        child: Ux4gButton(
                          text: isHindi ? 'रद्द करें' : 'Cancel',
                          variant: Ux4gButtonVariant.outline,
                          size: Ux4gButtonSize.large,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Ux4gButton(
                          text: isHindi ? 'हाजिरी दर्ज करें' : 'Confirm Override',
                          variant: Ux4gButtonVariant.primary,
                          size: Ux4gButtonSize.large,
                          onPressed: () => _submitOverride(isHindi),
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
