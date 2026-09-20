import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/core/services/upi_payment_launcher.dart';

void main() {
  group('UpiPaymentLauncher URI Construction Tests', () {
    test('buildUpiUri should format standard NPCI UPI URI with all required parameters', () {
      final uri = UpiPaymentLauncher.buildUpiUri(
        upiId: 'sunita@okhdfcbank',
        payeeName: 'Sunita Devi',
        amount: 4500.0,
        note: 'Salary for September 2026',
      );

      expect(uri, contains('upi://pay?'));
      expect(uri, contains('pa=sunita@okhdfcbank'));
      expect(uri, contains('pn=Sunita%20Devi'));
      expect(uri, contains('am=4500.00'));
      expect(uri, contains('cu=INR'));
      expect(uri, contains('tn=Salary%20for%20September%202026'));
    });

    test('buildUpiUri handles trim and default note properly', () {
      final uri = UpiPaymentLauncher.buildUpiUri(
        upiId: ' anita@paytm ',
        payeeName: ' Anita Kumari ',
        amount: 3800.5,
      );

      expect(uri, contains('pa=anita@paytm'));
      expect(uri, contains('pn=Anita%20Kumari'));
      expect(uri, contains('am=3800.50'));
      expect(uri, contains('tn=Maid%20Monthly%20Salary'));
    });
  });
}
