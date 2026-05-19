-- =============================================
-- FILE: 03_insert_sample_data.sql
-- PURPOSE: Insert sample data (RUN THIRD)
-- =============================================

USE workshop_db;

-- Insert customers
INSERT INTO customers (name, email, phone, address, vehicle_no) VALUES 
('Saman Perera', 'saman@gmail.com', '0771234567', 'No 123, Main Street, Colombo', 'ABC-1234'),
('Nimal Silva', 'nimal@gmail.com', '0777654321', 'No 45, Kandy Road, Kandy', 'XYZ-5678'),
('Kamal Jayasuriya', 'kamal@gmail.com', '0781234567', 'No 78, Galle Road, Galle', 'DEF-9012'),
('Amara Vidanage', 'amara@gmail.com', '0761234567', 'No 234, Negombo Road, Negombo', 'GHI-3456'),
('Ruwan Wijesinghe', 'ruwan@gmail.com', '0779876543', 'No 567, Galle Road, Colombo 03', 'JKL-7890');

-- Insert vehicles
INSERT INTO vehicles (customer_id, registration_no, model, make, service_status, service_notes) VALUES 
(1, 'ABC-1234', 'Camry', 'Toyota', 'In Progress', 'Oil change and tune-up in progress'),
(1, 'ABC-5678', 'Vitz', 'Toyota', 'Queued', 'Waiting for service'),
(2, 'XYZ-5678', 'Civic', 'Honda', 'Ready', 'Ready for pickup'),
(3, 'DEF-9012', 'Swift', 'Suzuki', '1st Checking', 'Initial inspection complete'),
(4, 'GHI-3456', 'Corolla', 'Toyota', 'Oil Changing', 'Oil change in progress'),
(5, 'JKL-7890', 'X5', 'BMW', 'Washing', 'Being washed and detailed');

-- Insert appointments
INSERT INTO appointments (customer_id, vehicle_id, appointment_date, appointment_time, status) VALUES 
(1, 1, CURDATE(), '09:00:00', 'confirmed'),
(1, 2, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '11:00:00', 'pending'),
(2, 3, CURDATE(), '10:30:00', 'confirmed'),
(3, 4, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '14:00:00', 'pending'),
(4, 5, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:30:00', 'confirmed'),
(5, 6, DATE_ADD(CURDATE(), INTERVAL 3 DAY), '13:00:00', 'pending');

-- Insert users (admin and staff)
INSERT INTO users (username, email, password_hash, full_name, role, phone) VALUES 
('admin', 'admin@workshop.com', 'admin123', 'System Administrator', 'admin', '0771234567'),
('manager1', 'manager@workshop.com', 'manager123', 'John Manager', 'manager', '0771234568'),
('mechanic1', 'mechanic@workshop.com', 'mechanic123', 'Mike Mechanic', 'mechanic', '0771234569'),
('staff1', 'staff@workshop.com', 'staff123', 'Sarah Staff', 'staff', '0771234570');

-- Insert invoices
INSERT INTO invoices (invoice_no, customer_id, total_amount, payment_status) VALUES 
('INV-2026001', 1, 5750.00, 'paid'),
('INV-2026002', 2, 4025.00, 'pending'),
('INV-2026003', 3, 8125.00, 'pending'),
('INV-2026004', 4, 3500.00, 'paid');

-- Show inserted data
SELECT '=== DATA INSERTION COMPLETE ===' AS Status;
SELECT COUNT(*) as TotalCustomers FROM customers;
SELECT COUNT(*) as TotalVehicles FROM vehicles;
SELECT COUNT(*) as TotalAppointments FROM appointments;
SELECT COUNT(*) as TotalUsers FROM users;
SELECT COUNT(*) as TotalInvoices FROM invoices;