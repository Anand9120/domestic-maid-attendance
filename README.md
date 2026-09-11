# Domestic Maid Attendance Tracking System

> **PRD v3.0 Implementation** • Flutter Clean Architecture (BLoC) • Spring Boot 3.x Layered Architecture • $0 Cloud Hosting Blueprint

---

## Architecture Overview

### 1. Spring Boot Backend (`backend/`)
- **Layered Architecture**: Controller Layer, Service Layer, Repository Layer, Entity & DTO Layer.
- **Geofence Engine**: Haversine formula calculation enforcing a **50-meter household boundary**.
- **Pass-By & Dwell Validator**: 3-minute (180s) minimum presence requirement before check-in logging.
- **Anti-Spoofing**: Mock location / Fake GPS app detection (`is_mock_location`).
- **Real-Time Push Notifications**: Firebase Cloud Messaging (FCM) dispatch to employers within 3 seconds.
- **Security**: Spring Security + Stateless JWT Token authentication.
- **Dual Profile Persistence**:
  - `dev` (Active default): Embedded H2 database with MySQL compatibility mode for instant local testing.
  - `prod`: MySQL 8.0 connection string (compatible with TiDB Cloud, Aiven.io, or Oracle Cloud Always Free VM).

### 2. Flutter Mobile Application (`mobile/`)
- **Clean Architecture**: Domain (Entities & UseCases), Data (Models, Local Hive DB, Remote Dio REST), Presentation (BLoC, Pages, Widgets).
- **Offline Event Queueing (Hive DB)**: When network connectivity is lost, arrival events are buffered locally with unaltered device timestamps and auto-synced upon reconnect.
- **Visual Monthly Attendance Ledger**: Color-coded calendar days (Present, Late, Half-Day, Absent), working days aggregation, and calculated salary deductions.
- **Manual Employer Override**: Modal allowing employers to manually mark presence for feature keypad phone users or forgotten devices.

---

## Directory Structure

```
domestic-maid-attendance/
├── backend/
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/app/maidattendance/
│       │   │   ├── MaidAttendanceApplication.java
│       │   │   ├── config/             # Security, Firebase, Swagger
│       │   │   ├── controller/         # Auth, Attendance, Household, Reports
│       │   │   ├── dto/                # Request & Response DTOs
│       │   │   ├── entity/             # JPA Entities (Users, Locations, Shifts, Logs)
│       │   │   ├── exception/          # GlobalExceptionHandler & Custom Exceptions
│       │   │   ├── repository/         # Spring Data JPA with JPQL queries
│       │   │   ├── security/           # JWT Provider & Auth Filters
│       │   │   └── service/            # Business Logic & Implementations
│       │   └── resources/
│       │       ├── application.yml
│       │       ├── schema.sql          # MySQL 8.0 DDL Execution Script
│       │       └── data.sql            # Seed demo data
│       └── test/                       # Unit & Integration tests
└── mobile/
    ├── pubspec.yaml
    ├── lib/
    │   ├── main.dart
    │   ├── app.dart
    │   ├── core/                       # Network, Geofence, Theme, Utils
    │   └── features/
    │       ├── auth/                   # Phone OTP Auth & BLoC
    │       ├── attendance/             # Check-in, Hive buffer, Ledger, BLoC
    │       └── household/              # Geofence boundary setup
    └── test/                           # BLoC and unit tests
```

---

## Quick Start Guide

### 1. Run Backend (Spring Boot 3.x)

```bash
cd backend
mvn spring-boot:run
```
- The backend will start on `http://localhost:8080`.
- Interactive Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI Specification: `http://localhost:8080/api-docs`
- H2 Console: `http://localhost:8080/h2-console` (JDBC URL: `jdbc:h2:mem:maidattendance`)

### 2. Run Mobile Client (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

---

## Preloaded Demo Accounts & Test Credentials

- **Employer**: Phone `+919876543210` (Name: *Priya Sharma*)
- **Maid 1**: Phone `+919811122233` (Name: *Sunita Devi*)
- **Maid 2**: Phone `+919844455566` (Name: *Anita Kumari*)
- **Default OTP**: `123456`
- **Household Geofence**: Sharma Residence (`28.6315° N, 77.2167° E`), 50m radius, 3-minute dwell time.
