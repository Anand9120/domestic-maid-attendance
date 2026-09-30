import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/ux4g/ux4g.dart';

/// Maid Emergency SOS & Safety Distress Modal Sheet
///
/// Designed in accordance with GIGW 3.0 and National Women Safety
/// guidelines (Helpline 112 & 1090 dispatch with live GPS pin).
class MaidSosPanicSheet extends StatelessWidget {
  final Position? currentPosition;
  final String employerPhoneNumber;
  final String currentHouseholdName;

  const MaidSosPanicSheet({
    super.key,
    this.currentPosition,
    this.employerPhoneNumber = '9876543210',
    this.currentHouseholdName = 'Current Workplace',
  });

  static void show(
    BuildContext context, {
    Position? currentPosition,
    String employerPhone = '9876543210',
    String householdName = 'Workplace',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MaidSosPanicSheet(
        currentPosition: currentPosition,
        employerPhoneNumber: employerPhone,
        currentHouseholdName: householdName,
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _shareSmsEmergency(String lat, String lon) async {
    final msg = Uri.encodeComponent(
      'EMERGENCY SOS: Domestic Worker in distress at $currentHouseholdName. Location: https://maps.google.com/?q=$lat,$lon',
    );
    final uri = Uri.parse('sms:$employerPhoneNumber?body=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;
    final isContrast = a11y.isHighContrast;
    final isHindi = a11y.isHindi;

    final latStr = currentPosition?.latitude.toStringAsFixed(5) ?? '22.72461';
    final lonStr = currentPosition?.longitude.toStringAsFixed(5) ?? '75.85792';

    return Container(
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isContrast ? AppColors.hcBorder : const Color(0xFFDC2626),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Alert Title Banner
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'आपातकालीन सुरक्षा सहायता (SOS)' : 'Emergency Safety Assistance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.white : const Color(0xFF991B1B),
                      ),
                    ),
                    Text(
                      isHindi
                        ? 'लाइव GPS स्थान के साथ तत्काल सहायता प्राप्त करें'
                        : 'Immediate help dispatch with live GPS broadcast',
                      style: TextStyle(
                        fontSize: 11,
                        color: isContrast ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Live Location Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isContrast ? Colors.black45 : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.pin_drop_rounded, color: Color(0xFFDC2626), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentHouseholdName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isContrast ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'GPS: $latStr, $lonStr',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: isHindi ? 'SMS द्वारा स्थान भेजें' : 'Send location via SMS',
                  child: IconButton(
                    tooltip: isHindi ? 'SMS द्वारा स्थान भेजें' : 'Send location via SMS',
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: const Icon(Icons.send_rounded, color: Color(0xFFDC2626)),
                    onPressed: () => _shareSmsEmergency(latStr, lonStr),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Speed Dial Emergency Helpline Buttons
          Text(
            isHindi ? 'तत्काल संपर्क करें (Emergency Helplines)' : 'Instant One-Tap Helplines',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isContrast ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // 112 National Helpline
          InkWell(
            onTap: () => _makeCall('112'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.call_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '112 - National Emergency (राष्ट्रीय आपातकाल)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Police / Ambulance / Fire Support 24x7',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 1090 Women Helpline
          InkWell(
            onTap: () => _makeCall('1090'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isContrast ? Colors.white12 : const Color(0xFF475569),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1090 - Women Safety Helpline (महिला सुरक्षा)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Toll-Free Government Women Distress Response',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Employer Direct Call
          InkWell(
            onTap: () => _makeCall(employerPhoneNumber),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isContrast ? Colors.white10 : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${isHindi ? "नियोक्ता को कॉल करें" : "Call Employer"} ($employerPhoneNumber)',
                          style: TextStyle(
                            color: isContrast ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Direct phone call to registered household employer',
                          style: TextStyle(
                            color: isContrast ? Colors.white70 : AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: isContrast ? Colors.white60 : Colors.grey, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Dismiss Button
          Ux4gButton(
            text: isHindi ? 'वापस जाएं (सुरक्षित)' : 'Dismiss (I am Safe)',
            variant: Ux4gButtonVariant.outline,
            size: Ux4gButtonSize.large,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
