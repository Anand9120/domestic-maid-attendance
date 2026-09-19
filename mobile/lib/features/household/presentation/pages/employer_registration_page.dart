import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/ux4g/ux4g.dart';
import '../../../../core/widgets/ux4g_civic_bar.dart';
import '../../../attendance/presentation/pages/attendance_dashboard_page.dart';
import '../../../auth/domain/entities/user_entity.dart';

class EmployerRegistrationPage extends StatefulWidget {
  final int? employerId;
  final String? initialName;
  final String? initialPhone;

  const EmployerRegistrationPage({
    super.key,
    this.employerId,
    this.initialName,
    this.initialPhone,
  });

  @override
  State<EmployerRegistrationPage> createState() => _EmployerRegistrationPageState();
}

class _EmployerRegistrationPageState extends State<EmployerRegistrationPage> {
  // Employer Profile
  late String _fullName;
  late String _phoneNumber;
  String _email = '';

  // Household Details
  String _houseName = 'Sharma Residence - Flat 402';
  String _address = 'B-Block, Green Park Heights, New Delhi';
  double _latitude = 28.6315;
  double _longitude = 77.2167;
  double _geofenceRadius = 50.0;
  double _dwellTimeMinutes = 3.0;
  String _inviteCode = 'SHARMA402';

  // Shifts & Compensation
  TimeOfDay _morningStart = const TimeOfDay(hour: 7, minute: 30);
  TimeOfDay _morningEnd = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay _eveningStart = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _eveningEnd = const TimeOfDay(hour: 20, minute: 0);
  String _monthlySalary = '5000';
  String _allowedLeaves = '2';

  bool _isDetectingGps = false;
  bool _isSubmitting = false;
  String? _gpsAccuracy;

  @override
  void initState() {
    super.initState();
    _fullName = widget.initialName ?? 'Priya Sharma';
    _phoneNumber = widget.initialPhone ?? '9876543210';
  }

