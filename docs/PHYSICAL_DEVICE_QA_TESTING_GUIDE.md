# 📱 Sahayika (सहायिका) — Physical Device QA & UAT Testing Guide
## Complete End-to-End Functional & UI/UX Testing Playbook for Testing Team

---

## 📑 Document Control & Overview

| Attribute | Details |
| :--- | :--- |
| **Document Purpose** | Comprehensive Testing Guide for Manual QA on Physical Android Devices |
| **App Name** | Sahayika (सहायिका) — Mobile Client |
| **Target OS** | Android 8.0 (API 26) to Android 14+ (API 34+) |
| **Architecture** | Flutter Clean Architecture + BLoC + UX4G Design System + Hive DB |
| **Backend Endpoint** | Live Cloud: `https://domestic-maid-attendance-backend.onrender.com` |
| **Status** | Version 4.0 (Enterprise Tested & Production Ready) |

---

## 🔑 Preloaded Test Credentials (Demo Accounts)

The testing team should use these pre-seeded accounts. No real SMS OTP is required in test mode; use the default verification code `123456`.

| User Role | User Full Name | Mobile Number | Default OTP | Household & Premise |
| :--- | :--- | :--- | :--- | :--- |
| **Employer (गृहस्वामी)** | Priya Sharma | `9876543210` | `123456` | Sharma Residence (Connaught Place, 50m radius) |
| **Domestic Maid (सहायिका 1)** | Sunita Devi | `9811122233` | `123456` | Assigned to Sharma Residence (Morning Shift) |
| **Domestic Maid (सहायिका 2)** | Anita Kumari | `9844455566` | `123456` | Assigned to Sharma Residence (Evening Shift) |

> [!TIP]
> Testing on multiple physical devices simultaneously:
> - **Device 1 (Employer Device)**: Log in as Priya Sharma (`9876543210`).
> - **Device 2 (Maid Device)**: Log in as Sunita Devi (`9811122233`).

---

## 🛠️ Step 0: APK Installation & Device Permissions Setup

Before commencing testing on physical phones:

1. **Install APK**:
   Copy the `app-release.apk` to your phone via USB / WhatsApp / Google Drive and tap to install (enable *"Install from Unknown Sources"* if prompted).
2. **Mandatory Device Permissions**:
   Go to phone **Settings ➔ Apps ➔ Sahayika ➔ Permissions**:
   - **Location (स्थान)**: Set to **"Allow all the time" (हमेशा अनुमति दें)** or **"Allow only while using the app"** with **"Use precise location" (सटीक स्थान)** enabled.
   - **Notifications (सूचनाएं)**: Set to **"Allowed"**.
   - **Battery (बैटरी)**: Set Battery Usage to **"Unrestricted" (अप्रतिबंधित)** so the OS does not kill the 3-minute background dwell timer when screen is locked.

---

## 🧪 Comprehensive Functional Test Suites

---

### Test Suite 1: Authentication & Form Validation (Positive & Negative)

#### 1.1 Mobile Number Input Validation
| Test Case ID | Test Scenario | Steps to Execute | Expected Result | Pass/Fail |
| :--- | :--- | :--- | :--- | :--- |
| **TC-AUTH-01** | Non-digit characters | Try typing letters (`abc`) or symbols (`#@!`) in phone field. | Field rejects non-digits completely (hardware filter active). | [ ] |
| **TC-AUTH-02** | Digits > 10 limit | Type 12 digits: `987654321099`. | Field strictly stops typing after 10 digits (`LengthLimitingTextInputFormatter`). | [ ] |
| **TC-AUTH-03** | Number starting with 0-5 | Type `0123456789` or `5555555555`. | Immediate live warning: *"भारतीय मोबाइल नंबर 6, 7, 8 या 9 से शुरू होना चाहिए"*. | [ ] |
| **TC-AUTH-04** | Incomplete phone | Type 8 digits (`98765432`) and tap "Get OTP". | Red error caption: *"कृपया पूरा 10 अंकों का मोबाइल नंबर दर्ज करें"*. Submission blocked. | [ ] |
| **TC-AUTH-05** | Repetitive dummy number | Type `0000000000` or `9999999999`. | Immediate rejection: *"कृपया एक वास्तविक मोबाइल नंबर दर्ज करें"*. | [ ] |
| **TC-AUTH-06** | Valid mobile number | Type `9876543210` with role Employer. | Field displays clean normal border, error disappears. | [ ] |

