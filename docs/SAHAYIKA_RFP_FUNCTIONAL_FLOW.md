# 📄 RFP & Functional Flow Specification
## Sahayika (सहायिका) — Zero-Touch Domestic Help Attendance & Transparent Payroll System

---

## 📑 Document Control & Metadata

| Attribute | Details |
| :--- | :--- |
| **Project Title** | Sahayika (सहायिका) — Domestic Attendance & Payroll Verification Platform |
| **System Tagline** | *हाज़िरी और भरोसा (Dignity, Presence & Trust)* |
| **Document Type** | Request For Proposal (RFP) / System Architecture & Operational Blueprint |
| **Version** | 4.0 (Enterprise Production & Security Hardened) |
| **Standards Compliance** | UX4G (National e-Governance Standard), GIGW 3.0 (WCAG 2.1 AAA), NPCI UPI Spec |
| **Target Platforms** | Android (Mobile App), Spring Boot (Cloud Backend), Docker (Alpine JRE 17), MySQL 8.0 |
| **Cloud Deployment** | Render Cloud (Containerized Web Service) + UptimeRobot Synthetic Heartbeat Monitor |
| **Test Coverage** | 56 Verified Tests (18 Spring Boot JUnit + 38 Flutter Unit/BLoC/Widget Tests) |
| **Status** | Approved for Implementation, Audited & Production Deployed |

---

## 1. Executive Summary & Problem Statement

### 1.1 The Challenge in Informal Domestic Employment
Across urban Indian residential complexes, gated communities, and standalone houses, over **50 million domestic workers (maids, cooks, caretakers)** form the invisible backbone of urban households. However, this sector operates almost entirely on informal, unwritten arrangements:
1. **Attendance Disputes**: Disagreements between employers and helpers over days worked, late arrivals, half-days, and sudden unannounced absences.
2. **Salary Friction & Deduction Confusion**: Mental math and manual diary entries lead to disputes at the start of each month regarding per-day wage deductions for leaves.
3. **Lack of Verifiable Digital Proof**: Feature-phone users and informal workers lack verifiable digital audit trails to prove their continuous presence, denying them access to micro-credit, formal banking, or government welfare subsidies.
4. **Biometric & Intrusive Hardware Failure**: Physical fingerprint scanners or society gate tablets create queues, hygiene concerns, high maintenance overhead, and privacy issues.

### 1.2 The Sahayika Solution
**Sahayika (सहायिका)** introduces a **zero-touch, non-intrusive, automated geofencing and dwell-time attendance verification platform** tailored to Indian societal conditions. 
- **Zero Manual Clicks Required**: Uses OS-level geofencing (50-meter perimeter) around employer residences.
- **3-Minute Dwell-Time Filter**: Eliminates false triggers caused by passing through corridors, stairwells, or society roads.
- **Offline-First Resilience**: Local encrypted buffer (Hive DB) guarantees seamless attendance logging in elevator dead-zones or basement flats.
- **Transparent Pro-Rata Payroll & UPI**: Computes precise monthly allowances, mid-month real-time projections without future date penalties, and triggers one-tap NPCI UPI salary payouts with instant bilingual WhatsApp salary slips.
- **Strict Anti-Spoofing & IDOR Security**: Rejects fake GPS mock locations at the API level and strictly enforces cryptographic token ownership on all report queries.
- **24/7 Cloud Availability ($0 Cost)**: Deployed on Render Cloud with an automated 5-minute UptimeRobot synthetic ping to eliminate cold-start sleep latency.
- **Dignified National Design**: Complies 100% with Government of India **UX4G Design System** and **GIGW 3.0** accessibility guidelines.

---

## 2. Stakeholders & User Personas

![System Stakeholders & User Personas Diagram](images/diagrams/01_stakeholders.png)

