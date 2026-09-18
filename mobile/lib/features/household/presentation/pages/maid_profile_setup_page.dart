import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../../core/widgets/ux4g_civic_bar.dart';
import '../../../attendance/presentation/pages/attendance_dashboard_page.dart';
import '../../../auth/domain/entities/user_entity.dart';

class MaidProfileSetupPage extends StatefulWidget {
  final int? maidId;
  final String? initialName;
  final String? initialPhone;

  const MaidProfileSetupPage({
    super.key,
    this.maidId,
    this.initialName,
    this.initialPhone,
  });

  @override
  State<MaidProfileSetupPage> createState() => _MaidProfileSetupPageState();
}

class _MaidProfileSetupPageState extends State<MaidProfileSetupPage> {
  late int _maidId;
  late String _fullName;
  late String _phoneNumber;
  String _emergencyContact = '9811122200';
  String _upiId = 'sunita@okhdfcbank';
  String _bankAccount = '';
  String _ifscCode = '';

  // Selected Services
  final Set<String> _selectedServices = {'COOKING', 'CLEANING'};

  // Linked households
  List<Map<String, dynamic>> _linkedHouseholds = [];
  bool _isLoadingHouseholds = false;
  bool _isLinkingCode = false;
  bool _isSavingProfile = false;

  final TextEditingController _inviteCodeController = TextEditingController();

  final List<Map<String, String>> _availableServices = [
    {'key': 'COOKING', 'label': '🍳 Cooking (खाना बनाना)'},
    {'key': 'CLEANING', 'label': '🧹 Cleaning (झाड़ू-पोंछा)'},
    {'key': 'DISHES', 'label': '🍽️ Dishes (बर्तन धोना)'},
    {'key': 'CHILDCARE', 'label': '👶 Child Care (शिशु देखभाल)'},
    {'key': 'ELDERCARE', 'label': '👵 Elder Care (बुजुर्ग देखभाल)'},
    {'key': 'LAUNDRY', 'label': '🧺 Laundry (कपड़े धोना)'},
    {'key': 'ALL_ROUNDER', 'label': '⭐ All-Rounder (समस्त कार्य)'},
  ];

