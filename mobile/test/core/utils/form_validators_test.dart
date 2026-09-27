import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/core/utils/form_validators.dart';

void main() {
  group('FormValidators - Indian Mobile Number', () {
    test('rejects empty and null', () {
      expect(FormValidators.validateIndianPhoneNumber(''), isNotNull);
      expect(FormValidators.validateIndianPhoneNumber(null), isNotNull);
      expect(FormValidators.validateIndianPhoneNumber('   '), isNotNull);
    });

    test('rejects numbers starting with 0-5', () {
      expect(FormValidators.validateIndianPhoneNumber('0123456789'), contains('6, 7, 8, or 9'));
      expect(FormValidators.validateIndianPhoneNumber('1234567890'), contains('6, 7, 8, or 9'));
      expect(FormValidators.validateIndianPhoneNumber('5555555555'), contains('6, 7, 8, or 9'));
    });

    test('rejects numbers less or more than 10 digits', () {
      expect(FormValidators.validateIndianPhoneNumber('98765'), contains('10'));
      expect(FormValidators.validateIndianPhoneNumber('987654321012'), contains('10'));
    });

    test('rejects all-identical repetitive numbers', () {
      expect(FormValidators.validateIndianPhoneNumber('9999999999'), isNotNull);
      expect(FormValidators.validateIndianPhoneNumber('8888888888'), isNotNull);
    });

    test('accepts valid 10-digit Indian numbers starting with 6, 7, 8, 9', () {
      expect(FormValidators.validateIndianPhoneNumber('9876543210'), isNull);
      expect(FormValidators.validateIndianPhoneNumber('8123456789'), isNull);
      expect(FormValidators.validateIndianPhoneNumber('7012345678'), isNull);
      expect(FormValidators.validateIndianPhoneNumber('6398765432'), isNull);
      expect(FormValidators.validateIndianPhoneNumber('+91 98765 43210'), isNull);
      expect(FormValidators.validateIndianPhoneNumber('919876543210'), isNull);
    });

    test('returns Hindi error message when requested', () {
      final hindiErr = FormValidators.validateIndianPhoneNumber('0123456789', isHindi: true);
      expect(hindiErr, contains('6, 7, 8 या 9'));
    });
  });

  group('FormValidators - Full Name', () {
    test('rejects empty or single character', () {
      expect(FormValidators.validateFullName(''), isNotNull);
      expect(FormValidators.validateFullName('A'), isNotNull);
    });

    test('accepts valid English and Hindi names', () {
      expect(FormValidators.validateFullName('Sunita Devi'), isNull);
      expect(FormValidators.validateFullName('सुनीता देवी'), isNull);
      expect(FormValidators.validateFullName('Rajesh K. Sharma'), isNull);
    });
  });

  group('FormValidators - Salary & Leaves', () {
    test('validates salary minimum and maximum bounds', () {
      expect(FormValidators.validateSalary('100'), contains('₹500'));
      expect(FormValidators.validateSalary('600000'), contains('₹5,00,000'));
      expect(FormValidators.validateSalary('5000'), isNull);
      expect(FormValidators.validateSalary('15000'), isNull);
    });

    test('validates allowed leaves', () {
      expect(FormValidators.validateAllowedLeaves('-1'), isNotNull);
      expect(FormValidators.validateAllowedLeaves('35'), contains('31'));
      expect(FormValidators.validateAllowedLeaves('2'), isNull);
      expect(FormValidators.validateAllowedLeaves('4'), isNull);
    });
  });

  group('FormValidators - UPI & Banking', () {
    test('validates standard UPI IDs', () {
      expect(FormValidators.validateUpiId('9876543210@paytm'), isNull);
      expect(FormValidators.validateUpiId('sunita@okaxis'), isNull);
      expect(FormValidators.validateUpiId('invalidupi'), isNotNull);
    });

    test('validates bank accounts', () {
      expect(FormValidators.validateBankAccount('123456789012'), isNull);
      expect(FormValidators.validateBankAccount('1234'), contains('9'));
      expect(FormValidators.validateBankAccount('abcdefghij'), contains('digits'));
    });

    test('validates IFSC codes', () {
      expect(FormValidators.validateIfscCode('SBIN0001234'), isNull);
      expect(FormValidators.validateIfscCode('HDFC0000456'), isNull);
      expect(FormValidators.validateIfscCode('1234567'), contains('IFSC'));
    });

    test('validates invite code', () {
      expect(FormValidators.validateInviteCode('SAH984'), isNull);
      expect(FormValidators.validateInviteCode('SHARMA402'), isNull);
      expect(FormValidators.validateInviteCode('123'), contains('6'));
    });
  });

  group('FormValidators - Coordinates & Time', () {
    test('validates latitude bounds (-90 to +90)', () {
      expect(FormValidators.validateLatitude('28.6315'), isNull);
      expect(FormValidators.validateLatitude('-33.8688'), isNull);
      expect(FormValidators.validateLatitude(''), contains('required'));
      expect(FormValidators.validateLatitude('95.1234'), contains('between -90.0 and +90.0'));
      expect(FormValidators.validateLatitude('abc'), contains('decimal'));
    });

    test('validates longitude bounds (-180 to +180)', () {
      expect(FormValidators.validateLongitude('77.2167'), isNull);
      expect(FormValidators.validateLongitude('-122.4194'), isNull);
      expect(FormValidators.validateLongitude(''), contains('required'));
      expect(FormValidators.validateLongitude('185.0000'), contains('between -180.0 and +180.0'));
      expect(FormValidators.validateLongitude('xyz'), contains('decimal'));
    });

    test('validates 24-hour time format', () {
      expect(FormValidators.validateTime24h('08:00'), isNull);
      expect(FormValidators.validateTime24h('23:59'), isNull);
      expect(FormValidators.validateTime24h('00:00'), isNull);
      expect(FormValidators.validateTime24h(''), contains('required'));
      expect(FormValidators.validateTime24h('24:00'), contains('Invalid time format'));
      expect(FormValidators.validateTime24h('8:00'), contains('Invalid time format'));
      expect(FormValidators.validateTime24h('12:60'), contains('Invalid time format'));
    });
  });
}
