import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/upi_payment_launcher.dart';
import '../../../../core/widgets/ux4g_civic_bar.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../salary/domain/entities/salary_calculation_entity.dart';
import '../../../salary/domain/entities/salary_settlement_entity.dart';
import '../../../salary/presentation/bloc/salary_bloc.dart';
import '../../../salary/presentation/bloc/salary_event.dart';
import '../../../salary/presentation/bloc/salary_state.dart';
import '../../../salary/presentation/widgets/digital_salary_slip_dialog.dart';
import '../../../salary/presentation/widgets/settle_payment_confirmation_dialog.dart';
import '../../domain/entities/monthly_report_entity.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/calendar_view.dart';
import '../widgets/status_badge.dart';

class MonthlyLedgerPage extends StatefulWidget {
  final int maidId;
  final String maidName;

  const MonthlyLedgerPage({
    super.key,
    required this.maidId,
    required this.maidName,
  });

  @override
  State<MonthlyLedgerPage> createState() => _MonthlyLedgerPageState();
}

class _MonthlyLedgerPageState extends State<MonthlyLedgerPage> {
  final int _year = DateTime.now().year;
  final int _month = DateTime.now().month;

  // Salary & Payout Configuration
  double _baseSalary = 5000.0;
  String _upiId = '';
  String _maidPhone = '';
  SalaryCalculationEntity? _latestCalculation;
  SalarySettlementEntity? _latestSettlement;

  @override
  void initState() {
    super.initState();
    _loadReport();
    _fetchMaidProfile();
    _loadSalaryCalculation();
  }

  void _loadSalaryCalculation() {
    sl.salaryBloc.add(
      CalculateSalaryEvent(
        maidId: widget.maidId,
        householdId: 1,
        year: _year,
        month: _month,
      ),
    );
  }

  void _loadReport() {
    context.read<AttendanceBloc>().add(
          FetchMonthlyReportEvent(
            maidId: widget.maidId,
            year: _year,
            month: _month,
          ),
        );
  }

