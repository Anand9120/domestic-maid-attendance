import 'package:flutter/material.dart';

class AccessibilityController extends ChangeNotifier {
  static final AccessibilityController instance = AccessibilityController._();
  AccessibilityController._();

  // Font scale factors: A- (0.85), A (1.0 - default), A+ (1.20)
  double _textScaleFactor = 1.0;
  double get textScaleFactor => _textScaleFactor;

  // High contrast / dark mode
  bool _isHighContrast = false;
  bool get isHighContrast => _isHighContrast;

  // Language: 'en' (English) or 'hi' (Hindi)
  String _locale = 'en';
  String get locale => _locale;
  bool get isHindi => _locale == 'hi';

  void setScale(double scale) {
    _textScaleFactor = scale;
    notifyListeners();
  }

  void toggleHighContrast() {
    _isHighContrast = !_isHighContrast;
    notifyListeners();
  }

  void setLocale(String lang) {
    _locale = lang;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = (_locale == 'en') ? 'hi' : 'en';
    notifyListeners();
  }

  // Bilingual strings helper
  String tr(String key) {
    if (isHindi) {
      return _hindiStrings[key] ?? _englishStrings[key] ?? key;
    }
    return _englishStrings[key] ?? key;
  }

  static const Map<String, String> _englishStrings = {
    'gov_portal_title': 'Domestic Maid Attendance Tracking System',
    'gov_subtitle': 'National e-Governance Standard (UX4G & GIGW 3.0)',
    'maid_dashboard': 'Maid Presence Dashboard',
    'employer_dashboard': 'Employer Dashboard',
    'zero_touch_desc': 'Zero-touch presence tracking with 50m geofence & offline sync',
    'select_role': 'Select Your Role',
    'maid_role': 'Maid / Helper',
    'employer_role': 'Employer',
    'full_name': 'Full Name',
    'phone_number': 'Phone Number',
    'get_otp': 'Get Verification Code',
    'verify_phone': 'Verify Phone Number',
    'enter_code': 'Enter 6-Digit Code',
    'code_sent_to': 'Code sent to',
    'test_mode_otp': 'Test Mode: Default OTP is 123456',
    'verify_continue': 'Verify & Continue',
    'live_presence_radar': 'Live Presence Radar (50m Geofence)',
    'inside_geofence': 'Inside 50m Geofence',
    'outside_geofence': 'Outside 50m Geofence',
    'dwell_completed': '3-min dwell complete (Arrival registered)',
    'dwell_counting': 'Dwell verification in progress',
    'enter_geofence': 'Enter 50m Boundary',
    'exit_geofence': 'Simulate Exit',
    'manual_checkin': 'Manual Check-in',
    'sync_offline': 'Sync Offline Logs',
    'logs_synced': 'All offline logs synced',
    'pending_sync': 'logs pending sync',
    'latest_log': 'Latest Attendance Log',
    'checkin_time': 'Check-in Time',
    'entry_type': 'Entry Type',
    'view_ledger': 'View Monthly Attendance Ledger',
    'manual_override': 'Manual Override',
    'override_hint': 'Employer correction for forgotten phone or keypad entry',
    'status_present': 'Present',
    'status_late': 'Late',
    'status_half_day': 'Half-Day',
    'status_absent': 'Absent',
    'status_offline': 'Offline',
    'status_mock_gps': '⚠️ Mock GPS',
    'working_days': 'Working Days',
    'present_days': 'Present Days',
    'late_days': 'Late Days',
    'absent_days': 'Absent Days',
    'calc_salary': 'Calculated Salary',
    'confirm': 'Confirm',
    'cancel': 'Cancel',
    'reason_notes': 'Reason / Notes',
    'logout': 'Logout',
    'font_size': 'Font Size',
    'high_contrast': 'High Contrast',
    'language': 'Language',
    'attendance_pipeline': 'Attendance Verification Pipeline',
    'step_geofence': 'Geofence',
    'step_geofence_desc': '50m Radius',
    'step_dwell': 'Dwell Timer',
    'step_dwell_desc': '3-min Stay',
    'step_audit': 'GPS Audit',
    'step_audit_desc': 'Mock Check',
    'step_verified': 'Presence',
    'step_verified_desc': 'Recorded',
    'realtime_telemetry': 'Real-Time GPS & Geofence Telemetry',
    'gps_hardware_status': 'Hardware GPS Status',
    'distance_to_target': 'Distance to Household',
    'calibrate_location': 'Set My Location as Household Geofence',
    'calibrating': 'Calibrating GPS...',
    'checkin_now': 'Check-In Now (Geofenced)',
    'authentic_gps': 'Authentic Hardware GPS (Clean)',
    'mock_gps_detected': 'Mock Location Detected (Spoofing Alert)',
  };

