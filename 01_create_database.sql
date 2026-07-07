-- =============================================
-- FILE: 01_create_database.sql
-- PURPOSE: Create the database (RUN THIS FIRST)
-- =============================================

-- Drop existing database if it exists
DROP DATABASE IF EXISTS workshop_db;

-- Create new database
CREATE DATABASE workshop_db;

-- Select the database
USE workshop_db;

-- Show confirmation
SELECT 'Database workshop_db created successfully!' AS Status;