#### 1.2 Full Name & Role Selection
| Test Case ID | Test Scenario | Steps to Execute | Expected Result | Pass/Fail |
| :--- | :--- | :--- | :--- | :--- |
| **TC-AUTH-07** | Empty Full Name | Leave name blank and tap "Get OTP". | Red error: *"पूरा नाम दर्ज करना आवश्यक है"*. Submission blocked. | [ ] |
| **TC-AUTH-08** | Single letter name | Type `A` in Full Name field. | Error: *"पूरा नाम कम से कम 2 अक्षरों का होना चाहिए"*. | [ ] |
| **TC-AUTH-09** | Role Toggle | Tap "Maid / सहायिका" then "Employer / गृहस्वामी". | Selected role highlights in Civic Blue / Dark Primary with checkmark state. | [ ] |
| **TC-AUTH-10** | Valid OTP Submission | Enter `123456` in OTP verification screen. | Successful JWT authentication; navigates directly to Dashboard. | [ ] |
| **TC-AUTH-11** | Invalid OTP | Enter `000000` or less than 6 digits. | Rejects with error SnackBar; prevents access. | [ ] |

---

### Test Suite 2: UX4G Accessibility & Civic UI Testing

Sahayika complies 100% with the Government of India UX4G & GIGW 3.0 accessibility standard. Test these top Civic Bar controls:

| Test Case ID | Feature | Steps to Execute | Expected Behavior | Pass/Fail |
| :--- | :--- | :--- | :--- | :--- |
| **TC-UI-01** | **Font Scale A-** | Tap `A-` on the top civic bar. | App font scale decreases to 0.85x. No text truncation or layout overlap. | [ ] |
| **TC-UI-02** | **Font Scale A** | Tap `A` (Default) on civic bar. | App font scale returns to standard 1.0x. | [ ] |
| **TC-UI-03** | **Font Scale A+** | Tap `A+` on civic bar. | App font scale increases to 1.20x. All cards expand flexibly without yellow-black striped RenderFlex overflow warnings. | [ ] |
| **TC-UI-04** | **High Contrast Dark Mode** | Tap `👁️ Contrast` icon on civic bar. | UI smoothly switches to Deep Slate (`#0F172A`) with WCAG AAA 8.2:1 contrast ratio, high-visibility borders and white text. | [ ] |
| **TC-UI-05** | **Bilingual Switch** | Tap `हिन्दी` / `English` button. | UI instantly translates all buttons, tabs, alerts, and calendar headers in real-time without app restart. | [ ] |
| **TC-UI-06** | **Screen Size Fluidity** | Test on 5.5" screen vs 6.7" screen. | Cards, radar dials, and buttons fit cleanly within viewport. Zero horizontal scroll on portrait mode. | [ ] |

---

### Test Suite 3: Employer Flow — Household Setup & GPS Calibration

Log in as **Employer** (`9876543210` / `123456`):

| Test Case ID | Step | Action | Expected Output | Pass/Fail |
| :--- | :--- | :--- | :--- | :--- |
| **TC-EMP-01** | Navigate Setup | From Login or Dashboard, tap **"Register New Household (नया घर जोड़ें)"**. | Opens `EmployerRegistrationPage`. | [ ] |
| **TC-EMP-02** | Form Validation | Try submitting with empty House Name or Salary < ₹500. | Real-time red error captions; submit button blocks invalid data. | [ ] |
| **TC-EMP-03** | GPS Calibration | Stand inside your residence and tap **"Auto-Detect My Current GPS Location"**. | Phone hardware GPS polls coordinates; displays live Latitude, Longitude and Accuracy badge (e.g. `±3.8m`). | [ ] |
| **TC-EMP-04** | Sliders | Adjust Geofence Radius (25m - 100m) and Dwell Time (1m - 10m). | Dynamic text updates cleanly to match slider thumb value. | [ ] |
| **TC-EMP-05** | Shift Timers | Tap Morning Shift Start (07:30) and End (09:30). Tap Evening Shift. | Material time-picker opens and updates shift schedule. | [ ] |
| **TC-EMP-06** | Submit & QR Generation | Tap **"Register Household & Generate Invite Code"**. | Backend generates unique 6-character Invite Code (e.g. `SAH-9842`) and renders sharp QR Code on screen. | [ ] |
| **TC-EMP-07** | Copy / Share Code | Tap "Copy Code" or "Share QR". | Copies code to clipboard and shows success toast. | [ ] |

