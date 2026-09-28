import 'package:flutter/material.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../domain/entities/salary_calculation_entity.dart';

/// UX4G & GIGW 3.0 Compliant Salary Settlement Dialog
class SettlePaymentConfirmationDialog extends StatefulWidget {
  final SalaryCalculationEntity calculation;
  final Function(String paymentMode, String? transactionRef, String? notes) onConfirmed;

  const SettlePaymentConfirmationDialog({
    super.key,
    required this.calculation,
    required this.onConfirmed,
  });

  @override
  State<SettlePaymentConfirmationDialog> createState() => _SettlePaymentConfirmationDialogState();
}

class _SettlePaymentConfirmationDialogState extends State<SettlePaymentConfirmationDialog> {
  String _paymentMode = 'UPI';
  String _transactionRef = '';
  String _notes = '';

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;

    return ListenableBuilder(
      listenable: a11y,
      builder: (context, _) {
        final isContrast = a11y.isHighContrast;
        final isHindi = a11y.isHindi;
        final netAmount = widget.calculation.netPayableSalary;

        return Dialog(
          backgroundColor: isContrast ? AppColors.hcSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isContrast ? AppColors.hcBorder : AppColors.border,
              width: 1.5,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
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
                              ? AppColors.darkPresent.withOpacity(0.2)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.payments_rounded,
                          color: isContrast ? AppColors.darkPresent : const Color(0xFF137333),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi ? 'वेतन निपटान एवं पर्ची' : 'Confirm Salary Settlement',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isContrast ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${widget.calculation.maidName} • ${widget.calculation.month}/${widget.calculation.year}',
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
                  const SizedBox(height: 16),

                  // Net Payable Amount Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isContrast ? Colors.black45 : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isContrast ? AppColors.darkPresent : const Color(0xFF86EFAC),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHindi ? 'कुल शुद्ध देय राशि' : 'Net Payable Amount',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isContrast ? Colors.white70 : const Color(0xFF166534),
                              ),
                            ),
                            Text(
                              '${widget.calculation.presentDays} ${isHindi ? "उपस्थित दिन" : "Days Present"} (${widget.calculation.effectiveDeductionDays.toStringAsFixed(0)} ${isHindi ? "कटौती" : "LOP"})',
                              style: TextStyle(
                                fontSize: 11,
                                color: isContrast ? Colors.white60 : const Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${netAmount.toInt()}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isContrast ? AppColors.darkPresent : const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Payment Mode Selector
                  Text(
                    isHindi ? 'भुगतान माध्यम चुनें' : 'Payment Mode',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isContrast ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPaymentModeOption('UPI', 'UPI', Icons.qr_code_scanner_rounded, isContrast),
                      const SizedBox(width: 8),
                      _buildPaymentModeOption('CASH', isHindi ? 'नकद' : 'Cash', Icons.money_rounded, isContrast),
                      const SizedBox(width: 8),
                      _buildPaymentModeOption('BANK_TRANSFER', isHindi ? 'बैंक' : 'Bank', Icons.account_balance_rounded, isContrast),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Transaction UTR / Ref Number Input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Ux4gInputField(
                          value: _transactionRef,
                          onValueChange: (val) => setState(() => _transactionRef = val),
                          label: isHindi ? 'UPI UTR / संदर्भ संख्या (वैकल्पिक)' : 'Transaction UTR / Ref No (Optional)',
                          placeholder: 'e.g. 423409182344',
                          leadingIcon: Icons.receipt_long_outlined,
                          size: Ux4gInputFieldSize.large,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: IconButton.outlined(
                          tooltip: isHindi ? 'स्वतः UTR कोड उत्पन्न करें' : 'Generate UTR reference',
                          icon: const Icon(Icons.auto_awesome, size: 20),
                          onPressed: () {
                            final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(6);
                            setState(() => _transactionRef = 'UTR-$timestamp');
                          },
                          style: IconButton.styleFrom(
                            side: BorderSide(color: isContrast ? Colors.white38 : AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Notes Input
                  Ux4gInputField(
                    value: _notes,
                    onValueChange: (val) => setState(() => _notes = val),
                    label: isHindi ? 'टिप्पणी / विवरण (वैकल्पिक)' : 'Notes / Remarks (Optional)',
                    placeholder: isHindi ? 'उदा. पूर्ण माह का वेतन चुकता' : 'e.g. Full month settlement completed',
                    leadingIcon: Icons.edit_note_rounded,
                    size: Ux4gInputFieldSize.large,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
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
                          text: isHindi ? 'पुष्टि करें व पर्ची दें' : 'Confirm & Issue',
                          variant: Ux4gButtonVariant.primary,
                          size: Ux4gButtonSize.large,
                          leadingIcon: Icons.check_circle_outline,
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onConfirmed(
                              _paymentMode,
                              _transactionRef.trim().isNotEmpty ? _transactionRef.trim() : null,
                              _notes.trim().isNotEmpty ? _notes.trim() : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentModeOption(String mode, String label, IconData icon, bool isContrast) {
    final isSelected = _paymentMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _paymentMode = mode),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isContrast ? AppColors.darkPrimary.withOpacity(0.25) : AppColors.primary.withOpacity(0.08))
                : (isContrast ? Colors.white10 : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? (isContrast ? AppColors.darkPrimary : AppColors.primary)
                  : (isContrast ? Colors.white24 : AppColors.border),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? (isContrast ? AppColors.darkPrimary : AppColors.primary)
                    : (isContrast ? Colors.white70 : AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isContrast ? Colors.white : AppColors.primary)
                      : (isContrast ? Colors.white70 : AppColors.textPrimary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
