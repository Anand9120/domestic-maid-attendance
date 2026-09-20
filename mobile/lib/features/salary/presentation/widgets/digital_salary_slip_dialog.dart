import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/salary_settlement_entity.dart';

class DigitalSalarySlipDialog extends StatelessWidget {
  final SalarySettlementEntity settlement;

  const DigitalSalarySlipDialog({
    super.key,
    required this.settlement,
  });

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Month $month';
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _generateShareableText() {
    final monthName = _getMonthName(settlement.payoutMonth);
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(settlement.settledAt);

    return '''*घरेलू सहायक डिजिटल वेतन पर्ची (Civic Maid Salary Receipt)*
=======================================
🧾 *रसीद सं. (Receipt No):* ${settlement.transactionRef}
📅 *माह (Salary Period):* $monthName ${settlement.payoutYear}
⏱️ *भुगतान समय (Settled At):* $dateStr
🟢 *स्थिति (Status):* ${settlement.status} (${settlement.paymentMode})

👤 *सहायक (Maid):* ${settlement.maidName}
📱 *मोबाइल:* ${settlement.maidPhoneNumber ?? 'N/A'}
🏦 *UPI ID:* ${settlement.maidUpiId ?? 'N/A'}

🏡 *नियोक्ता (Employer):* ${settlement.employerName}
🏢 *घर / पता:* ${settlement.houseName}

---------------------------------------
📊 *उपस्थिति रिकॉर्ड (Attendance Record):*
• कुल कार्य दिवस (Working Days): ${settlement.totalWorkingDays}
• उपस्थित (Present): ${settlement.presentDays}
• देरी से आगमन (Late): ${settlement.lateDays}
• आधा दिन (Half Day): ${settlement.halfDays}
• अनुपस्थित (Absent): ${settlement.absentDays}
• स्वीकृत सवेतन अवकाश (Allowed Leaves): ${settlement.allowedLeaves} दिन
• प्रभावी कटौती दिवस (Deduction Days): ${settlement.deductionDays.toStringAsFixed(1)} दिन

---------------------------------------
💰 *वेतन विवरण (Salary Calculation):*
• मूल मासिक वेतन (Base Salary): ${_formatCurrency(settlement.baseSalary)}
• अनुपस्थिति कटौती (Deduction): -${_formatCurrency(settlement.deductionAmount)}
---------------------------------------
⭐ *शुद्ध देय वेतन (Net Amount Paid):* *${_formatCurrency(settlement.netAmount)}*
=======================================
_प्रमाणित डिजिटल वेतन पर्ची - Domestic Maid Civic Attendance System_''';
  }

