-- =============================================
-- FILE: run_all.sql
-- PURPOSE: Run complete setup at once
-- =============================================

-- Run this file to set up everything at once

SOURCE 01_create_database.sql;
SOURCE 02_create_tables.sql;
SOURCE 03_insert_sample_data.sql;
SOURCE 04_views_and_queries.sql;

SELECT '=========================================' AS '';
SELECT 'COMPLETE DATABASE SETUP FINISHED!' AS Status;
SELECT '=========================================' AS '';
SELECT 'Your database is ready to use!' AS Message;
SELECT '=========================================' AS '';