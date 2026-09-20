class ApiConstants {
  // Configured to laptop local Wi-Fi IP so real Android mobile devices can connect seamlessly
  static const String baseUrl = 'http://192.168.0.114:8080';

  // Auth endpoints
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String registerFcmToken = '/api/v1/auth/register-fcm-token';

  // Attendance endpoints
  static const String checkIn = '/api/v1/attendance/check-in';
  static const String checkOut = '/api/v1/attendance/check-out';
  static const String manualOverride = '/api/v1/attendance/manual-override';
  static const String maidAttendance = '/api/v1/attendance/maid';
  static const String householdAttendance = '/api/v1/attendance/household';

  // Household endpoints
  static const String householdSetup = '/api/v1/household/setup';
  static const String maidAssignments = '/api/v1/household/maid';
  static const String householdByCode = '/api/v1/household/code';
  static const String joinHouseholdByCode = '/api/v1/household/join-by-code';

  // Profile endpoints
  static const String userProfile = '/api/v1/auth/user';

  // Report endpoints
  static const String monthlyReport = '/api/v1/reports/monthly';

  // Notification endpoints
  static const String notifications = '/api/v1/notifications';
  static const String userNotifications = '/api/v1/notifications/user';

  // Salary endpoints
  static const String salary = '/api/v1/salary';
  static const String calculateSalary = '/api/v1/salary/calculate';
  static const String settleSalary = '/api/v1/salary/settle';
}

