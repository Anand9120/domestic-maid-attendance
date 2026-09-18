-- ==============================================================================
-- Domestic Maid Attendance Tracking System - Seed Data
-- ==============================================================================

-- 1. Users (1 Employer, 2 Maids)
INSERT INTO users (id, full_name, phone_number, role, emergency_contact, services_offered, upi_id, is_active)
VALUES 
(1, 'Priya Sharma (Employer)', '+919876543210', 'EMPLOYER', '+919876543211', NULL, 'priya@upi', TRUE),
(2, 'Sunita Devi (Maid)', '+919811122233', 'MAID', '+919811122200', 'COOKING,CLEANING', 'sunita@okhdfcbank', TRUE),
(3, 'Anita Kumari (Maid)', '+919844455566', 'MAID', '+919844455500', 'ALL_ROUNDER', 'anita@paytm', TRUE);

-- 2. Household Location (Employer Priya's apartment)
-- Coordinates: Connaught Place, New Delhi (28.6315° N, 77.2167° E)
INSERT INTO household_locations (id, employer_id, house_name, address, latitude, longitude, geofence_radius_meters, dwell_time_minutes, invite_code, monthly_salary, allowed_leaves)
VALUES 
(1, 1, 'Sharma Residence - Flat 402', 'B-Block, Green Park Heights, New Delhi', 28.63150000, 77.21670000, 50, 3, 'SHARMA402', 5000.00, 2);

-- 3. Shift Schedules for Household 1
-- Morning Shift: 07:30 - 09:30, Grace Period: 15 mins
-- Evening Shift: 18:00 - 20:00, Grace Period: 15 mins
INSERT INTO shift_schedules (id, household_id, shift_name, start_time, end_time, grace_period_minutes)
VALUES 
(1, 1, 'Morning Cleaning & Cooking', '07:30:00', '09:30:00', 15),
(2, 1, 'Evening Dinner & Dishes', '18:00:00', '20:00:00', 15);

-- 4. Maid Household Assignment
INSERT INTO maid_household_assignments (id, maid_id, household_id, status)
VALUES 
(1, 2, 1, 'ACTIVE'),
(2, 3, 1, 'ACTIVE');

-- 5. FCM Device Token for Employer (Dummy token for push notification demonstration)
INSERT INTO fcm_device_tokens (id, user_id, fcm_token, device_type)
VALUES 
(1, 1, 'mock_employer_fcm_token_xyz123', 'ANDROID');