```mermaid
graph TD
    subgraph Users["System Stakeholders"]
        Maid["<b>Domestic Helper (सहायिका)</b><br>Sunita Devi<br>• Multi-household helper<br>• Low digital literacy<br>• Hindi UI & large visual cues"]
        Employer["<b>Employer / Householder</b><br>Rajesh Sharma<br>• Apartment Resident<br>• Real-time arrival push alerts<br>• Automated payroll & UPI payment"]
        RWA["<b>Society Management / Admin</b><br>RWA Committee<br>• Community-wide mapping<br>• Audit-proof entry verification<br>• Dispute arbitration"]
    end

    Maid -->|Autonomous Presence| App["<b>Sahayika App Engine</b>"]
    Employer -->|Invite Code & Approval| App
    RWA -->|Society Security & Audit| App
```

### 2.1 Persona A: Smt. Sunita Devi (Gharelu Sahayika)
- **Role**: Works in 4 different flats across Tower B & C in a residential society (morning and evening shifts).
- **Tech Literacy**: Basic smartphone user, prefers Hindi vernacular interface, audio/haptic feedback, and zero manual input.
- **Primary Need**: Ensure her presence is recorded fairly even if the householder is asleep or away, with transparent proof of working days.

### 2.2 Persona B: Sh. Rajesh Sharma (Employer / Resident)
- **Role**: Tech-working householder with busy morning schedules.
- **Primary Need**: Wants instant push notifications when Sunita arrives, automated month-end salary calculations factoring in agreed paid leaves, and 1-tap UPI payment directly to her bank account.

### 2.3 Persona C: System Administrator & Dispute Arbiter
- **Role**: RWA Secretary / Community Admin.
- **Primary Need**: Immutable audit trails, spoof-proof GPS validation, and employer manual override logs with documented reasons.

---

## 3. End-to-End Operational Lifecycle & Process Flows

The complete operational flow of Sahayika spans seven interconnected phases:

![End-to-End Operational Lifecycle Flowchart](images/diagrams/02_operational_lifecycle.png)

```mermaid
flowchart TD
    A([1. Household Setup & Calibration]) --> B([2. Maid Onboarding & QR/Code Linking])
    B --> C([3. Zero-Touch Presence Monitoring])
    C --> D([4. 3-Min Dwell & Anti-Fraud Verification])
    D --> E([5. Instant Push Notification & Log Sync])
    E --> F([6. Multi-Household Society Switching])
    F --> G([7. Month-End Payroll & UPI Settlement])
```

---

### Phase 1: Household Setup, Multi-Property & GPS Calibration

![Household Setup & GPS Calibration Sequence](images/diagrams/03_household_calibration_seq.png)

```mermaid
sequenceDiagram
    autonumber
    actor Emp as Employer (गृहस्वामी)
    participant App as Sahayika Mobile App
    participant GPS as Device Hardware GPS
    participant API as Spring Boot Backend
    participant DB as MySQL Database

    Emp->>App: Launches App & Selects 'Employer / गृहस्वामी'
    Emp->>App: Enters Phone Number -> Receives OTP
    App->>API: POST /api/v1/auth/verify-otp
    API-->>App: JWT Token + Employer Profile
    Emp->>App: Navigates to 'Add Household / आवास विवरण'
    Emp->>App: Taps 'Auto-Detect My Current GPS Location'
    App->>GPS: Request high-accuracy coordinates
    GPS-->>App: Latitude, Longitude, Accuracy (e.g. ±4.2m)
    Emp->>App: Configures Shift 1 (Morning) & Shift 2 (Evening)
    App->>API: POST /api/v1/household/setup (Lat, Lon, Radius=50m, Dwell=3m, Shifts=[1,2])
    API->>DB: Persist in `household_locations` & generate unique 6-char Invite Code (e.g., 'SAH-9842')
    API->>DB: Insert Shift Schedules without duplication
    API-->>App: Household registered + QR Code payload
    App-->>Emp: Displays Visual QR Code & Alphanumeric Invite Code
```

