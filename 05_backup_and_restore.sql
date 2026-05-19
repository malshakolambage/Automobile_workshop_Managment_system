-- =============================================
-- FILE: 05_backup_and_restore.sql
-- PURPOSE: Backup and restore utilities
-- =============================================

USE workshop_db;

-- Create backup table for customers
CREATE TABLE IF NOT EXISTS customers_backup LIKE customers;

-- Backup customers data
INSERT INTO customers_backup SELECT * FROM customers;

-- Create backup table for vehicles
CREATE TABLE IF NOT EXISTS vehicles_backup LIKE vehicles;
INSERT INTO vehicles_backup SELECT * FROM vehicles;

-- Show backup counts
SELECT 'customers_backup' as BackupTable, COUNT(*) as Records FROM customers_backup
UNION ALL
SELECT 'vehicles_backup', COUNT(*) FROM vehicles_backup;

-- Procedure to restore customers from backup
DELIMITER //
CREATE PROCEDURE restore_customers()
BEGIN
    DELETE FROM customers;
    INSERT INTO customers SELECT * FROM customers_backup;
    SELECT 'Customers restored from backup' as Message;
END //
DELIMITER ;

-- Procedure to get database statistics
DELIMITER //
CREATE PROCEDURE get_db_stats()
BEGIN
    SELECT 'Total Customers' as Metric, COUNT(*) as Value FROM customers
    UNION ALL
    SELECT 'Total Vehicles', COUNT(*) FROM vehicles
    UNION ALL
    SELECT 'Total Appointments', COUNT(*) FROM appointments
    UNION ALL
    SELECT 'Total Users', COUNT(*) FROM users
    UNION ALL
    SELECT 'Total Invoices', COUNT(*) FROM invoices;
END //
DELIMITER ;

-- Run statistics
CALL get_db_stats();