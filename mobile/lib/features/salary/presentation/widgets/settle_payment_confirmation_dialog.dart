import 'package:flutter/material.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/salary_calculation_entity.dart';

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
  final _refController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;
    final isContrast = a11y.isHighContrast;
    final netAmount = widget.calculation.netPayableSalary;

    return AlertDialog(
      backgroundColor: isContrast ? AppColors.hcBackground : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isContrast ? Colors.yellow : Colors.transparent),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      title: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: isContrast ? Colors.yellow : const Color(0xFF137333), size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'वेतन निपटान (Confirm Settlement)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isContrast ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm salary settlement for ${widget.calculation.maidName} for ${widget.calculation.month}/${widget.calculation.year}.',
              style: TextStyle(fontSize: 12, color: isContrast ? Colors.white70 : AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // Amount tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isContrast ? AppColors.hcSurface : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Net Settled Amount:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isContrast ? Colors.white70 : const Color(0xFF1B5E20),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${netAmount.toInt()}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isContrast ? Colors.yellow : const Color(0xFF137333),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Payment Mode selector
            Text('Payment Mode / भुगतान माध्यम:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isContrast ? Colors.white70 : AppColors.textPrimary)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _paymentMode,
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              dropdownColor: isContrast ? Colors.grey.shade900 : Colors.white,
              items: const [
                DropdownMenuItem(
                  value: 'UPI',
                  child: Text('UPI (GPay / PhonePe / Paytm)', overflow: TextOverflow.ellipsis),
                ),
                DropdownMenuItem(
                  value: 'CASH',
                  child: Text('Cash (नकद)', overflow: TextOverflow.ellipsis),
                ),
                DropdownMenuItem(
                  value: 'BANK_TRANSFER',
                  child: Text('Bank Transfer (IMPS/NEFT)', overflow: TextOverflow.ellipsis),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _paymentMode = val);
              },
            ),
            const SizedBox(height: 12),

            // Transaction Ref input
            TextField(
              controller: _refController,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'UPI UTR / Ref No (Optional)',
                hintText: 'e.g. 423409182344',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  tooltip: 'Auto-generate',
                  onPressed: () {
                    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
                    _refController.text = 'UTR-$timestamp';
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Notes input
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Notes / टिप्पणी (Optional)',
                hintText: 'e.g. Full month payment settled',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isContrast ? Colors.yellow : const Color(0xFF137333),
            foregroundColor: isContrast ? Colors.black : Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirmed(
              _paymentMode,
              _refController.text.trim().isNotEmpty ? _refController.text.trim() : null,
              _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
            );
          },
          child: const Text('Confirm & Issue Slip (पुष्टि करें)'),
        ),
      ],
    );
  }
}
