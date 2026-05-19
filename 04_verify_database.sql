-- =============================================
-- FILE: 04_views_and_queries.sql
-- PURPOSE: Create useful views and queries (RUN FOURTH)
-- =============================================

USE workshop_db;

-- View: Vehicles with owner names
CREATE OR REPLACE VIEW vehicle_details AS
SELECT 
    v.id,
    v.registration_no,
    v.model,
    v.make,
    v.service_status,
    v.service_notes,
    c.name as owner_name,
    c.phone as owner_phone,
    c.email as owner_email
FROM vehicles v
LEFT JOIN customers c ON v.customer_id = c.id;

-- View: Appointments with customer and vehicle details
CREATE OR REPLACE VIEW appointment_details AS
SELECT 
    a.id,
    a.appointment_date,
    a.appointment_time,
    a.status,
    c.name as customer_name,
    c.phone as customer_phone,
    v.registration_no,
    v.model,
    v.make
FROM appointments a
LEFT JOIN customers c ON a.customer_id = c.id
LEFT JOIN vehicles v ON a.vehicle_id = v.id;

-- View: Today's appointments
CREATE OR REPLACE VIEW today_appointments AS
SELECT * FROM appointment_details 
WHERE appointment_date = CURDATE();

-- View: Vehicle status summary
CREATE OR REPLACE VIEW vehicle_status_summary AS
SELECT 
    service_status,
    COUNT(*) as count,
    GROUP_CONCAT(registration_no) as vehicles
FROM vehicles
GROUP BY service_status;

-- Useful queries

-- Get all vehicles with owner names
SELECT * FROM vehicle_details;

-- Get today's appointments
SELECT * FROM today_appointments;

-- Get vehicle status summary
SELECT * FROM vehicle_status_summary;

-- Get pending appointments
SELECT * FROM appointment_details 
WHERE status = 'pending' 
ORDER BY appointment_date;

-- Get vehicles by status
SELECT service_status, COUNT(*) as count 
FROM vehicles 
GROUP BY service_status;

-- Get customer service history
SELECT 
    c.name,
    v.registration_no,
    v.service_status,
    v.service_notes,
    v.created_at as last_updated
FROM customers c
JOIN vehicles v ON c.id = v.customer_id
ORDER BY c.name;