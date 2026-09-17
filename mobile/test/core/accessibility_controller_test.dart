import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/core/accessibility/accessibility_controller.dart';

void main() {
  group('AccessibilityController GIGW 3.0 Tests', () {
    late AccessibilityController controller;

    setUp(() {
      controller = AccessibilityController.instance;
      // Reset to defaults
      controller.setScale(1.0);
      if (controller.isHighContrast) controller.toggleHighContrast();
      controller.setLocale('en');
    });

    test('Default scale should be 1.0', () {
      expect(controller.textScaleFactor, 1.0);
    });

    test('setScale modifies font scaling for A-, A, A+', () {
      controller.setScale(0.85);
      expect(controller.textScaleFactor, 0.85);

      controller.setScale(1.20);
      expect(controller.textScaleFactor, 1.20);
    });

    test('toggleHighContrast toggles contrast mode', () {
      expect(controller.isHighContrast, false);
      controller.toggleHighContrast();
      expect(controller.isHighContrast, true);
      controller.toggleHighContrast();
      expect(controller.isHighContrast, false);
    });

    test('Language toggle and translations support English and Hindi', () {
      expect(controller.locale, 'en');
      expect(controller.tr('maid_role'), 'Maid / Helper');

      controller.toggleLocale();
      expect(controller.locale, 'hi');
      expect(controller.isHindi, true);
      expect(controller.tr('maid_role'), 'सहायिका / कामगार');

      controller.toggleLocale();
      expect(controller.locale, 'en');
      expect(controller.tr('maid_role'), 'Maid / Helper');
    });
  });
}