1. **Employer Registration**: The householder logs in using phone OTP authentication.
2. **Hardware Calibration**: The employer stands inside their apartment and taps **"Calibrate My Current GPS Location"**. The app polls the device hardware GPS to obtain high-precision coordinates with satellite accuracy validation.
3. **Multi-Property Independence**: Employers managing multiple properties (e.g., primary home and rental flat) can set up independent households without overwriting prior registrations.
4. **Dual Shift Support**: Supports multiple distinct shifts (e.g., Morning 07:00–11:00 and Evening 17:00–20:00) with custom grace periods.
5. **Geofence Definition**: Sets an OS-level circular geofence boundary with a default radius of **50 meters** and a **3-minute dwell time**.
6. **Invite Code Generation**: The server generates a unique alphanumeric invite code (and QR payload) for the helper.

---

### Phase 2: Maid Onboarding & Multi-Household Linking

![Maid Onboarding & Household Linking Sequence](images/diagrams/04_maid_onboarding_seq.png)

```mermaid
sequenceDiagram
    autonumber
    actor Maid as Helper (सहायिका)
    participant App as Sahayika App (Maid Mode)
    participant API as Backend API
    participant DB as MySQL Database

    Maid->>App: Selects Language (हिन्दी / English)
    Maid->>App: Authenticates via Phone OTP
    Maid->>App: Enters Household Invite Code (or Scans QR)
    App->>API: POST /api/v1/household/link (InviteCode, MaidUserId)
    API->>DB: Query `household_locations` by InviteCode
    API->>DB: Insert into `maid_household_assignments` (Status = 'ACTIVE')
    API-->>App: Household linked (Address, Geofence Coords, Shift Timings)
    App-->>Maid: Society radar updates with new linked household
```

1. **Bilingual Onboarding**: Sunita launches the app, taps the top Civic Bar to select **हिन्दी**, and logs in with her phone number.
2. **Linking Residences**: She enters the 6-digit code or scans the employer's QR code.
3. **Assignment Activation**: The backend binds the maid to the household with active status. Sunita can link multiple households within the same society (e.g., Flat 101, Flat 304, Flat 502).

---

### Phase 3: Zero-Touch Attendance Pipeline & Anti-Fraud Verification

![Zero-Touch Attendance & Anti-Fraud Verification Pipeline](images/diagrams/05_attendance_pipeline_flow.png)

```mermaid
flowchart TD
    Start([Helper approaches residence]) --> RoleCheck{User Role == MAID?}
    RoleCheck -- No (Employer Device) --> Abort[Skip Geofence Attendance]
    RoleCheck -- Yes --> GPS[OS Background Geofence Trigger]
    GPS --> CheckRadius{Distance <= 50m?}
    CheckRadius -- No --> Wait[Continue background telemetry]
    CheckRadius -- Yes --> DwellTimer[Start 3-Minute Dwell-Time Counter]

    DwellTimer --> DwellCheck{Remains inside for 180s?}
    DwellCheck -- Exited Early --> Cancel[Discard Pass-By / False Trigger]
    DwellCheck -- 180s Completed --> SpoofCheck{Mock GPS / Mock Location?}

    SpoofCheck -- Spoof Detected --> RejectFraud[Reject with GeofenceValidationException<br>HTTP 400 Bad Request]
    SpoofCheck -- Authentic GPS --> ValidCheckIn[Create Attendance Record<br>Status: PRESENT / LATE<br>Type: AUTO_GEOFENCE]

    ValidCheckIn --> OnlineCheck{Internet Connected?}
    OnlineCheck -- Yes --> PushBackend[POST /api/v1/attendance/check-in]
    OnlineCheck -- No (Elevator/Basement) --> BufferHive[Store in Local Hive DB<br>Preserve Hardware Timestamp]

    PushBackend --> SendFCM[Trigger Firebase Cloud Messaging<br>Alert Employer < 3s]
    BufferHive --> WaitNetwork[Wait for Connectivity Restore]
    WaitNetwork --> SyncWorker[Auto-Sync Worker pushes to Backend]
    SyncWorker --> SendFCM
```

