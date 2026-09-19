-- ==============================================================================
-- Domestic Maid Attendance Tracking System - Seed Data
-- Multi-Household Society Configuration (Green Park Heights Society)
-- ==============================================================================

-- 1. Users (3 Employers, 2 Maids)
INSERT INTO users (id, full_name, phone_number, role, emergency_contact, services_offered, upi_id, is_active)
VALUES 
(1, 'Priya Sharma (Employer)', '+919876543210', 'EMPLOYER', '+919876543211', NULL, 'priya@upi', TRUE),
(2, 'Sunita Devi (Maid)', '+919811122233', 'MAID', '+919811122200', 'COOKING,CLEANING,DISHES', 'sunita@okhdfcbank', TRUE),
(3, 'Anita Kumari (Maid)', '+919844455566', 'MAID', '+919844455500', 'ALL_ROUNDER', 'anita@paytm', TRUE),
(4, 'Rajesh Verma (Employer)', '+919876543220', 'EMPLOYER', '+919876543221', NULL, 'verma@upi', TRUE),
(5, 'Amit Kapoor (Employer)', '+919876543230', 'EMPLOYER', '+919876543231', NULL, 'amit@icici', TRUE);

-- 2. Household Locations in Green Park Heights Society
-- Household 1: Flat 402 (Sharma Residence)
INSERT INTO household_locations (id, employer_id, house_name, address, latitude, longitude, geofence_radius_meters, dwell_time_minutes, invite_code, monthly_salary, allowed_leaves)
VALUES 
(1, 1, 'Sharma Residence - Flat 402', 'B-Block, Green Park Heights, New Delhi', 28.63150000, 77.21670000, 50, 3, 'SHARMA402', 5000.00, 2);

-- Household 2: Flat 105 (Verma Residence) - ~110m northeast of Flat 402
INSERT INTO household_locations (id, employer_id, house_name, address, latitude, longitude, geofence_radius_meters, dwell_time_minutes, invite_code, monthly_salary, allowed_leaves)
VALUES 
(2, 4, 'Verma Residence - Flat 105', 'A-Block, Green Park Heights, New Delhi', 28.63220000, 77.21750000, 45, 3, 'VERMA105', 4500.00, 2);

-- Household 3: Flat 204 (Kapoor Residence) - ~115m southwest of Flat 402
INSERT INTO household_locations (id, employer_id, house_name, address, latitude, longitude, geofence_radius_meters, dwell_time_minutes, invite_code, monthly_salary, allowed_leaves)
VALUES 
(3, 5, 'Kapoor Residence - Flat 204', 'C-Block, Green Park Heights, New Delhi', 28.63080000, 77.21590000, 50, 3, 'KAPOOR204', 4000.00, 2);

-- 3. Shift Schedules
-- Flat 402: 07:30 - 09:30 & 18:00 - 20:00
INSERT INTO shift_schedules (id, household_id, shift_name, start_time, end_time, grace_period_minutes)
VALUES 
(1, 1, 'Morning Cleaning & Cooking', '07:30:00', '09:30:00', 15),
(2, 1, 'Evening Dinner & Dishes', '18:00:00', '20:00:00', 15),
-- Flat 105: 10:00 - 12:00
(3, 2, 'Late Morning Cleaning & Dusting', '10:00:00', '12:00:00', 15),
-- Flat 204: 16:30 - 18:00
(4, 3, 'Evening Dinner Prep', '16:30:00', '18:00:00', 15);

-- 4. Multi-Household Assignments for Sunita Devi (Maid id=2 works across Flat 402, Flat 105, Flat 204)
INSERT INTO maid_household_assignments (id, maid_id, household_id, status)
VALUES 
(1, 2, 1, 'ACTIVE'),
(2, 3, 1, 'ACTIVE'),
(3, 2, 2, 'ACTIVE'),
(4, 2, 3, 'ACTIVE');

-- 5. FCM Device Token for Employer
INSERT INTO fcm_device_tokens (id, user_id, fcm_token, device_type)
VALUES 
(1, 1, 'mock_employer_fcm_token_xyz123', 'ANDROID');

-- 6. Initial Seed Notifications (Activity Timeline Demonstration)
INSERT INTO notification_logs (id, user_id, household_id, title, body, type, is_read, created_at)
VALUES
(1, 2, 1, 'Auto-Switched to Sharma Residence (Flat 402)', 'Continuous GPS locked proximity to Flat 402 (18m away). Geofence boundary active.', 'AUTO_SWITCH', FALSE, DATEADD('SECOND', -1800, CURRENT_TIMESTAMP)),
(2, 2, 1, 'Arrival Verified: Flat 402', 'Checked into Sharma Residence at 07:35 AM (ON_TIME). 3-minute dwell verified.', 'CHECK_IN', FALSE, DATEADD('SECOND', -1620, CURRENT_TIMESTAMP)),
(3, 1, 1, 'Maid Arrived: Sunita Devi', 'Sunita Devi arrived at Sharma Residence - Flat 402 at 07:35 AM (ON_TIME)', 'CHECK_IN', FALSE, DATEADD('SECOND', -1620, CURRENT_TIMESTAMP)),
(4, 2, 1, 'Shift Completed: Flat 402', 'Automated departure logged at 09:31 AM. Work duration: 1h 56m recorded.', 'CHECK_OUT', FALSE, DATEADD('SECOND', -600, CURRENT_TIMESTAMP)),
(5, 2, 2, 'Approaching Verma Residence (Flat 105)', 'Distance: 38m. Prepare for automated 3-minute dwell verification.', 'GEOFENCE_ENTER', FALSE, DATEADD('SECOND', -300, CURRENT_TIMESTAMP));

