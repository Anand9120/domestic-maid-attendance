import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiPaymentLauncher {
  static String buildUpiUri({
    required String upiId,
    required String payeeName,
    required double amount,
    String? note,
  }) {
    final cleanUpi = upiId.trim();
    final cleanName = Uri.encodeComponent(payeeName.trim());
    final amountFormatted = amount.toStringAsFixed(2);
    final transactionNote = Uri.encodeComponent(note ?? 'Maid Monthly Salary');

    return 'upi://pay?pa=$cleanUpi&pn=$cleanName&am=$amountFormatted&cu=INR&tn=$transactionNote';
  }

  static Future<bool> launchUpiIntent(String upiUri) async {
    try {
      final uri = Uri.parse(upiUri);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('UpiPaymentLauncher error: $e');
      return false;
    }
  }
}