#### Detailed Logic of Attendance Pipeline:
1. **Device Role Isolation**: Only client instances authenticated under the `MAID` role trigger autonomous geofencing. Employer devices are strictly blocked from accidentally logging auto-attendance for their workers.
2. **Geofence Detection**: As the helper enters within 50 meters of the employer's calibrated coordinates (calculated via the **Haversine formula**), the geofence engine registers an entry event.
3. **3-Minute Dwell-Time Gate**:
   $$\text{Dwell Duration} \ge 180 \text{ seconds}$$
   If the helper walks past the door to another floor or passes through the corridor, she leaves the 50m radius before 180 seconds elapse. The counter cancels automatically, preventing false check-ins.
4. **Strict Anti-Spoofing & Mock-GPS Rejection**:
   The engine queries `isFromMockProvider()` and detects fake GPS manipulation tools. If mock coordinates are detected, the backend immediately throws a `GeofenceValidationException` (HTTP 400), refusing to log fake attendance.
5. **Shift & Punctuality Engine**:
   - Compares arrival time against the configured shift schedule.
   - If arrival $\le$ Start Time + Grace Period (default 15 mins): Logged as **PRESENT (उपस्थित)**.
   - If arrival $>$ Start Time + Grace Period: Logged as **LATE (विलंब)**.
6. **Real-Time Push Notification (FCM)**:
   The backend asynchronously dispatches an urgent push notification to the employer's device:
   > *“🔔 सहायिका उपस्थित: सुनीता देवी 08:02 AM पर आपके घर पहुंच चुकी हैं (50m जियोफेंस सत्यापित)।”*
7. **Idempotent Check-Out**:
   Repeated check-out invocations return the existing valid record without inflating working hours or overwriting checkout timestamps.

---

### Phase 4: Society Multi-Household Auto-Switching Radar

When a helper works across multiple apartments in a high-rise society, Sahayika avoids confusing manual check-ins:

![Multi-Household Society Auto-Switching Radar State Machine](images/diagrams/06_multi_household_radar_state.png)

```mermaid
stateDiagram-v2
    [*] --> IdleOutsideSociety: Helper Outside Geofence
    IdleOutsideSociety --> Flat101_Active: Arrives at Flat 101 (Distance < 50m & Dwell >= 3m)
    
    state Flat101_Active {
        [*] --> WorkingAtFlat101
        WorkingAtFlat101 --> Departure101: Leaves Flat 101 Radius
    }

    Departure101 --> Flat304_AutoSwitch: Walks to Tower C, Flat 304 (Distance < 50m)

    state Flat304_AutoSwitch {
        [*] --> WorkingAtFlat304
        WorkingAtFlat304 --> Departure304: Completes shift & exits
    }

    Departure304 --> IdleOutsideSociety: Leaves Society Premises
```

1. **Parallel Distance Computing**: The app tracks distances to all assigned society households simultaneously.
2. **Autonomous Handover**: When Sunita finishes work at Flat 101 and moves to Flat 304, the radar detects departure from Flat 101 (logging check-out) and automatically primes the dwell-time counter for Flat 304.
3. **Zero Confusion**: Each household maintains an independent, isolated ledger and timestamp history.

---

### Phase 5: Offline-First Buffer & Auto-Sync (Elevator/Basement Resilience)

Urban buildings frequently suffer from cellular dead-zones in elevators, basements, and staircases.

![Offline-First Hive DB Buffer Architecture](images/diagrams/07_offline_buffer_sync.png)

```mermaid
graph LR
    subgraph ClientDevice["Helper Mobile Device"]
        Event["Check-In Trigger"] --> NetCheck{"Online?"}
        NetCheck -- "Online" --> RemoteAPI["Spring Boot API"]
        NetCheck -- "Offline" --> HiveDB[("Local Encrypted<br>Hive Storage")]
        HiveDB --> SyncEngine["Background Sync Engine"]
        SyncEngine -->|"Connectivity Restored"| RemoteAPI
    end

    subgraph CloudServer["Cloud Infrastructure"]
        RemoteAPI --> MySQL[("Production MySQL DB<br>Preserves Original Device Time")]
    end
```