---

### Test Suite 4: Maid Flow — Profile Setup & Invite Code Linking

Log in as **Maid** (`9811122233` / `123456`):

| Test Case ID | Step | Action | Expected Output | Pass/Fail |
| :--- | :--- | :--- | :--- | :--- |
| **TC-MAID-01** | Open Profile | Tap **Profile / प्रोफाइल** from drawer or top menu. | Opens `MaidProfileSetupPage`. | [ ] |
| **TC-MAID-02** | Services Offered | Select/deselect chips: *Cooking, Cleaning, Dishes, Childcare*. | Chips toggle between active primary color and outline with checkmarks. | [ ] |
| **TC-MAID-03** | UPI VPA Validation | Enter invalid UPI (e.g. `sunita123`). Enter valid UPI (`9811122233@paytm`). | Invalid triggers warning; valid clears error. | [ ] |
| **TC-MAID-04** | Bank & IFSC Validation | Enter Account Number (`123456789012`) and IFSC (`SBIN0001234`). | Only digits allowed in account; IFSC auto-capitalizes to 11 characters. | [ ] |
| **TC-MAID-05** | Link by Invite Code | Enter Employer's 6-character Invite Code in Section 4 and tap **"Link"**. | Spinner displays while linking; success badge appears and newly linked household displays in "Linked Households" list with address. | [ ] |

---

### Test Suite 5: Geofencing & Zero-Touch Attendance Pipeline

> [!IMPORTANT]
> **Real-World Testing on Physical Devices**:
> This test verifies the core zero-touch innovation of Sahayika.

| Test Case ID | Scenario | Steps to Execute on Physical Device | Expected Result | Pass/Fail |
| :--- | :--- | :--- | :--- | :--- |
| **TC-GEO-01** | **Outside Boundary** | Helper stands > 60 meters away from the registered household coordinates. | Radar widget displays distance (e.g. `85m Away`); Status shows **"Outside Premises (घर से दूर)"**. No check-in occurs. | [ ] |
| **TC-GEO-02** | **Approach Residence** | Helper walks towards residence and crosses within the **50-meter perimeter**. | Radar state changes to **"Inside Boundary (परिसर के अंदर)"**; live distance displays (e.g. `24m`); Dwell timer initiates. | [ ] |
| **TC-GEO-03** | **Pass-By Filter (< 3 Mins)** | Helper walks past the door and leaves the 50m radius after 1 minute (simulating corridor/staircase transit). | Dwell timer cancels automatically; **no attendance is logged** (False trigger eliminated). | [ ] |
| **TC-GEO-04** | **Valid Autonomous Check-In** | Helper remains inside the 50m perimeter for **3 continuous minutes (180s)**. | Haptic vibration triggers; status updates to **उपस्थित (PRESENT)** or **विलंब (LATE)** automatically with **ZERO manual button clicks**! | [ ] |
| **TC-GEO-05** | **Instant Push Alert** | Observe Employer device upon maid check-in. | Employer receives real-time FCM push notification: *“🔔 सुनीता देवी 08:02 AM पर आपके घर पहुंच चुकी हैं।”* (< 3s delivery). | [ ] |
| **TC-GEO-06** | **Anti-Mock Fake GPS** | Install a Fake GPS / Mock Location app on Android and mock coordinates to employer house. | Hardware `isFromMockProvider()` detects fraud; server strictly rejects check-in with `GeofenceValidationException` (HTTP 400). | [ ] |
| **TC-GEO-07** | **Departure Check-Out** | Helper exits the 50m radius upon finishing work or taps Check-Out. | Check-out timestamp records; total duration calculated (e.g. `1h 45m`). Repeated taps do not inflate time. | [ ] |

---

### Test Suite 6: Offline-First Resilience (Elevator / Basement Dead-Zone)

