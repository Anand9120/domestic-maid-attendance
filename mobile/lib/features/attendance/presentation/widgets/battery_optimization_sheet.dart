import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/accessibility/accessibility_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/ux4g/ux4g.dart';

/// Modal sheet offering step-by-step guidance to prevent
/// aggressive OEM battery managers from killing background GPS tracking.
class BatteryOptimizationSheet extends StatelessWidget {
  const BatteryOptimizationSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BatteryOptimizationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;
    final isContrast = a11y.isHighContrast;
    final isHindi = a11y.isHindi;

    return Container(
      decoration: BoxDecoration(
        color: isContrast ? AppColors.hcBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isContrast ? AppColors.hcBorder : AppColors.border,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag bar
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

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isContrast ? AppColors.darkPrimary.withOpacity(0.2) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.battery_charging_full_rounded,
                  color: Color(0xFF2563EB),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'अबाधित उपस्थिति हेतु बैटरी सेटिंग्स' : 'Background GPS Optimization',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isContrast ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isHindi ? 'बिना रुकावट स्वतः चेक-इन के लिए बैटरी सेवर बंद करें' : 'Ensure zero-touch automated check-ins run reliably',
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

          // Instruction Cards
          _buildStepRow(
            '1',
            isHindi ? 'बैटरी उपयोग को "अनियंत्रित" (Unrestricted) करें' : 'Set Battery Usage to "Unrestricted"',
            isHindi
                ? 'फोन सेटिंग्स > ऐप्स > सहायिका > बैटरी > नो रिस्ट्रिक्शन चुनें।'
                : 'Phone Settings > Apps > Sahayika > Battery > Select "No Restrictions".',
            Icons.battery_alert_rounded,
            isContrast,
          ),
          const SizedBox(height: 10),

          _buildStepRow(
            '2',
            isHindi ? '"ऑटो-स्टार्ट" (Autostart) अनुमति चालू करें' : 'Enable "Autostart" Permission',
            isHindi
                ? 'Xiaomi, Vivo, Oppo और Realme फ़ोनों में बैकग्राउंड ऑटोस्टार्ट चालू करना आवश्यक है।'
                : 'Required for Xiaomi/MIUI, Vivo, Oppo, Realme to allow background presence checks.',
            Icons.play_circle_outline_rounded,
            isContrast,
          ),
          const SizedBox(height: 10),

          _buildStepRow(
            '3',
            isHindi ? 'सटीक स्थान (Precise Location) की अनुमति दें' : 'Grant "Allow All the Time" Location',
            isHindi
                ? 'स्थान अनुमति को "हर समय अनुमति दें" (Allow All the Time) पर सेट करें।'
                : 'Set location permission to "Allow all the time" with Precise Location enabled.',
            Icons.location_on_outlined,
            isContrast,
          ),
          const SizedBox(height: 22),

          // Action Button: Open App Settings
          Ux4gButton(
            text: isHindi ? 'फोन सेटिंग्स खोलें' : 'Open Device App Settings',
            variant: Ux4gButtonVariant.primary,
            size: Ux4gButtonSize.large,
            leadingIcon: Icons.settings_rounded,
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
          ),
          const SizedBox(height: 10),

          Ux4gButton(
            text: isHindi ? 'समझ गया (बंद करें)' : 'Got it (Close)',
            variant: Ux4gButtonVariant.outline,
            size: Ux4gButtonSize.large,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    String stepNum,
    String title,
    String description,
    IconData icon,
    bool isContrast,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isContrast ? Colors.white10 : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isContrast ? Colors.white24 : AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF2563EB),
            child: Text(
              stepNum,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isContrast ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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
    );
  }
}