1. **Encrypted Local Storage**: Check-in events generated while offline are written into a local encrypted **Hive DB** box (`offline_attendance_box`).
2. **Hardware Timestamp Preservation**: The exact hardware time when the geofence and dwell-time were validated is preserved, preventing sync-time timestamp drift.
3. **Database Unique Constraint**: The database enforces `@UniqueConstraint(name = "uk_maid_household_date_shift", columnNames = {"maid_id", "household_id", "log_date", "shift_id"})` ensuring network retries never create duplicate attendance rows.
4. **Reactive Synchronization**: As soon as the device connects to Wi-Fi or 4G, `SyncOfflineLogsEvent` fires in the background, flushing queued records to the server without user intervention.

---

### Phase 6: Monthly Ledger, Mid-Month Real-Time Payroll & IDOR Protection

![Monthly Payroll & Pro-Rata Deduction Calculation Sequence](images/diagrams/08_payroll_calculation_seq.png)

```mermaid
sequenceDiagram
    autonumber
    actor Emp as Employer (गृहस्वामी)
    participant App as Sahayika App
    participant Bloc as SalaryBloc & AttendanceBloc
    participant API as Backend Service

    Emp->>App: Opens 'Monthly Ledger & Salary (मासिक बहीखाता)'
    App->>Bloc: FetchMonthlyReport(Month, Year, MaidId)
    Bloc->>API: GET /api/v1/reports/monthly?maidId=X&month=Y&year=Z (Bearer JWT)
    API->>API: Verify IDOR: Authenticated User owns Maid/Household?
    alt Unauthorized IDOR Access
        API-->>Bloc: HTTP 403 Forbidden
    else Authorized
        API->>API: Run Mid-Month Date Guard (Filter out future dates)
        API-->>Bloc: ReportData (WorkingDays, PresentDays, LateDays, AbsentDays, AllowedLeaves)
        Bloc->>Bloc: Run Pro-Rata Payroll Engine
        Bloc-->>App: Display Visual Calendar + Financial Breakdown
        Emp->>App: Reviews Net Payable Amount
    end
```

#### Mid-Month Future Date Guard:
When calculating monthly reports on an active mid-month date (e.g. the 15th of the month):
$$\text{Evaluated Days} = \{ d \in \text{Month Days} \mid d \le \text{Today} \}$$
Future dates (Day 16 to Day 30/31) are classified as **FUTURE_DATE** and are **never penalised as unexcused absences**. This ensures real-time accuracy during mid-month audits without showing false deductions.

#### Mathematical Payroll Formula:
$$\text{Total Working Days} = \text{Calendar Days in Month} - \text{Designated Weekly Offs}$$

$$\text{Per-Day Wage (प्रति दिन मजदूरी)} = \frac{\text{Base Monthly Salary}}{\text{Total Working Days}}$$

$$\text{Deductible Days} = \max(0, \text{Elapsed Unexcused Absences} + (0.5 \times \text{Half Days}) - \text{Allowed Leaves})$$

$$\text{Deduction Amount (कटौती)} = \text{Deductible Days} \times \text{Per-Day Wage}$$

$$\text{Net Payable Salary (कुल देय वेतन)} = \max(0.0, \text{Base Monthly Salary} - \text{Deduction Amount})$$

---

### Phase 7: Digital Settlement, UPI Deep-Linking & WhatsApp Slip

![NPCI UPI Deep-Link Digital Settlement Sequence](images/diagrams/09_upi_settlement_seq.png)