  Future<void> _detectGpsLocation() async {
    setState(() => _isDetectingGps = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
          _gpsAccuracy = '±${pos.accuracy.toStringAsFixed(1)}m';
          _isDetectingGps = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 GPS Calibrated: ${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)} (Accuracy: $_gpsAccuracy)'),
            backgroundColor: AppColors.present,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDetectingGps = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ GPS fetch error: $e'),
            backgroundColor: AppColors.absent,
          ),
        );
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final h = tod.hour.toString().padLeft(2, '0');
    final m = tod.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _submitRegistration() async {
    if (_fullName.trim().isEmpty || _phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill employer name and phone number')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'employerId': widget.employerId ?? 1,
        'houseName': _houseName.trim().isEmpty ? 'Home' : _houseName.trim(),
        'address': _address.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'geofenceRadiusMeters': _geofenceRadius.toInt(),
        'dwellTimeMinutes': _dwellTimeMinutes.toInt(),
        'inviteCode': _inviteCode.trim().toUpperCase(),
        'monthlySalary': double.tryParse(_monthlySalary) ?? 5000.0,
        'allowedLeaves': int.tryParse(_allowedLeaves) ?? 2,
        'shifts': [
          {
            'shiftName': 'Morning Shift',
            'startTime': _formatTimeOfDay(_morningStart),
            'endTime': _formatTimeOfDay(_morningEnd),
            'gracePeriodMinutes': 15,
          },
          {
            'shiftName': 'Evening Shift',
            'startTime': _formatTimeOfDay(_eveningStart),
            'endTime': _formatTimeOfDay(_eveningEnd),
            'gracePeriodMinutes': 15,
          }
        ]
      };

      final household = await sl.setupHouseholdUseCase.execute(payload);
      final finalInviteCode = household.inviteCode ?? _inviteCode;

      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccessInviteDialog(finalInviteCode);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registering household: $e'),
            backgroundColor: AppColors.absent,
          ),
        );
      }
    }
  }

  void _showSuccessInviteDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.present.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.present, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Household Registered!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Share this 6-character Invite Code or QR code with your maid. When they enter it in their app, they will automatically link to your household geofence.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: QrImageView(
                    data: 'MAID_INVITE:$code',
                    version: QrVersions.auto,
                    size: 160.0,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Copy Code',
                        icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Invite code "$code" copied to clipboard!'),
                              backgroundColor: AppColors.present,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.dashboard_rounded, size: 18),
              label: const Text('Go to Dashboard'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceDashboardPage(
                      user: UserEntity(
                        id: widget.employerId ?? 1,
                        fullName: _fullName,
                        phoneNumber: _phoneNumber,
                        role: UserRole.employer,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
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
            title: const Text('Household Registration'),
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
                            // Header Notice
                            _buildInfoBanner(
                              icon: Icons.home_work_rounded,
                              title: 'Setup Your Household Geofence & Shifts',
                              subtitle: 'Once registered, your maid’s attendance will automatically record with zero manual buttons whenever they remain inside your premises for $_dwellTimeMinutes continuous minutes.',
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 20),

                            // Section 1: Employer Details
                            _buildSectionHeader(
                              number: '1',
                              title: 'Employer Details (नियोक्ता विवरण)',
                              icon: Icons.person_outline_rounded,
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'Employer Full Name *',
                              placeholder: 'e.g. Priya Sharma',
                              value: _fullName,
                              leadingIcon: Icons.person_rounded,
                              onValueChange: (v) => setState(() => _fullName = v),
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'Mobile Number *',
                              placeholder: '9876543210',
                              prefixText: '+91 ',
                              value: _phoneNumber,
                              type: Ux4gInputFieldType.number,
                              leadingIcon: Icons.phone_android_rounded,
                              onValueChange: (v) => setState(() => _phoneNumber = v),
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'Email Address (Optional)',
                              placeholder: 'employer@domain.com',
                              value: _email,
                              type: Ux4gInputFieldType.email,
                              leadingIcon: Icons.email_outlined,
                              onValueChange: (v) => setState(() => _email = v),
                            ),
                            const SizedBox(height: 24),

                            // Section 2: Household & Geofence
                            _buildSectionHeader(
                              number: '2',
                              title: 'Premises & GPS Geofence (घर व लोकेशन)',
                              icon: Icons.location_on_outlined,
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'House / Flat Name *',
                              placeholder: 'e.g. Sharma Residence - Flat 402',
                              value: _houseName,
                              leadingIcon: Icons.apartment_rounded,
                              onValueChange: (v) => setState(() => _houseName = v),
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'Street Address *',
                              placeholder: 'e.g. B-Block, Green Park Heights, New Delhi',
                              value: _address,
                              leadingIcon: Icons.signpost_outlined,
                              onValueChange: (v) => setState(() => _address = v),
                            ),
                            const SizedBox(height: 14),

                            // GPS Auto Detect Button
                            Container(
                              padding: const EdgeInsets.all(14),
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
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.gps_fixed_rounded,
                                        color: isContrast ? Colors.yellow : AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'GPS Coordinates Calibration',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      if (_gpsAccuracy != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.present.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Accuracy: $_gpsAccuracy',
                                            style: const TextStyle(
                                              color: AppColors.present,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Lat: ${_latitude.toStringAsFixed(6)} | Lon: ${_longitude.toStringAsFixed(6)}',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      color: isContrast ? Colors.white70 : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Ux4gButton(
                                      text: _isDetectingGps ? 'Calibrating GPS...' : 'Auto-Detect My Current GPS Location',
                                      variant: Ux4gButtonVariant.secondary,
                                      size: Ux4gButtonSize.medium,
                                      isLoading: _isDetectingGps,
                                      leadingIcon: Icons.my_location_rounded,
                                      onPressed: _detectGpsLocation,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Geofence Radius Slider
                            _buildSliderControl(
                              title: 'Geofence Radius: ${_geofenceRadius.toInt()} meters',
                              subtitle: 'Recommended for multi-story apartments: 50m (filters road traffic)',
                              value: _geofenceRadius,
                              min: 25,
                              max: 100,
                              divisions: 15,
                              onChanged: (v) => setState(() => _geofenceRadius = v),
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 14),

                            // Dwell Time Slider
                            _buildSliderControl(
                              title: 'Dwell Time Threshold: ${_dwellTimeMinutes.toInt()} minutes',
                              subtitle: 'Maid must remain inside 50m for 3 continuous minutes before attendance registers (Zero pass-by false alarms).',
                              value: _dwellTimeMinutes,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              onChanged: (v) => setState(() => _dwellTimeMinutes = v),
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 24),

                            // Section 3: Shifts & Compensation
                            _buildSectionHeader(
                              number: '3',
                              title: 'Shifts & Compensation (शिफ्ट व वेतन)',
                              icon: Icons.access_time_rounded,
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePickerTile(
                                    label: 'Morning Shift',
                                    start: _morningStart,
                                    end: _morningEnd,
                                    onPickStart: (t) => setState(() => _morningStart = t),
                                    onPickEnd: (t) => setState(() => _morningEnd = t),
                                    isContrast: isContrast,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTimePickerTile(
                                    label: 'Evening Shift',
                                    start: _eveningStart,
                                    end: _eveningEnd,
                                    onPickStart: (t) => setState(() => _eveningStart = t),
                                    onPickEnd: (t) => setState(() => _eveningEnd = t),
                                    isContrast: isContrast,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Ux4gInputField(
                                    label: 'Monthly Base Salary *',
                                    placeholder: '5000',
                                    prefixText: '₹ ',
                                    value: _monthlySalary,
                                    type: Ux4gInputFieldType.number,
                                    leadingIcon: Icons.currency_rupee_rounded,
                                    onValueChange: (v) => setState(() => _monthlySalary = v),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Ux4gInputField(
                                    label: 'Allowed Monthly Leaves',
                                    placeholder: '2',
                                    postfixText: ' days',
                                    value: _allowedLeaves,
                                    type: Ux4gInputFieldType.number,
                                    leadingIcon: Icons.event_available_rounded,
                                    onValueChange: (v) => setState(() => _allowedLeaves = v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Section 4: Household Invite Code
                            _buildSectionHeader(
                              number: '4',
                              title: 'Household Invite Code (आमंत्रण कोड)',
                              icon: Icons.key_rounded,
                              isContrast: isContrast,
                            ),
                            const SizedBox(height: 12),
                            Ux4gInputField(
                              label: 'Custom / Generated Invite Code',
                              placeholder: 'SHARMA402',
                              value: _inviteCode,
                              leadingIcon: Icons.qr_code_2_rounded,
                              caption: 'A 6 to 8 character alphanumeric code that your maid will enter to join.',
                              onValueChange: (v) => setState(() => _inviteCode = v.toUpperCase()),
                            ),
                            const SizedBox(height: 30),

                            // Submit Button
                            Ux4gButton(
                              text: 'Save & Generate Maid Invite Code',
                              variant: Ux4gButtonVariant.primary,
                              size: Ux4gButtonSize.large,
                              isLoading: _isSubmitting,
                              leadingIcon: Icons.save_rounded,
                              onPressed: _submitRegistration,
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

  Widget _buildInfoBanner({
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

  Widget _buildSliderControl({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required bool isContrast,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isContrast ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isContrast ? Colors.white24 : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isContrast ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: isContrast ? Colors.yellow : AppColors.primary,
            inactiveColor: isContrast ? Colors.white24 : Colors.grey.shade300,
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String label,
    required TimeOfDay start,
    required TimeOfDay end,
    required ValueChanged<TimeOfDay> onPickStart,
    required ValueChanged<TimeOfDay> onPickEnd,
    required bool isContrast,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isContrast ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isContrast ? Colors.white24 : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isContrast ? Colors.yellow : AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: start);
              if (picked != null) onPickStart(picked);
            },
            child: Row(
              children: [
                const Icon(Icons.alarm, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('In: ${start.format(context)}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: end);
              if (picked != null) onPickEnd(picked);
            },
            child: Row(
              children: [
                const Icon(Icons.alarm_off, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Out: ${end.format(context)}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