| Test Case ID | Step | Action | Expected Output | Pass/Fail |
| :--- | :--- | :--- | :--- | :--- |
| **TC-OFF-01** | Disconnect Network | Turn ON **Airplane Mode** (or disable Wi-Fi & Mobile Data). | App header shows offline status indicator; no crash occurs. | [ ] |
| **TC-OFF-02** | Offline Check-In | Trigger attendance check-in while completely offline. | Event is encrypted and queued in local **Hive DB** (`offline_attendance_box`) with hardware timestamp. UI displays **"Offline Buffered (ऑफ़लाइन सुरक्षित)"** badge. | [ ] |
| **TC-OFF-03** | Network Reconnect | Turn OFF Airplane Mode (re-enable Wi-Fi / 4G). | Background sync engine detects connectivity within 10 seconds; flushes queued log to server; badge updates to synced green checkmark. | [ ] |
| **TC-OFF-04** | Zero Duplicate Rows | Rapidly tap sync or reconnect multiple times. | Database unique constraint `uk_maid_household_date_shift` prevents duplicate entries. | [ ] |

---

### Test Suite 7: Monthly Ledger, Mid-Month Payroll & UPI Settlement

Log in as **Employer** (`9876543210` / `123456`):

| Test Case ID | Step | Action | Expected Output | Pass/Fail |
| :--- | :--- | :--- | :--- | :--- |
| **TC-PAY-01** | Open Ledger | Tap **"Monthly Ledger & Salary (मासिक बहीखाता)"**. | Opens interactive calendar ledger for Sunita Devi. | [ ] |
| **TC-PAY-02** | Color Coding | Inspect days on visual calendar. | - Present: Emerald Green<br>- Late: Amber Orange<br>- Absent: Carmine Red<br>- Future Days: Neutral Grey. | [ ] |
| **TC-PAY-03** | Mid-Month Future Date Guard | Check ledger on an active mid-month date (e.g. Day 15). | Days 16–30/31 are **NOT penalised as absences**. Only elapsed working days incur wage calculations. | [ ] |
| **TC-PAY-04** | Pro-Rata Math | Verify calculation breakdown card: | Formula strictly enforced:<br>$\text{Net} = \text{Base Salary} - (\text{Deductible Days} \times \text{Per-Day Wage})$. | [ ] |
| **TC-PAY-05** | 1-Tap UPI Launch | Tap **"UPI द्वारा भुगतान करें (Pay via UPI)"**. | Device OS launches installed UPI apps (GPay / PhonePe / Paytm / BHIM) with prefilled VPA (`sunita@upi`), helper name, and exact amount. | [ ] |
| **TC-PAY-06** | Settle Payment | Return to app and tap **"वेतन भुगतान दर्ज करें (Settle Salary)"**. Enter UTR No. | Generates digital settlement receipt; updates ledger status to **SETTLED (भुगतान पूर्ण)**. | [ ] |
| **TC-PAY-07** | WhatsApp Slip | Tap **"WhatsApp पर भेजें (Share Slip)"**. | Opens WhatsApp with prefilled bilingual formatted salary summary receipt ready to send to helper. | [ ] |

---

## 📋 Defect Reporting Format (For QA Testers)

If any deviation or issue is found during testing, log it using this template:

```markdown
### 🐞 Defect Report: [Short Title]
- **Severity**: Critical (P0) / High (P1) / Medium (P2) / Low (P3)
- **Device Model**: e.g., Samsung Galaxy M31 / Redmi Note 12 / OnePlus Nord
- **Android OS Version**: e.g., Android 12 / Android 14
- **App Version**: Sahayika v4.0 (Release APK)
- **User Role Tested**: Employer / Maid
- **Pre-Conditions**: e.g., GPS enabled, High Contrast ON, Hindi language selected
- **Steps to Reproduce**:
  1. ...
  2. ...
  3. ...
- **Expected Behavior**: What should happen according to UX4G/RFP specs
- **Actual Behavior**: What actually happened (include error text or visual glitch)
- **Screenshots / Video**: Attach screenshot or screen recording
```

---

## ✅ Sign-Off Criteria for Pilot Deployment

The APK is certified for Pilot Release when:
1. **100% of P0 and P1 test cases pass** across at least 2 different physical Android phone models.
2. **Zero `RenderFlex` layout overflows** occur in both Normal and High-Contrast modes at `A+` font scale.
3. **Autonomous geofence check-in** triggers accurately after 3-minute dwell without false alarms.
4. **Offline synchronization** flushes seamlessly without record duplication.