```mermaid
sequenceDiagram
    autonumber
    actor Emp as Employer
    participant App as Sahayika App
    participant UPI as NPCI UPI App (GPay/PhonePe/Paytm)
    actor Maid as Helper (Bank Account)
    participant API as Backend API

    Emp->>App: Taps 'UPI द्वारा भुगतान करें (Pay via UPI)'
    App->>UPI: Launches standard NPCI UPI URI:<br>upi://pay?pa={maidUpi}&pn={maidName}&am={netPayable}&tn=Sahayika+Salary
    Emp->>UPI: Authorizes payment with UPI PIN
    UPI->>Maid: Bank Transfer Completed
    Emp->>App: Returns to App & Taps 'वेतन भुगतान दर्ज करें (Settle Salary)'
    App->>API: POST /api/v1/salary/settle
    API-->>App: Digital Salary Settlement Receipt Generated
    Emp->>App: Taps 'WhatsApp पर भेजें (Share Slip)'
    App-->>Maid: Sends formatted bilingual salary breakdown & audit receipt
```

1. **NPCI Compliant UPI Launcher**: Constructs verified UPI deep-link URI (`upi://pay?pa=...&pn=...&am=...&cu=INR`).
2. **Direct Bank-to-Bank**: Zero payment gateway commissions, ₹0 intermediary transaction fees.
3. **One-Tap WhatsApp Receipt**: Generates a clean, transparent Hindi/English summary receipt showing base pay, days worked, approved leaves, deductions, and net amount with a digital verification ID.

---

## 4. Technical Architecture & Component Stack

![Full-Stack Technical Architecture Diagram](images/diagrams/10_technical_architecture.png)

```mermaid
graph TB
    subgraph Frontend["Mobile Client (Flutter Clean Architecture)"]
        UI["Presentation Layer<br>• UX4G Widgets (Ux4gSpinner, Ux4gCard, Ux4gButton)<br>• GIGW 3.0 Accessibility Controller (Scale, Contrast, Bilingual)"]
        BLoC["State Management (BLoC)<br>• AuthBloc • AttendanceBloc • SalaryBloc • NotificationBloc"]
        Domain["Domain Layer<br>• UseCases • Entities • Contracts"]
        Data["Data Layer<br>• Repositories • Hive Local DB • Dio REST Client"]
    end

    subgraph Backend["Cloud Backend (Spring Boot 3.2.x / Java 17)"]
        Security["Spring Security 6 & Stateless JWT<br>• JwtAuthenticationFilter • IDOR Access Guards"]
        Controllers["REST Controllers<br>• AuthController • AttendanceController<br>• HouseholdController • ReportController • HealthController"]
        Services["Business Services<br>• GeofenceValidationServiceImpl (Haversine)<br>• AttendanceServiceImpl • SalarySettlementServiceImpl<br>• FcmNotificationServiceImpl"]
        Repos["Spring Data JPA Repositories"]
    end

    subgraph KeepAlive["High-Availability Synthetic Monitoring"]
        UptimeRobot["UptimeRobot Cloud Monitor<br>5-Min Keep-Alive Ping to /health"]
    end

    subgraph Storage["Persistence & Push"]
        MySQL[("MySQL 8.0 Database<br>InnoDB Storage Engine")]
        FCM["Firebase Cloud Messaging (FCM)<br>Push Delivery < 3s"]
    end

    UI --> BLoC
    BLoC --> Domain
    Domain --> Data
    Data --> Security
    Security --> Controllers
    Controllers --> Services
    Services --> Repos
    Repos --> MySQL
    Services --> FCM
    UptimeRobot -->|GET /health| Controllers
```

---

## 5. UI/UX Design System Compliance (UX4G & GIGW 3.0)

Sahayika strictly enforces the **Government of India UX4G Design Guidelines** and **GIGW 3.0 (Guidelines for Indian Government Websites and Apps)** standards:

| Parameter | UX4G Specification | Sahayika Implementation |
| :--- | :--- | :--- |
| **Primary Palette** | Civic Blue (`#0B4D8C`) | AppBars, primary CTAs, official headers |
| **Secondary Accent**| Warm Saffron (`#E06A3B` / `#FB923C`) | Shift timers, highlight tags, secondary buttons |
| **Success / Present**| Emerald Green (`#138808` / `#34D399`) | Check-in verified badges, salary settled chips |
| **Dark Theme** | Deep Civic Slate 900 (`#0F172A`) | WCAG AAA 8.2:1 contrast ratio, no harsh OLED eye strain |
| **Card Components** | `Ux4gCard` with subtle borders (`#334155`) | Standard 12px squircle radius with elevation and theme awareness |
| **Loading Indicators**| `Ux4gSpinner` (Arc Sweep Gradient) | Smooth rotational loop, anti-clipping geometry, size presets (16, 24, 36, 48px) |
| **Accessibility Scale**| Font sizing: A- (0.85x), A (1.0x), A+ (1.20x) | Managed by persistent `AccessibilityController` |
| **Bilingual Toggle**| Single-tap Hindi / English toggle | Instant localized UI text without restarting the app |
| **Screen Readers** | GIGW 3.0 / WCAG 2.1 AAA Semantics | `Semantics(liveRegion: true)` on timers, radar, and spinners |

---

## 6. Database Schema & Data Dictionary (MySQL 8.0)

![MySQL 8.0 Relational Entity-Relationship Diagram](images/diagrams/11_database_er_diagram.png)

```mermaid
erDiagram
    USERS ||--o{ HOUSEHOLD_LOCATIONS : owns
    USERS ||--o{ MAID_HOUSEHOLD_ASSIGNMENTS : works_as
    HOUSEHOLD_LOCATIONS ||--o{ SHIFT_SCHEDULES : defines
    HOUSEHOLD_LOCATIONS ||--o{ MAID_HOUSEHOLD_ASSIGNMENTS : has
    HOUSEHOLD_LOCATIONS ||--o{ ATTENDANCE_LOGS : logs_at
    USERS ||--o{ ATTENDANCE_LOGS : records
    USERS ||--o{ FCM_DEVICE_TOKENS : registers

    USERS {
        bigint id PK
        varchar full_name
        varchar phone_number UK
        varchar role "EMPLOYER, MAID, ADMIN"
        boolean is_active
        timestamp created_at
    }

    HOUSEHOLD_LOCATIONS {
        bigint id PK
        bigint employer_id FK
        varchar house_name
        varchar invite_code UK
        decimal latitude
        decimal longitude
        int geofence_radius_meters
        int dwell_time_minutes
    }

    SHIFT_SCHEDULES {
        bigint id PK
        bigint household_id FK
        varchar shift_name
        time start_time
        time end_time
        int grace_period_minutes
    }

    MAID_HOUSEHOLD_ASSIGNMENTS {
        bigint id PK
        bigint maid_id FK
        bigint household_id FK
        varchar status "ACTIVE, INACTIVE"
        timestamp assigned_at
    }

    ATTENDANCE_LOGS {
        bigint id PK
        bigint maid_id FK
        bigint household_id FK
        bigint shift_id FK
        date log_date
        timestamp check_in_time
        timestamp check_out_time
        varchar status "PRESENT, LATE, HALF_DAY, ABSENT"
        varchar entry_type "AUTO_GEOFENCE, MANUAL_OVERRIDE"
        boolean is_mock_location
    }

    FCM_DEVICE_TOKENS {
        bigint id PK
        bigint user_id FK
        varchar fcm_token
        varchar device_type "ANDROID, IOS"
        timestamp updated_at
    }
```

*Unique Constraint Note*: `ATTENDANCE_LOGS` enforces `uk_maid_household_date_shift (maid_id, household_id, log_date, shift_id)` to guarantee duplicate records are impossible under network retry storms.

---

## 7. Zero-Cost ($0) Production Cloud Deployment Strategy

Sahayika is engineered to run at **$0 infrastructure hosting cost** for residential communities and public pilots:

| Component | Platform / Service | Free Tier Allocation | Capability & Setup |
| :--- | :--- | :--- | :--- |
| **Web Service / Backend** | **Render Cloud (Docker Web Service)** | 512 MB RAM, 0.1 CPU | Multi-stage Docker build (Eclipse Temurin 17 JRE Alpine), 350MB heap limit (`-Xmx350m`). Zero-downtime auto-deploy on git push. |
| **Synthetic Uptime Monitor** | **UptimeRobot** | Free (50 monitors, 5-min intervals) | Pings `https://domestic-maid-attendance-backend.onrender.com/health` every 5 minutes to eliminate Render cold-start latency ($0). |
| **Relational Database**| **Aiven.io / TiDB Cloud / Render DB** | 1 GB Free Tier with SSL encryption | Accommodates over 1.5 million attendance log rows with foreign key integrity. |
| **Push Notifications** | **Firebase Cloud Messaging (FCM)** | Unlimited Free Tier | Sub-second push delivery across all Android and iOS devices. |
| **Mapping Engine** | **OpenStreetMap & Leaflet** | Open-Source / 100% Free | Zero Google Maps API billing or credit card requirements. |
| **Mobile App Dist** | **GitHub Releases / Direct APK** | Free Unlimited Downloads | Instant distribution without mandatory developer account during pilot phase. |
| **Monthly OpEx** | **Total Operating Expense** | **₹0 / Month ($0.00)** | Fully sustainable for community RWAs, municipal bodies, and welfare NGOs. |

---

## 8. Summary of Fallback Mechanisms & Security Guardrails

| Edge Scenario | System Response & Mitigation |
| :--- | :--- |
| **Feature / Keypad Phone** | Employer utilizes **Manual Override** (`entry_type = 'MANUAL_OVERRIDE'`) with reason logging (e.g. *“कीपैड फोन / साधारण फोन”*). |
| **Phone Forgotten at Home** | Householder marks attendance via 1-tap manual override from their dashboard; prevents helper loss of pay. |
| **GPS Drift / Rainy Weather** | Dwell-time buffer (3 minutes) tolerates momentary GPS drift without interrupting valid sessions. |
| **Fake GPS App Installed** | Hardware `isFromMockProvider()` check detects spoofing and backend strictly throws `GeofenceValidationException` (HTTP 400). |
| **Elevator Cellular Blackout** | Local encrypted Hive storage buffers attendance and syncs automatically within 10 seconds of reconnecting. |
| **IDOR Tampering Attempt** | JWT token ownership verified against requested maid/household resource; unauthorized requests return HTTP 403 Forbidden. |
| **Mid-Month Future Date Penalty** | Future dates in current month are filtered out; only elapsed working days incur absence penalties. |
| **Double Check-Out Tap** | Check-out endpoint is idempotent; multiple calls return existing valid checkout time without inflating hours. |
| **Employer Auto Check-In Bug** | Mobile client restricts geofence triggers to `MAID` role only; employer devices never generate ghost logs. |

---

## 9. Test Suite Verification & Quality Assurance Audit

The platform has completed end-to-end automated testing across all layers:

| Layer | Framework | Test Count | Status | Description |
| :--- | :--- | :--- | :--- | :--- |
| **Backend Integration** | JUnit 5 + MockMvc | 18 Tests | **100% Passed** | Geofence validation, mid-month reports, multi-shift setup, IDOR security, and check-in idempotency. |
| **Mobile Client** | Flutter Test / BLoC | 38 Tests | **100% Passed** | Clean architecture use cases, BLoCs (Auth, Attendance, Salary), UX4G widgets, and offline Hive sync. |
| **Static Code Analysis** | Flutter Analyze / Maven | 0 Issues | **Clean** | Zero lint errors, strict null safety, GIGW 3.0 accessibility compliance. |
| **Total Test Suite** | Full-Stack End-to-End | **56 Tests** | **All Passed** | Verified production-ready for live pilot deployment. |

---

## 10. Conclusion & Next Steps

**Sahayika (सहायिका)** bridges the trust gap between urban families and domestic workers through automated technology, ethical privacy guardrails, and transparent payroll calculations. 

With all **56 tests verified**, security vulnerabilities patched, UX4G compliance established, clean zero-touch pipelines implemented, and 24/7 cloud availability secured with zero operational costs, the platform is ready for pilot deployment in target residential communities.