  static const Map<String, String> _hindiStrings = {
    'gov_portal_title': 'घरेलू सहायिका उपस्थिति प्रणाली',
    'gov_subtitle': 'राष्ट्रीय ई-गवर्नेंस मानक (UX4G एवं GIGW 3.0)',
    'maid_dashboard': 'सहायिका उपस्थिति डैशबोर्ड',
    'employer_dashboard': 'नियोक्ता डैशबोर्ड',
    'zero_touch_desc': '50 मीटर जियोफेंस और ऑफलाइन सिंक के साथ स्वतः उपस्थिति ट्रैकिंग',
    'select_role': 'अपनी भूमिका चुनें',
    'maid_role': 'सहायिका / कामगार',
    'employer_role': 'नियोक्ता / गृहस्वामी',
    'full_name': 'पूरा नाम',
    'phone_number': 'मोबाइल नंबर',
    'get_otp': 'सत्यापन कोड प्राप्त करें',
    'verify_phone': 'फोन नंबर सत्यापित करें',
    'enter_code': '6-अंकों का कोड दर्ज करें',
    'code_sent_to': 'कोड भेजा गया',
    'test_mode_otp': 'परीक्षण मोड: डिफ़ॉल्ट ओटीपी 123456 है',
    'verify_continue': 'सत्यापित करें और आगे बढ़ें',
    'live_presence_radar': 'लाइव उपस्थिति रडार (50 मीटर जियोफेंस)',
    'inside_geofence': '50 मीटर जियोफेंस के भीतर',
    'outside_geofence': 'जियोफेंस के बाहर',
    'dwell_completed': '3-मिनट ठहराव पूर्ण (उपस्थिति दर्ज)',
    'dwell_counting': 'ठहराव सत्यापन जारी है',
    'enter_geofence': '50मी परिधि में प्रवेश करें',
    'exit_geofence': 'बाहर निकलने का अनुकरण',
    'manual_checkin': 'मैन्युअल चेक-इन',
    'sync_offline': 'ऑफलाइन लॉग सिंक करें',
    'logs_synced': 'सभी ऑफलाइन लॉग सिंक हो चुके हैं',
    'pending_sync': 'लॉग सिंक हेतु शेष',
    'latest_log': 'नवीनतम उपस्थिति लॉग',
    'checkin_time': 'चेक-इन समय',
    'entry_type': 'प्रविष्टि प्रकार',
    'view_ledger': 'मासिक उपस्थिति रजिस्टर देखें',
    'manual_override': 'मैन्युअल सुधार (ओवरराइड)',
    'override_hint': 'फोन भूल जाने या कीपैड फोन हेतु नियोक्ता द्वारा सुधार',
    'status_present': 'उपस्थित (Present)',
    'status_late': 'विलंब (Late)',
    'status_half_day': 'आधा दिन (Half-Day)',
    'status_absent': 'अनुपस्थित (Absent)',
    'status_offline': 'ऑफलाइन',
    'status_mock_gps': '⚠️ नकली GPS',
    'working_days': 'कुल कार्य दिवस',
    'present_days': 'उपस्थित दिवस',
    'late_days': 'विलंब दिवस',
    'absent_days': 'अनुपस्थित दिवस',
    'calc_salary': 'देय वेतन',
    'confirm': 'पुष्टि करें',
    'cancel': 'रद्द करें',
    'reason_notes': 'कारण / टिप्पणी',
    'logout': 'लॉग आउट',
    'font_size': 'फ़ॉन्ट आकार',
    'high_contrast': 'उच्च कंट्रास्ट',
    'language': 'भाषा',
    'attendance_pipeline': 'उपस्थिति सत्यापन प्रक्रिया',
    'step_geofence': 'जियोफेंस',
    'step_geofence_desc': '50मी दायरा',
    'step_dwell': 'ठहराव समय',
    'step_dwell_desc': '3 मिनट',
    'step_audit': 'GPS जांच',
    'step_audit_desc': 'सत्यापन',
    'step_verified': 'उपस्थिति',
    'step_verified_desc': 'दर्ज',
    'realtime_telemetry': 'वास्तविक समय GPS और जियोफेंस टेलीमेट्री',
    'gps_hardware_status': 'हार्डवेयर GPS स्थिति',
    'distance_to_target': 'घर से दूरी',
    'calibrate_location': 'अपने वर्तमान स्थान को जियोफेंस बनाएं',
    'calibrating': 'GPS कैलिब्रेट हो रहा है...',
    'checkin_now': 'अभी उपस्थिति दर्ज करें (जियोफेंस सत्यापित)',
    'authentic_gps': 'प्रामाणिक हार्डवेयर GPS (सत्यापित)',
    'mock_gps_detected': 'नकली GPS का पता चला (सुरक्षा चेतावनी)',
  };
}
