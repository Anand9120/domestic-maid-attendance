import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../domain/entities/attendance_log_entity.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';

/// UX4G & GIGW 3.0 Compliant Bulk Attendance Review & Backfill Dialog
///
/// Designed for employers when the domestic worker's GPS remained off
/// for days or the entire month, eliminating the need to:
/// 1. Ask for her phone daily (preserving maid's privacy & dignity).
/// 2. Manually mark 26 individual days one by one.
class BulkBackfillDialog extends StatefulWidget {
  final int employerId;
  final int householdId;
  final int maidId;
  final String maidName;
  final int year;
  final int month;
  final List<AttendanceLogEntity> existingLogs;
  final VoidCallback onCompleted;

  const BulkBackfillDialog({
    super.key,
    required this.employerId,
    required this.householdId,
    required this.maidId,
    required this.maidName,
    required this.year,
    required this.month,
    required this.existingLogs,
    required this.onCompleted,
  });

  @override
  State<BulkBackfillDialog> createState() => _BulkBackfillDialogState();
}

class _BulkBackfillDialogState extends State<BulkBackfillDialog> {
  bool _markAllAsPresent = true;
  final Set<int> _selectedLeaveDays = {};
  bool _isProcessing = false;

  List<int> _computeUnrecordedWorkingDays() {
    final daysInMonth = DateUtils.getDaysInMonth(widget.year, widget.month);
    final loggedDays = widget.existingLogs
        .where((log) => log.attendanceDate.year == widget.year && log.attendanceDate.month == widget.month)
        .map((log) => log.attendanceDate.day)
        .toSet();

    final List<int> unrecorded = [];
    for (int day = 1; day <= daysInMonth; day++) {
      // Includes all days (Sundays included since morning shifts are active)
      if (!loggedDays.contains(day)) {
        unrecorded.add(day);
      }
    }
    return unrecorded;
  }

  Future<void> _submitBulkBackfill() async {
    setState(() => _isProcessing = true);
    final unrecorded = _computeUnrecordedWorkingDays();

    final bloc = context.read<AttendanceBloc>();
    for (final day in unrecorded) {
      final date = DateTime(widget.year, widget.month, day);
      final isLeave = _selectedLeaveDays.contains(day);

      bloc.add(
        ManualOverrideSubmitted(
          maidId: widget.maidId,
          householdId: widget.householdId,
          attendanceDate: date,
          checkInTime: isLeave ? null : '08:00',
          status: isLeave ? AttendanceStatus.absent : AttendanceStatus.present,
          employerId: widget.employerId,
          notes: isLeave
              ? 'मंजूर अवकाश / Leave (Bulk Review)'
              : 'मासिक थोक सत्यापन / Bulk Confirmation (GPS-Off Safe Mode)',
        ),
      );
    }

    // Give a short delay for state updates
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _isProcessing = false);
      widget.onCompleted();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;

