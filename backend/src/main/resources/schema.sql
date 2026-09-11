-- ==============================================================================
-- Domestic Maid Attendance Tracking System - Database Schema (MySQL 8.0)
-- Matches PRD v3.0 Section 6.1
-- ==============================================================================

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    role VARCHAR(20) NOT NULL, -- 'EMPLOYER', 'MAID', 'ADMIN'
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. HOUSEHOLD_LOCATIONS TABLE
CREATE TABLE IF NOT EXISTS household_locations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employer_id BIGINT NOT NULL,
    house_name VARCHAR(100) DEFAULT 'Home',
    address TEXT,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    geofence_radius_meters INT DEFAULT 50,
    dwell_time_minutes INT DEFAULT 3,
    CONSTRAINT fk_household_employer FOREIGN KEY (employer_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. SHIFT_SCHEDULES TABLE
CREATE TABLE IF NOT EXISTS shift_schedules (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    household_id BIGINT NOT NULL,
    shift_name VARCHAR(50) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    grace_period_minutes INT DEFAULT 15,
    CONSTRAINT fk_shift_household FOREIGN KEY (household_id) REFERENCES household_locations(id) ON DELETE CASCADE
);

-- 4. MAID_HOUSEHOLD_ASSIGNMENTS TABLE
CREATE TABLE IF NOT EXISTS maid_household_assignments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    maid_id BIGINT NOT NULL,
    household_id BIGINT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE', -- 'ACTIVE', 'INACTIVE'
    CONSTRAINT fk_assignment_maid FOREIGN KEY (maid_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_assignment_household FOREIGN KEY (household_id) REFERENCES household_locations(id) ON DELETE CASCADE,
    CONSTRAINT uq_maid_household UNIQUE (maid_id, household_id)
);

-- 5. ATTENDANCE_LOGS TABLE
CREATE TABLE IF NOT EXISTS attendance_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    maid_id BIGINT NOT NULL,
    household_id BIGINT NOT NULL,
    shift_id BIGINT NULL,
    attendance_date DATE NOT NULL,
    check_in_time TIME NULL,
    check_out_time TIME NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PRESENT', -- 'PRESENT', 'ABSENT', 'LATE', 'HALF_DAY'
    entry_type VARCHAR(30) NOT NULL DEFAULT 'AUTOMATED_GEOFENCE', -- 'AUTOMATED_GEOFENCE', 'OFFLINE_SYNC', 'MANUAL_OVERRIDE'
    device_timestamp TIMESTAMP NOT NULL,
    server_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_mock_location BOOLEAN DEFAULT FALSE,
    override_by_employer_id BIGINT NULL,
    CONSTRAINT fk_log_maid FOREIGN KEY (maid_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_log_household FOREIGN KEY (household_id) REFERENCES household_locations(id) ON DELETE CASCADE,
    CONSTRAINT fk_log_override FOREIGN KEY (override_by_employer_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 6. FCM_DEVICE_TOKENS TABLE
CREATE TABLE IF NOT EXISTS fcm_device_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    fcm_token VARCHAR(255) NOT NULL UNIQUE,
    device_type VARCHAR(20) DEFAULT 'ANDROID', -- 'ANDROID', 'IOS', 'WEB'
    CONSTRAINT fk_fcm_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_attendance_maid_date ON attendance_logs(maid_id, attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_household_date ON attendance_logs(household_id, attendance_date);
