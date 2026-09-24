import 'package:flutter/services.dart';

/// Centralized Form Validators for Sahayika (National UX4G & Civic Standards)
class FormValidators {
  FormValidators._();

  /// Regular expression for standard Indian 10-digit mobile number (starts with 6, 7, 8, 9)
  static final RegExp _indianPhoneRegex = RegExp(r'^[6-9]\d{9}$');

  /// Regular expression for email format
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  /// Regular expression for standard Indian UPI ID (e.g. name@bank, 9876543210@paytm)
  static final RegExp _upiRegex = RegExp(
    r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$',
  );

  /// Regular expression for standard Indian IFSC code (4 letters, 0, 6 alphanumeric)
  static final RegExp _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  /// Indian mobile number input formatter (digits only, max 10 digits)
  static List<TextInputFormatter> get phoneFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];

  /// OTP input formatter (digits only, max 6 digits)
  static List<TextInputFormatter> get otpFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ];

  /// Currency/Salary input formatter (digits only, max 7 digits)
  static List<TextInputFormatter> get salaryFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(7),
      ];

  /// Leaves input formatter (digits only, max 2 digits)
  static List<TextInputFormatter> get leavesFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ];

  /// Name input formatter (letters, spaces, dots, hyphens only, max 50 chars)
  static List<TextInputFormatter> get nameFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s.\-'\u0900-\u097F]")),
        LengthLimitingTextInputFormatter(50),
      ];

  /// Invite Code input formatter (alphanumeric, max 12 chars)
  static List<TextInputFormatter> get inviteCodeFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
        LengthLimitingTextInputFormatter(12),
      ];

  /// Bank Account formatter (digits only, max 18 digits)
  static List<TextInputFormatter> get bankAccountFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(18),
      ];

  /// IFSC Code formatter (uppercase alphanumeric only, max 11 chars)
  static List<TextInputFormatter> get ifscFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        LengthLimitingTextInputFormatter(11),
      ];

  /// Validates standard 10-digit Indian Mobile Number
  static String? validateIndianPhoneNumber(String? value, {bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      return isHindi
          ? 'मोबाइल नंबर दर्ज करना आवश्यक है'
          : 'Mobile number is required';
    }

    final clean = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    final tenDigitPhone = clean.startsWith('91') && clean.length == 12
        ? clean.substring(2)
        : clean;

    if (!RegExp(r'^\d+$').hasMatch(tenDigitPhone)) {
      return isHindi ? 'केवल अंक (0-9) दर्ज करें' : 'Only numbers are allowed';
    }

    if (tenDigitPhone.length != 10) {
      return isHindi
          ? 'कृपया पूरा 10 अंकों का मोबाइल नंबर दर्ज करें (वर्तमान: ${tenDigitPhone.length})'
          : 'Enter exactly 10-digit mobile number (current: ${tenDigitPhone.length})';
    }

    if (!_indianPhoneRegex.hasMatch(tenDigitPhone)) {
      final firstDigit = int.tryParse(tenDigitPhone[0]) ?? 0;
      if (firstDigit < 6) {
        return isHindi
            ? 'भारतीय मोबाइल नंबर 6, 7, 8 या 9 से शुरू होना चाहिए'
            : 'Mobile number must start with 6, 7, 8, or 9';
      }
      return isHindi
          ? 'कृपया पूरा 10 अंकों का वैध मोबाइल नंबर दर्ज करें'
          : 'Please enter a valid 10-digit mobile number';
    }

    // Dummy/repetitive rejection (e.g. 0000000000, 1111111111)
    if (RegExp(r'^(\d)\1{9}$').hasMatch(tenDigitPhone)) {
      return isHindi
          ? 'कृपया एक वास्तविक मोबाइल नंबर दर्ज करें'
          : 'Please enter a valid mobile number';
    }

    return null;
  }

  /// Validates Person Full Name
  static String? validateFullName(String? value, {String? label, bool isHindi = false}) {
    final fieldLabel = label ?? (isHindi ? 'पूरा नाम' : 'Full Name');
    if (value == null || value.trim().isEmpty) {
      return isHindi
          ? '$fieldLabel दर्ज करना आवश्यक है'
          : '$fieldLabel is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return isHindi
          ? '$fieldLabel कम से कम 2 अक्षरों का होना चाहिए'
          : '$fieldLabel must be at least 2 characters';
    }

    if (trimmed.length > 50) {
      return isHindi
          ? '$fieldLabel 50 अक्षरों से अधिक नहीं हो सकता'
          : '$fieldLabel cannot exceed 50 characters';
    }

    return null;
  }

  /// Validates 6-Digit OTP
  static String? validateOtp(String? value, {bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      return isHindi ? '6 अंकों का OTP दर्ज करें' : 'Enter 6-digit OTP';
    }

    final clean = value.trim();
    if (clean.length != 6 || !RegExp(r'^\d{6}$').hasMatch(clean)) {
      return isHindi
          ? 'कृपया पूरा 6 अंकों का संख्यात्मक OTP दर्ज करें'
          : 'Please enter a valid 6-digit numeric OTP';
    }

    return null;
  }

  /// Validates Optional Email Address
  static String? validateEmail(String? value, {bool required = false, bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) {
        return isHindi ? 'ईमेल दर्ज करना आवश्यक है' : 'Email address is required';
      }
      return null;
    }

    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return isHindi
          ? 'कृपया मान्य ईमेल पता दर्ज करें (उदा. user@domain.com)'
          : 'Please enter a valid email address (e.g. user@domain.com)';
    }

    return null;
  }

  /// Validates House / Apartment Name
  static String? validateHouseName(String? value, {bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      return isHindi
          ? 'घर या फ्लैट का नाम आवश्यक है'
          : 'House / Flat name is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return isHindi
          ? 'घर का नाम कम से कम 2 अक्षरों का होना चाहिए'
          : 'House name must be at least 2 characters';
    }

    return null;
  }

  /// Validates Street Address
  static String? validateAddress(String? value, {bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      return isHindi ? 'पता दर्ज करना आवश्यक है' : 'Address is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 4) {
      return isHindi
          ? 'कृपया विस्तृत पता दर्ज करें (कम से कम 4 अक्षर)'
          : 'Please enter a detailed address (at least 4 characters)';
    }

    return null;
  }

  /// Validates Monthly Base Salary
  static String? validateSalary(String? value, {bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      return isHindi ? 'मासिक वेतन दर्ज करना आवश्यक है' : 'Monthly salary is required';
    }

    final clean = value.trim();
    final amount = double.tryParse(clean);
    if (amount == null) {
      return isHindi ? 'केवल मान्य राशि दर्ज करें' : 'Enter a valid numeric amount';
    }

    if (amount < 500) {
      return isHindi
          ? 'मासिक वेतन कम से कम ₹500 होना चाहिए'
          : 'Monthly salary must be at least ₹500';
    }

    if (amount > 500000) {
      return isHindi
          ? 'मासिक वेतन ₹5,00,000 से अधिक नहीं हो सकता'
          : 'Monthly salary cannot exceed ₹5,00,000';
    }

    return null;
  }

  /// Validates Allowed Monthly Leaves
  static String? validateAllowedLeaves(String? value, {bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      return isHindi ? 'स्वीकृत छुट्टियां दर्ज करें' : 'Allowed leaves is required';
    }

    final leaves = int.tryParse(value.trim());
    if (leaves == null) {
      return isHindi ? 'केवल संख्या दर्ज करें' : 'Enter valid numeric days';
    }

    if (leaves < 0) {
      return isHindi ? 'छुट्टियां ऋणात्मक नहीं हो सकतीं' : 'Leaves cannot be negative';
    }

    if (leaves > 31) {
      return isHindi ? 'छुट्टियां 31 दिनों से अधिक नहीं हो सकतीं' : 'Leaves cannot exceed 31 days';
    }

    return null;
  }

  /// Validates UPI ID (VPA)
  static String? validateUpiId(String? value, {bool required = true, bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) {
        return isHindi ? 'UPI ID दर्ज करना आवश्यक है' : 'UPI ID is required';
      }
      return null;
    }

    final trimmed = value.trim();
    if (!_upiRegex.hasMatch(trimmed)) {
      return isHindi
          ? 'मान्य UPI ID दर्ज करें (उदा. mobile@upi या name@okhdfcbank)'
          : 'Enter valid UPI ID (e.g. mobile@upi or name@okhdfcbank)';
    }

    return null;
  }

  /// Validates Bank Account Number
  static String? validateBankAccount(String? value, {bool required = false, bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) {
        return isHindi ? 'खाता संख्या आवश्यक है' : 'Account number is required';
      }
      return null;
    }

    final clean = value.trim();
    if (!RegExp(r'^\d+$').hasMatch(clean)) {
      return isHindi ? 'खाता संख्या केवल अंकों में होनी चाहिए' : 'Account number must be digits only';
    }

    if (clean.length < 9 || clean.length > 18) {
      return isHindi
          ? 'बैंक खाता संख्या 9 से 18 अंकों की होनी चाहिए'
          : 'Bank account number must be between 9 and 18 digits';
    }

    return null;
  }

  /// Validates IFSC Code
  static String? validateIfscCode(String? value, {bool required = false, bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) {
        return isHindi ? 'IFSC कोड आवश्यक है' : 'IFSC Code is required';
      }
      return null;
    }

    final upper = value.trim().toUpperCase();
    if (!_ifscRegex.hasMatch(upper)) {
      return isHindi
          ? 'मान्य 11-अक्षरीय IFSC कोड दर्ज करें (उदा. SBIN0001234)'
          : 'Enter valid 11-character IFSC code (e.g. SBIN0001234)';
    }

    return null;
  }

  /// Validates Invite Code
  static String? validateInviteCode(String? value, {bool isHindi = false}) {
    if (value == null || value.trim().isEmpty) {
      return isHindi ? 'आमंत्रण कोड दर्ज करें' : 'Invite code is required';
    }

    final clean = value.trim().toUpperCase();
    if (clean.length < 6 || clean.length > 12) {
      return isHindi
          ? 'आमंत्रण कोड 6 से 12 अक्षरों का होना चाहिए'
          : 'Invite code must be 6 to 12 characters';
    }

    return null;
  }
}