    return ListenableBuilder(
      listenable: a11y,
      builder: (context, _) {
        final isContrast = a11y.isHighContrast;
        final isHindi = a11y.isHindi;
        final unrecordedDays = _computeUnrecordedWorkingDays();

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
                          Icons.playlist_add_check_circle_rounded,
                          color: isContrast ? AppColors.darkPrimary : AppColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi
                                  ? 'मासिक थोक हाजिरी सत्यापन'
                                  : 'Monthly Bulk Attendance Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isContrast ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${widget.maidName} • ${widget.month}/${widget.year}',
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
                  const SizedBox(height: 14),

                  // Problem Explanation Banner (GPS off context)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isContrast
                          ? Colors.amber.withOpacity(0.12)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isContrast ? Colors.amberAccent : const Color(0xFFF59E0B),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: isContrast ? Colors.amberAccent : const Color(0xFFB45309),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isHindi
                              ? 'अगर सहायिका का GPS पूरे महीने बंद रहा, तो आपको रोज़ उनका मोबाइल मांगने या 26 बार हाजिरी लगाने की ज़रूरत नहीं है। यहाँ से 1-क्लिक में पूरे महीने का हिसाब पूरा करें।'
                              : 'If maid kept GPS off all month, you don\'t need to ask for her phone daily or fill 26 logs one-by-one. Verify the entire month in 1-tap here.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isContrast ? Colors.white : const Color(0xFF78350F),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Unrecorded stats badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isHindi ? 'छूटे हुए कार्यदिवस (Unrecorded):' : 'Unrecorded Working Days:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isContrast ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: unrecordedDays.isEmpty
                              ? (isContrast ? AppColors.darkPresent.withOpacity(0.2) : Colors.green.shade50)
                              : (isContrast ? Colors.blue.withOpacity(0.2) : Colors.blue.shade50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${unrecordedDays.length} ${isHindi ? "दिन" : "days"}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: unrecordedDays.isEmpty
                                ? (isContrast ? AppColors.darkPresent : Colors.green.shade800)
                                : (isContrast ? Colors.lightBlueAccent : Colors.blue.shade800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (unrecordedDays.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        isHindi
                            ? '🎉 इस महीने के सभी कार्यदिवस पहले से ही दर्ज हैं!'
                            : '🎉 All working days this month are already recorded!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isContrast ? AppColors.darkPresent : AppColors.present,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Option 1: Mark all as present
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _markAllAsPresent,
                      activeColor: isContrast ? AppColors.darkPrimary : AppColors.primary,
                      title: Text(
                        isHindi
                            ? 'सभी छूटे दिन "उपस्थित" मार्क करें'
                            : 'Mark all unrecorded days as "PRESENT"',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isContrast ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        isHindi
                            ? 'मेड नियमित रूप से काम पर आईं (सामान्य कार्यदिवस)'
                            : 'Maid worked regularly on all normal scheduled days',
                        style: TextStyle(
                          fontSize: 11,
                          color: isContrast ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _markAllAsPresent = val;
                          if (val) _selectedLeaveDays.clear();
                        });
                      },
                    ),

                    const Divider(height: 20),

                    // Option 2: Leave selector
                    Text(
                      isHindi
                          ? 'क्या इस महीने कोई छुट्टी ली थी? (Select Leaves)'
                          : 'Did she take any leave this month? (Optional)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isHindi
                          ? 'जिस तारीख को दीदी नहीं आई थीं, उस पर टैप करें:'
                          : 'Tap dates when she did not come to work:',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick Date Chips for leave selection
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: unrecordedDays.map((day) {
                        final isLeave = _selectedLeaveDays.contains(day);
                        return ChoiceChip(
                          label: Text('$day ${isHindi ? "तारीख" : ""}'),
                          selected: isLeave,
                          selectedColor: isContrast
                              ? Colors.red.withOpacity(0.3)
                              : Colors.red.shade100,
                          side: BorderSide(
                            color: isLeave
                                ? (isContrast ? Colors.redAccent : Colors.red)
                                : (isContrast ? Colors.white24 : AppColors.border),
                          ),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isLeave ? FontWeight.bold : FontWeight.normal,
                            color: isLeave
                                ? (isContrast ? Colors.redAccent : Colors.red.shade900)
                                : (isContrast ? Colors.white70 : AppColors.textPrimary),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedLeaveDays.add(day);
                              } else {
                                _selectedLeaveDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    if (_selectedLeaveDays.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          isHindi
                              ? '📌 ${_selectedLeaveDays.length} दिन अनुपस्थित (Leave) दर्ज होंगे, बाकी सभी उपस्थित।'
                              : '📌 ${_selectedLeaveDays.length} days will be marked ABSENT, rest all PRESENT.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isContrast ? Colors.amberAccent : Colors.amber.shade900,
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 22),

                  // Actions
                  if (_isProcessing)
                    const Center(child: Ux4gSpinner.medium())
                  else
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
                        if (unrecordedDays.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Ux4gButton(
                              text: isHindi ? 'एक साथ पुष्टि करें' : 'Confirm Month',
                              variant: Ux4gButtonVariant.primary,
                              size: Ux4gButtonSize.large,
                              onPressed: _submitBulkBackfill,
                            ),
                          ),
                        ],
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
