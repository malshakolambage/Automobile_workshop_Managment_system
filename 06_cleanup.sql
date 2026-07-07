-- =============================================
-- FILE: 06_cleanup.sql
-- PURPOSE: Clean up old data (RUN CAREFULLY)
-- =============================================

USE workshop_db;

-- Delete old completed appointments (older than 30 days)
DELETE FROM appointments 
WHERE status = 'completed' 
AND appointment_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- Delete old invoices (older than 1 year and paid)
DELETE FROM invoices 
WHERE payment_status = 'paid' 
AND created_at < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Show how many records were deleted
SELECT ROW_COUNT() as RecordsDeleted;

-- Optimize tables
OPTIMIZE TABLE customers;
OPTIMIZE TABLE vehicles;
OPTIMIZE TABLE appointments;
OPTIMIZE TABLE invoices;
OPTIMIZE TABLE users;

SELECT 'Cleanup completed successfully!' as Status;