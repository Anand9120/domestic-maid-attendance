import 'package:flutter/material.dart';
import '../accessibility/accessibility_controller.dart';

class Ux4gCivicBar extends StatelessWidget {
  final bool showTitle;

  const Ux4gCivicBar({
    super.key,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = AccessibilityController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isContrast = controller.isHighContrast;
        final currentScale = controller.textScaleFactor;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indian National Tricolor Ribbon (GIGW & UX4G standard)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    color: const Color(0xFFFF9933), // Saffron
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 4,
                    color: Colors.white, // White
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 4,
                    color: const Color(0xFF138808), // India Green
                  ),
                ),
              ],
            ),

            // Civic Accessibility Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isContrast ? Colors.black : const Color(0xFF0B3866),
                border: Border(
                  bottom: BorderSide(
                    color: isContrast ? Colors.yellow : const Color(0xFF1D5490),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Civic Emblem / Logo + Text
                  if (showTitle) ...[
                    const Icon(
                      Icons.account_balance_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.tr('gov_portal_title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isContrast ? Colors.yellow : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),

                  // Accessibility Controls (A-, A, A+)
                  _buildScaleButton(
                    label: 'A-',
                    isSelected: currentScale < 0.95,
                    onTap: () => controller.setScale(0.85),
                    semanticsLabel: 'Decrease text size',
                    isContrast: isContrast,
                  ),
                  const SizedBox(width: 4),
                  _buildScaleButton(
                    label: 'A',
                    isSelected: currentScale >= 0.95 && currentScale <= 1.05,
                    onTap: () => controller.setScale(1.0),
                    semanticsLabel: 'Standard text size',
                    isContrast: isContrast,
                  ),
                  const SizedBox(width: 4),
                  _buildScaleButton(
                    label: 'A+',
                    isSelected: currentScale > 1.05,
                    onTap: () => controller.setScale(1.20),
                    semanticsLabel: 'Increase text size',
                    isContrast: isContrast,
                  ),
                  const SizedBox(width: 8),

                  // High Contrast Toggle
                  Semantics(
                    button: true,
                    label: 'Toggle High Contrast Theme',
                    child: InkWell(
                      onTap: () => controller.toggleHighContrast(),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: isContrast ? Colors.yellow : Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isContrast ? Colors.black : Colors.white30,
                          ),
                        ),
                        child: Icon(
                          Icons.contrast_rounded,
                          size: 15,
                          color: isContrast ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Language Switcher (EN / हिन्दी)
                  Semantics(
                    button: true,
                    label: 'Toggle Language English or Hindi',
                    child: InkWell(
                      onTap: () => controller.toggleLocale(),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isContrast ? Colors.yellow : const Color(0xFFE05A1B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          controller.isHindi ? 'English' : 'हिन्दी',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isContrast ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScaleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required String semanticsLabel,
    required bool isContrast,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected
                ? (isContrast ? Colors.yellow : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isContrast ? Colors.yellow : Colors.white38,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? (isContrast ? Colors.black : const Color(0xFF0B3866))
                  : (isContrast ? Colors.yellow : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