  Future<void> _fetchMaidProfile() async {
    try {
      final user = await sl.getUserProfileUseCase.execute(widget.maidId);
      if (mounted) {
        setState(() {
          if (user.upiId != null && user.upiId!.isNotEmpty) {
            _upiId = user.upiId!;
          }
          if (user.phoneNumber.isNotEmpty) {
            _maidPhone = user.phoneNumber;
          }
        });
      }
    } catch (_) {
      // Retain defaults
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Month $month';
  }

  String _computeDuration(String? inTime, String? outTime) {
    if (inTime == null || outTime == null) return '';
    try {
      final inParts = inTime.split(':').map(int.parse).toList();
      final outParts = outTime.split(':').map(int.parse).toList();
      int diffMinutes = (outParts[0] * 60 + outParts[1]) - (inParts[0] * 60 + inParts[1]);
      if (diffMinutes < 0) diffMinutes += 24 * 60;
      final hrs = diffMinutes ~/ 60;
      final mins = diffMinutes % 60;
      return hrs > 0 ? '${hrs}h ${mins}m' : '${mins}m';
    } catch (_) {
      return '';
    }
  }

  void _showEditSalaryDialog() {
    final controller = TextEditingController(text: _baseSalary.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Agreed Monthly Salary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the agreed base monthly salary for this household.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                labelText: 'Monthly Salary (रुपये)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                setState(() => _baseSalary = val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _payViaUpi(double amount) async {
    if (_upiId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maid UPI ID is not configured. Please add in Profile.'),
          backgroundColor: AppColors.absent,
        ),
      );
      return;
    }

    final upiUrl = UpiPaymentLauncher.buildUpiUri(
      upiId: _upiId,
      payeeName: widget.maidName,
      amount: amount,
      note: 'Salary for ${_getMonthName(_month)} $_year',
    );

    try {
      final launched = await UpiPaymentLauncher.launchUpiIntent(upiUrl);
      if (mounted) {
        if (!launched) {
          _showUpiFallbackModal(amount, upiUrl);
        } else {
          // Trigger settlement prompt once employer returns from UPI app
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('UPI App launched. Confirm settlement once paid.'),
              action: SnackBarAction(
                label: 'Settle & Receipt',
                onPressed: () {
                  if (_latestCalculation != null) {
                    _showSettleDialog(_latestCalculation!);
                  }
                },
              ),
              duration: const Duration(seconds: 10),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) _showUpiFallbackModal(amount, upiUrl);
    }
  }

  void _showSettleDialog(SalaryCalculationEntity calc) {
    showDialog(
      context: context,
      builder: (ctx) => SettlePaymentConfirmationDialog(
        calculation: calc,
        onConfirmed: (mode, ref, notes) {
          sl.salaryBloc.add(
            SettleSalaryEvent(
              maidId: widget.maidId,
              householdId: 1,
              year: _year,
              month: _month,
              paymentMode: mode,
              transactionRef: ref,
              notes: notes,
            ),
          );
        },
      ),
    );
  }

  Future<void> _viewSalaryReceipt(int settlementId) async {
    try {
      final receipt = await sl.getSalarySettlementsUseCase.executeForReceipt(settlementId);
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => DigitalSalarySlipDialog(settlement: receipt),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load slip: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showUpiFallbackModal(double amount, String upiUrl) {
    final a11y = AccessibilityController.instance;
    final isContrast = a11y.isHighContrast;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isContrast ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isContrast ? AppColors.darkBorder : Colors.transparent),
        ),
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF137333), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'UPI Salary Payout (₹${amount.toInt()})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isContrast ? Colors.white : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Scan with Google Pay, PhonePe, Paytm or BHIM UPI to transfer directly to ${widget.maidName}.',
                style: TextStyle(
                  fontSize: 12,
                  color: isContrast ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: QrImageView(
                  data: upiUrl,
                  version: QrVersions.auto,
                  size: 160.0,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isContrast ? Colors.grey.shade900 : const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UPI ID:', style: TextStyle(fontSize: 10, color: isContrast ? Colors.white60 : AppColors.textSecondary)),
                          Text(_upiId.isNotEmpty ? _upiId : 'Not Configured', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isContrast ? AppColors.darkPrimary : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: 'Copy UPI ID',
                      onPressed: _upiId.isEmpty ? null : () {
                        Clipboard.setData(ClipboardData(text: _upiId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied UPI ID: $_upiId'),
                            backgroundColor: AppColors.present,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isContrast ? AppColors.darkPresent : const Color(0xFF137333),
              foregroundColor: isContrast ? const Color(0xFF0F172A) : Colors.white,
            ),
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Record Settlement (निपटान दर्ज करें)'),
            onPressed: () {
              Navigator.pop(ctx);
              if (_latestCalculation != null) {
                _showSettleDialog(_latestCalculation!);
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _generateSalarySlipText(MonthlyReportEntity report, double netPayable, double deductionAmount) {
    return '''*घरेलू सहायक वेतन पर्ची (Maid Attendance & Salary Slip)*
---------------------------------------
👤 *सहायक (Maid):* ${widget.maidName}
📅 *माह (Month):* ${_getMonthName(_month)} $_year
🏢 *घर (Household):* Sharma Residence - Flat 402

📊 *उपस्थिति सारांश (Attendance Summary):*
• कुल कार्य दिवस (Total Days): ${report.totalWorkingDays}
• उपस्थित (Present): ${report.presentDays}
• देरी (Late): ${report.lateDays}
• आधा दिन (Half-Day): ${report.halfDays}
• अनुपस्थित (Absent): ${report.absentDays}
• कुल कटौती (Deductions): ${report.calculatedDeductions.toStringAsFixed(1)} दिन

💰 *वेतन विवरण (Salary Breakdown):*
• मूल मासिक वेतन (Base Salary): ₹${_baseSalary.toInt()}
• कटौती राशि (Deductions): -₹${deductionAmount.toInt()}
• *देय शुद्ध वेतन (Net Payable):* *₹${netPayable.toInt()}*

🏦 *भुगतान UPI ID:* $_upiId
---------------------------------------
_Generated via Digital Civic Maid Attendance System_''';
  }

  Future<void> _shareSalarySlipOnWhatsApp(MonthlyReportEntity report, double netPayable, double deductionAmount) async {
    final slipText = _generateSalarySlipText(report, netPayable, deductionAmount);
    final cleanPhone = _maidPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneParam = cleanPhone.length >= 10 ? '&phone=91$cleanPhone' : '';
    final waUrl = 'whatsapp://send?text=${Uri.encodeComponent(slipText)}$phoneParam';
    final uri = Uri.parse(waUrl);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final webPhoneParam = cleanPhone.length >= 10 ? '&phone=91$cleanPhone' : '';
        final webUri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(slipText)}$webPhoneParam');
        final webLaunched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
        if (!webLaunched) {
          await Clipboard.setData(ClipboardData(text: slipText));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📋 WhatsApp app not found. Salary slip copied to clipboard!'),
                backgroundColor: AppColors.present,
              ),
            );
          }
        }
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: slipText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📋 Salary slip copied to clipboard!'),
            backgroundColor: AppColors.present,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;

    return ListenableBuilder(
      listenable: a11y,
      builder: (context, _) {
        final isContrast = a11y.isHighContrast;

        return Scaffold(
          backgroundColor: isContrast ? AppColors.hcBackground : AppColors.background,
          appBar: AppBar(
            backgroundColor: isContrast ? AppColors.darkSurface : AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
              '${widget.maidName} - ${a11y.tr('view_ledger')}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Ledger',
                onPressed: () {
                  _loadReport();
                  _fetchMaidProfile();
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const Ux4gCivicBar(showTitle: false),
                Expanded(
                  child: BlocConsumer<SalaryBloc, SalaryState>(
                    bloc: sl.salaryBloc,
                    listener: (context, salaryState) {
                      if (!mounted) return;
                      if (salaryState is SalaryCalculatedState) {
                        setState(() {
                          _latestCalculation = salaryState.calculation;
                          _baseSalary = salaryState.calculation.monthlyBaseSalary;
                        });
                      } else if (salaryState is SalarySettledSuccessState) {
                        setState(() {
                          _latestSettlement = salaryState.settlement;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 वेतन भुगतान संपन्न! (Salary Settled Successfully)'),
                            backgroundColor: AppColors.present,
                          ),
                        );
                        _loadSalaryCalculation();
                        showDialog(
                          context: context,
                          builder: (ctx) => DigitalSalarySlipDialog(settlement: salaryState.settlement),
                        );
                      } else if (salaryState is SalaryErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(salaryState.message), backgroundColor: Colors.red),
                        );
                      }
                    },
                    builder: (context, salaryState) {
                      return BlocBuilder<AttendanceBloc, AttendanceState>(
                        builder: (context, state) {
                          if (state is AttendanceLoading) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 48),
                                child: Ux4gLoadingIndicator(
                                  size: 40,
                                  color: isContrast ? AppColors.darkPrimary : AppColors.primary,
                                  message: a11y.isHindi
                                      ? 'मासिक उपस्थिति विवरण लोड हो रहा है...'
                                      : 'Loading monthly attendance ledger...',
                                ),
                              ),
                            );
                          }

                          if (state is MonthlyReportLoaded) {
                            final report = state.report;

                            // Payroll Computation with backend allowance integration
                            final totalWorkingDays = _latestCalculation?.totalWorkingDays ?? (report.totalWorkingDays > 0 ? report.totalWorkingDays : 26);
                            final perDaySalary = _baseSalary / totalWorkingDays;
                            final fallbackDeductionAmount = (report.calculatedDeductions * perDaySalary).roundToDouble();
                            final deductionAmount = _latestCalculation?.deductionAmount ?? fallbackDeductionAmount;
                            final netPayable = _latestCalculation?.netPayableSalary ?? (_baseSalary - fallbackDeductionAmount).clamp(0.0, _baseSalary);
                            final isSettled = _latestCalculation?.isAlreadySettled ?? false;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(18),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Month Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_getMonthName(_month)} $_year Ledger',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isContrast ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isContrast ? AppColors.darkPrimary.withOpacity(0.15) : AppColors.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Attendance: ${report.attendancePercentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isContrast ? const Color(0xFF0F172A) : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Metrics Summary Grid
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('working_days'),
                                        value: '${report.totalWorkingDays}',
                                        color: AppColors.primary,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('present_days'),
                                        value: '${report.presentDays}',
                                        color: AppColors.present,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('late_days'),
                                        value: '${report.lateDays}',
                                        color: AppColors.late,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('status_half_day'),
                                        value: '${report.halfDays}',
                                        color: AppColors.halfDay,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('absent_days'),
                                        value: '${report.absentDays}',
                                        color: AppColors.absent,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildMetricTile(
                                        label: a11y.tr('deductions'),
                                        value: '${report.calculatedDeductions.toStringAsFixed(1)}d',
                                        color: isContrast ? AppColors.darkSecondary : Colors.deepOrange,
                                        isContrast: isContrast,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Salary Breakdown Card (वेतन गणना)
                                _buildSalaryCard(
                                  report: report,
                                  netPayable: netPayable,
                                  deductionAmount: deductionAmount,
                                  isContrast: isContrast,
                                  a11y: a11y,
                                  isSettled: isSettled,
                                ),
                                const SizedBox(height: 14),

                                // 1-Tap UPI Payment & WhatsApp Share Action Buttons
                                _buildActionButtons(
                                  report: report,
                                  netPayable: netPayable,
                                  deductionAmount: deductionAmount,
                                  isContrast: isContrast,
                                  isSettled: isSettled,
                                ),
                                const SizedBox(height: 18),

                                // Visual Calendar Card
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isContrast ? AppColors.hcSurface : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isContrast ? AppColors.hcBorder : AppColors.border,
                                      width: isContrast ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a11y.tr('visual_calendar'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isContrast ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      MonthlyCalendarGrid(
                                        year: _year,
                                        month: _month,
                                        logs: report.dailyLogs,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Daily Records Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Daily Attendance Entries',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isContrast ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${report.dailyLogs.length} logged',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Daily Attendance Entries with Arrival/Departure Duration
                                if (report.dailyLogs.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isContrast ? AppColors.hcSurface : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isContrast ? AppColors.hcBorder : AppColors.border,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No check-in records found for this month.',
                                        style: TextStyle(
                                          color: isContrast ? Colors.white70 : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...report.dailyLogs.map((log) {
                                    final hasOut = log.checkOutTime != null && log.checkOutTime!.isNotEmpty;
                                    final inTime = log.checkInTime ?? "08:00 AM";
                                    final outTime = log.checkOutTime ?? "--:--";
                                    final durationStr = _computeDuration(inTime, outTime);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isContrast ? AppColors.hcSurface : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isContrast ? AppColors.hcBorder : AppColors.border,
                                          width: isContrast ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${log.attendanceDate.day}/${log.attendanceDate.month}/${log.attendanceDate.year}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: isContrast ? Colors.white : AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.schedule_rounded,
                                                      size: 13,
                                                      color: isContrast ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        hasOut
                                                            ? 'In: $inTime • Out: $outTime ($durationStr)'
                                                            : 'In: $inTime • In Progress / Pending Out',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500,
                                                          color: hasOut
                                                              ? (isContrast ? Colors.white70 : AppColors.textSecondary)
                                                              : (isContrast ? AppColors.darkPrimary : const Color(0xFF1A73E8)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (log.overrideByEmployerName != null) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Overridden: ${log.overrideByEmployerName}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: isContrast ? AppColors.darkSecondary : AppColors.secondary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: StatusBadge(
                                              status: log.status,
                                              entryType: log.entryType,
                                              isMock: log.isMockLocation,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        );
                      }

                      return const Center(child: Text('Loading monthly ledger...'));
                    },
                  );
                },
              ),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalaryCard({
    required MonthlyReportEntity report,
    required double netPayable,
    required double deductionAmount,
    required bool isContrast,
    required AccessibilityController a11y,
    required bool isSettled,
  }) {
    final allowedLeaves = _latestCalculation?.allowedLeaves ?? 2;
    final deductionDays = _latestCalculation?.effectiveDeductionDays ?? report.calculatedDeductions;
    final receiptRef = _latestCalculation?.settlementReceiptRef;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcSurface : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSettled
              ? (isContrast ? AppColors.darkPresent : const Color(0xFF137333))
              : (isContrast ? AppColors.hcBorder : const Color(0xFFDADCE0)),
          width: isContrast || isSettled ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isSettled ? Icons.verified_rounded : Icons.payments_rounded,
                      color: isContrast ? AppColors.darkPresent : const Color(0xFF137333),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a11y.tr('salary_breakdown'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isContrast ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!isSettled)
                InkWell(
                  onTap: _showEditSalaryDialog,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: isContrast ? AppColors.darkPrimary : AppColors.primary),
                        const SizedBox(width: 2),
                        Text('Edit', style: TextStyle(fontSize: 11, color: isContrast ? AppColors.darkPrimary : AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isContrast ? AppColors.darkPresentBg : const Color(0xFFE6F4EA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SETTLED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isContrast ? const Color(0xFF0F172A) : const Color(0xFF137333),
                    ),
                  ),
                ),
            ],
          ),
          if (isSettled && receiptRef != null) ...[
            const SizedBox(height: 8),
            Text(
              'रसीद सं. (Receipt No): $receiptRef',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isContrast ? AppColors.darkPresent : const Color(0xFF137333),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),

          // Breakdown items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${a11y.tr("base_monthly_salary")}:',
                  style: TextStyle(fontSize: 12, color: isContrast ? Colors.white70 : AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${_baseSalary.toInt()}',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isContrast ? Colors.white : AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Attendance Deductions (${deductionDays.toStringAsFixed(1)} days):',
                        style: TextStyle(fontSize: 12, color: isContrast ? Colors.white70 : AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: '$allowedLeaves paid allowed leaves applied without deduction',
                      child: Icon(Icons.info_outline, size: 13, color: isContrast ? AppColors.darkPrimary : AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '-₹${deductionAmount.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.deepOrange),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${a11y.tr("net_payable")}:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isContrast ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${netPayable.toInt()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isContrast ? AppColors.darkPresent : const Color(0xFF137333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isContrast ? AppColors.darkSurfaceElevated : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isContrast ? Colors.white24 : const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 16, color: isContrast ? AppColors.darkPresent : const Color(0xFF137333)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maid UPI ID: $_upiId',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isContrast ? Colors.white70 : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons({
    required MonthlyReportEntity report,
    required double netPayable,
    required double deductionAmount,
    required bool isContrast,
    required bool isSettled,
  }) {
    final a11y = AccessibilityController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSettled) ...[
          // View Digital Slip Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isContrast ? AppColors.darkPresent : const Color(0xFF137333),
                foregroundColor: isContrast ? const Color(0xFF0F172A) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                if (_latestSettlement != null) {
                  showDialog(
                    context: context,
                    builder: (_) => DigitalSalarySlipDialog(settlement: _latestSettlement!),
                  );
                } else {
                  _viewSalaryReceipt(1);
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'डिजिटल वेतन पर्ची देखें (View Digital Slip)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ] else ...[
          // 1-Tap UPI Payment Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isContrast ? AppColors.darkPresent : const Color(0xFF137333),
                foregroundColor: isContrast ? const Color(0xFF0F172A) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () => _payViaUpi(netPayable),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on_rounded, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '1-Tap Pay ₹${netPayable.toInt()} via UPI (GPay/PhonePe)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Settle Confirmation Button
          SizedBox(
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isContrast ? AppColors.darkBorderHighlight : const Color(0xFF137333)),
                foregroundColor: isContrast ? AppColors.darkPrimary : const Color(0xFF137333),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                if (_latestCalculation != null) {
                  _showSettleDialog(_latestCalculation!);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_turned_in_rounded, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      a11y.tr('settle_salary'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // WhatsApp Share Salary Slip Button
        SizedBox(
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: isContrast ? AppColors.hcSurface : const Color(0xFFE8F5E9),
              foregroundColor: isContrast ? AppColors.darkPresent : const Color(0xFF2E7D32),
              side: BorderSide(
                color: isContrast ? AppColors.darkPresent : const Color(0xFF4CAF50),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => _shareSalarySlipOnWhatsApp(report, netPayable, deductionAmount),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share_rounded, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${a11y.tr("share_salary_slip")} (WhatsApp)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required bool isContrast,
  }) {
    return Ux4gCard(
      elevation: 0,
      cornerRadius: 10,
      backgroundColor: isContrast ? Colors.white10 : color.withOpacity(0.08),
      borderColor: isContrast ? AppColors.darkBorder : color.withOpacity(0.25),
      borderWidth: isContrast ? 1.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isContrast ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