  Future<void> _shareOnWhatsApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final text = _generateShareableText();
    final cleanPhone = (settlement.maidPhoneNumber ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final phoneParam = cleanPhone.length >= 10 ? '&phone=91$cleanPhone' : '';
    final waUrl = 'whatsapp://send?text=${Uri.encodeComponent(text)}$phoneParam';
    final uri = Uri.parse(waUrl);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final webPhoneParam = cleanPhone.length >= 10 ? '&phone=91$cleanPhone' : '';
        final webUri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}$webPhoneParam');
        final webLaunched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
        if (!webLaunched) {
          await Clipboard.setData(ClipboardData(text: text));
          messenger.showSnackBar(
            const SnackBar(
              content: Text('WhatsApp not detected. Salary slip copied to clipboard!'),
              backgroundColor: AppColors.present,
            ),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Salary slip copied to clipboard!'),
          backgroundColor: AppColors.present,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;
    final isContrast = a11y.isHighContrast;
    final monthName = _getMonthName(settlement.payoutMonth);
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(settlement.settledAt);

    return Dialog(
      backgroundColor: isContrast ? AppColors.hcBackground : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isContrast ? Colors.yellow : const Color(0xFF137333),
          width: isContrast ? 2 : 1,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge & Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isContrast ? Colors.yellow : const Color(0xFFE6F4EA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: isContrast ? Colors.black : const Color(0xFF137333),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'डिजिटल वेतन पर्ची',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isContrast ? Colors.yellow : const Color(0xFF137333),
                          ),
                        ),
                        Text(
                          'Official Digital Salary Slip (GIGW 3.0)',
                          style: TextStyle(
                            fontSize: 11,
                            color: isContrast ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isContrast ? Colors.yellow : const Color(0xFF137333),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PAID (सफल)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Metadata card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isContrast ? AppColors.hcSurface : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isContrast ? AppColors.hcBorder : const Color(0xFFE8EAED)),
                ),
                child: Column(
                  children: [
                    _buildRow('Receipt Ref / रसीद सं:', settlement.transactionRef, isContrast, isBold: true),
                    const SizedBox(height: 6),
                    _buildRow('Salary Period / अवधि:', '$monthName ${settlement.payoutYear}', isContrast),
                    const SizedBox(height: 6),
                    _buildRow('Settled At / दिनांक:', dateStr, isContrast),
                    const SizedBox(height: 6),
                    _buildRow('Payment Mode / माध्यम:', settlement.paymentMode, isContrast),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Parties details
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isContrast ? AppColors.hcSurface : const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('सहायक (Maid)', style: TextStyle(fontSize: 10, color: isContrast ? Colors.white60 : AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(settlement.maidName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isContrast ? Colors.white : AppColors.textPrimary)),
                          Text(settlement.maidPhoneNumber ?? '', style: TextStyle(fontSize: 10, color: isContrast ? Colors.white70 : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isContrast ? AppColors.hcSurface : const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('नियोक्ता (Employer)', style: TextStyle(fontSize: 10, color: isContrast ? Colors.white60 : AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(settlement.employerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isContrast ? Colors.white : AppColors.textPrimary)),
                          Text(settlement.houseName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: isContrast ? Colors.white70 : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Attendance Scorecard
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isContrast ? AppColors.hcSurface : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isContrast ? AppColors.hcBorder : const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'उपस्थिति सारांश (Attendance Breakdown)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.yellow : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildStatChip('Total Days', '${settlement.totalWorkingDays}', isContrast)),
                        Expanded(child: _buildStatChip('Present', '${settlement.presentDays}', isContrast, color: AppColors.present)),
                        Expanded(child: _buildStatChip('Late', '${settlement.lateDays}', isContrast, color: AppColors.late)),
                        Expanded(child: _buildStatChip('Half-Day', '${settlement.halfDays}', isContrast, color: AppColors.halfDay)),
                        Expanded(child: _buildStatChip('Absent', '${settlement.absentDays}', isContrast, color: AppColors.absent)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isContrast ? Colors.white10 : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: isContrast ? Colors.yellow : AppColors.present),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'सवेतन अवकाश (Allowed Leaves): ${settlement.allowedLeaves} दिन स्वीकृत (No deduction)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isContrast ? Colors.white : const Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Financial Calculation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isContrast ? Colors.black : const Color(0xFFF9FBE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isContrast ? Colors.yellow : const Color(0xFFC0CA33)),
                ),
                child: Column(
                  children: [
                    _buildRow('मूल मासिक वेतन (Base Salary):', _formatCurrency(settlement.baseSalary), isContrast),
                    const SizedBox(height: 6),
                    _buildRow(
                      'कटौती (${settlement.deductionDays.toStringAsFixed(1)} दिन अनुपस्थिति):',
                      '-${_formatCurrency(settlement.deductionAmount)}',
                      isContrast,
                      valueColor: Colors.deepOrange,
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'कुल भुगतान (Net Amount):',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isContrast ? Colors.white : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatCurrency(settlement.netAmount),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isContrast ? Colors.yellow : const Color(0xFF137333),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isContrast ? Colors.yellow : const Color(0xFF25D366),
                        foregroundColor: isContrast ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('WhatsApp पर भेजें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () => _shareOnWhatsApp(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: 'रसीद कॉपी करें (Copy)',
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await Clipboard.setData(ClipboardData(text: _generateShareableText()));
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Digital salary slip copied to clipboard!'),
                          backgroundColor: AppColors.present,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isContrast, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isContrast ? (isBold ? Colors.yellow : Colors.white) : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String val, bool isContrast, {Color? color}) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isContrast ? Colors.yellow : (color ?? AppColors.textPrimary),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isContrast ? Colors.white60 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