  @override
  void initState() {
    super.initState();
    _maidId = widget.maidId ?? 2;
    _fullName = widget.initialName ?? 'Sunita Devi';
    _phoneNumber = widget.initialPhone ?? '9811122233';
    _fetchLinkedHouseholds();
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchLinkedHouseholds() async {
    setState(() => _isLoadingHouseholds = true);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 5),
      ));

      final response = await dio.get('${ApiConstants.maidAssignments}/$_maidId/assignments');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _linkedHouseholds = list.map((e) => e as Map<String, dynamic>).toList();
            _isLoadingHouseholds = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingHouseholds = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHouseholds = false);
    }
  }

  Future<void> _linkHouseholdByInviteCode() async {
    final code = _inviteCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-character invite code')),
      );
      return;
    }

    setState(() => _isLinkingCode = true);

    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 8),
      ));

      final response = await dio.post(
        ApiConstants.joinHouseholdByCode,
        data: {
          'maidId': _maidId,
          'inviteCode': code,
        },
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        _inviteCodeController.clear();
        await _fetchLinkedHouseholds();

        if (mounted) {
          setState(() => _isLinkingCode = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Successfully linked with household (Code: $code)!'),
              backgroundColor: AppColors.present,
            ),
          );
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to link household');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLinkingCode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Linking failed: Check if code is valid ($e)'),
            backgroundColor: AppColors.absent,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSavingProfile = true);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 8),
      ));

      final payload = {
        'fullName': _fullName.trim(),
        'emergencyContact': _emergencyContact.trim(),
        'servicesOffered': _selectedServices.join(','),
        'upiId': _upiId.trim(),
        'bankAccount': _bankAccount.trim().isNotEmpty ? '$_bankAccount (IFSC: $_ifscCode)' : null,
      };

      final response = await dio.put('${ApiConstants.userProfile}/$_maidId/profile', data: payload);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() => _isSavingProfile = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Maid Profile & Payout details updated!'),
              backgroundColor: AppColors.present,
            ),
          );
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingProfile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Profile update failed: $e'),
            backgroundColor: AppColors.absent,
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
            title: const Text('Maid Profile & Onboarding'),
            backgroundColor: isContrast ? Colors.black : AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SafeArea(
            child: Column(
              children: [
                const Ux4gCivicBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Info Card
                            _buildInfoCard(
                              icon: Icons.badge_outlined,
                              title: 'Digital Worker Identity & Payouts',
                              subtitle: 'Set your services, payment address, and link employer households using their 6-digit Invite Code.',
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 20),

                            // Section 1: Personal & Emergency
                            _buildSectionHeader(
                              number: '1',
                              title: 'Personal & Emergency Details (व्यक्तिगत विवरण)',
                              icon: Icons.person_rounded,
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'Full Name *',
                              placeholder: 'Sunita Devi',
                              value: _fullName,
                              leadingIcon: Icons.person_outline_rounded,
                              onValueChange: (v) => setState(() => _fullName = v),
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'Mobile Number *',
                              placeholder: '9811122233',
                              prefixText: '+91 ',
                              value: _phoneNumber,
                              type: Ux4gInputFieldType.number,
                              leadingIcon: Icons.phone_android_rounded,
                              onValueChange: (v) => setState(() => _phoneNumber = v),
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'Emergency Contact (Family / Relative) *',
                              placeholder: '9811122200',
                              prefixText: '+91 ',
                              value: _emergencyContact,
                              type: Ux4gInputFieldType.number,
                              leadingIcon: Icons.emergency_rounded,
                              caption: 'Used for worker safety and emergency alert dispatch.',
                              onValueChange: (v) => setState(() => _emergencyContact = v),
                            ),
                            const SizedBox(height: 24),

                            // Section 2: Services Offered Chips
                            _buildSectionHeader(
                              number: '2',
                              title: 'Services Offered (प्रदत्त सेवाएं)',
                              icon: Icons.handyman_rounded,
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableServices.map((service) {
                                final isSelected = _selectedServices.contains(service['key']);
                                return FilterChip(
                                  selected: isSelected,
                                  label: Text(service['label']!),
                                  labelStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? (isContrast ? Colors.black : Colors.white)
                                        : (isContrast ? Colors.white : AppColors.textPrimary),
                                  ),
                                  selectedColor: isContrast ? Colors.yellow : AppColors.primary,
                                  backgroundColor: isContrast ? Colors.black : Colors.grey.shade100,
                                  checkmarkColor: isContrast ? Colors.black : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? (isContrast ? Colors.yellow : AppColors.primary)
                                          : (isContrast ? Colors.white24 : AppColors.border),
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedServices.add(service['key']!);
                                      } else {
                                        if (_selectedServices.length > 1) {
                                          _selectedServices.remove(service['key']!);
                                        }
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),

                            // Section 3: Payout Details
                            _buildSectionHeader(
                              number: '3',
                              title: 'Direct Bank / UPI Payout (वेतन भुगतान खाता)',
                              icon: Icons.account_balance_wallet_rounded,
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'UPI ID (PhonePe / Google Pay / Paytm / BHIM) *',
                              placeholder: 'e.g. sunita@paytm or 9811122233@upi',
                              value: _upiId,
                              leadingIcon: Icons.qr_code_rounded,
                              caption: 'Salary will be directly transferred to this UPI VPA.',
                              onValueChange: (v) => setState(() => _upiId = v),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Ux4gInputField(
                                    label: 'Bank A/c Number (Optional)',
                                    placeholder: '123456789012',
                                    value: _bankAccount,
                                    type: Ux4gInputFieldType.number,
                                    leadingIcon: Icons.account_balance_rounded,
                                    onValueChange: (v) => setState(() => _bankAccount = v),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: Ux4gInputField(
                                    label: 'IFSC Code',
                                    placeholder: 'SBIN0001234',
                                    value: _ifscCode,
                                    leadingIcon: Icons.numbers_rounded,
                                    onValueChange: (v) => setState(() => _ifscCode = v.toUpperCase()),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Section 4: Link Household via Invite Code
                            _buildSectionHeader(
                              number: '4',
                              title: 'Link with Employer Household (घर से जुड़ें)',
                              icon: Icons.link_rounded,
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isContrast ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isContrast ? Colors.yellow : AppColors.primary.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Enter 6-digit Invite Code provided by employer:',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _inviteCodeController,
                                          textCapitalization: TextCapitalization.characters,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'e.g. SHARMA402',
                                            filled: true,
                                            fillColor: isContrast ? Colors.grey.shade900 : Colors.grey.shade50,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: AppColors.border),
                                            ),
                                            prefixIcon: const Icon(Icons.vpn_key_rounded, size: 20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isContrast ? Colors.yellow : AppColors.primary,
                                          foregroundColor: isContrast ? Colors.black : Colors.white,
                                          minimumSize: const Size(120, 48),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: _isLinkingCode
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                              )
                                            : const Icon(Icons.link_rounded, size: 18),
                                        label: const Text('Link', style: TextStyle(fontWeight: FontWeight.bold)),
                                        onPressed: _isLinkingCode ? null : _linkHouseholdByInviteCode,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Linked Households List
                            const Text(
                              'Linked Households (जुड़े हुए घर):',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            if (_isLoadingHouseholds)
                              const Center(child: CircularProgressIndicator())
                            else if (_linkedHouseholds.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No households linked yet. Enter an invite code above to connect.',
                                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: _linkedHouseholds.map((assignment) {
                                  final loc = assignment['householdLocation'] as Map<String, dynamic>? ?? {};
                                  final houseName = loc['houseName'] ?? 'Household';
                                  final addr = loc['address'] ?? '';
                                  final salary = loc['monthlySalary'] ?? 0;
                                  final code = loc['inviteCode'] ?? '';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isContrast ? Colors.black : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isContrast ? Colors.white38 : AppColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.present.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.home_rounded, color: AppColors.present, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                houseName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              Text(
                                                addr,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                              ),
                                              if (salary > 0)
                                                Text(
                                                  'Salary: ₹$salary/mo • Code: $code',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.present.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'ACTIVE',
                                            style: TextStyle(
                                              color: AppColors.present,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 24),

                            // Save Profile Button
                            Ux4gButton(
                              text: 'Save Profile & Payout Details',
                              variant: Ux4gButtonVariant.primary,
                              size: Ux4gButtonSize.large,
                              isLoading: _isSavingProfile,
                              leadingIcon: Icons.save_rounded,
                              onPressed: _saveProfile,
                            ),
                            const SizedBox(height: 14),

                            // Go to Dashboard Button
                            SizedBox(
                              width: double.infinity,
                              child: Ux4gButton(
                                text: 'Go to Attendance Dashboard',
                                variant: Ux4gButtonVariant.secondary,
                                size: Ux4gButtonSize.large,
                                leadingIcon: Icons.dashboard_rounded,
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AttendanceDashboardPage(
                                        user: UserEntity(
                                          id: _maidId,
                                          fullName: _fullName,
                                          phoneNumber: _phoneNumber,
                                          role: UserRole.maid,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String number,
    required String title,
    required IconData icon,
    required bool isContrast,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isContrast ? Colors.yellow : AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isContrast ? Colors.black : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 20, color: isContrast ? Colors.yellow : AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isContrast ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isContrast,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isContrast ? Colors.black : AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isContrast ? Colors.yellow : AppColors.primary.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isContrast ? Colors.yellow : AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isContrast ? Colors.yellow : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isContrast ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
