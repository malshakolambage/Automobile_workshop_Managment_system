

CREATE DATABASE IF NOT EXISTS autonex CHARACTER SET utf8mb4;
USE autonex;

-- ---------------------------------------------------------
-- USERS (customers who use the Flutter app, and workshop staff/admin)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(20),
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('customer','admin') NOT NULL DEFAULT 'customer',
  profile_image LONGTEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------
-- WORKSHOP PROFILE (single row settings, shown on admin dashboard sidebar + invoices)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS workshop_profile (
  id INT PRIMARY KEY DEFAULT 1,
  name VARCHAR(120) DEFAULT 'AutoNex Workshop',
  phone VARCHAR(20),
  email VARCHAR(150),
  location VARCHAR(255),
  image LONGTEXT,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT IGNORE INTO workshop_profile (id, name) VALUES (1, 'AutoNex Workshop');

-- ---------------------------------------------------------
-- VEHICLES (belongs to a customer)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS vehicles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  model VARCHAR(120) NOT NULL,        -- e.g. "Toyota Prius"
  plate_number VARCHAR(30) NOT NULL,
  status VARCHAR(50) DEFAULT 'Queued', -- Queued, 1st Checking, In Progress, Oil Changing, Washing, Final Check, Ready
  description TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- APPOINTMENTS / BOOKINGS
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  vehicle_id INT,
  service_type VARCHAR(120) NOT NULL,
  appointment_date DATE NOT NULL,
  appointment_time VARCHAR(20),
  notes TEXT,
  status ENUM('Pending','Approved','Rejected','Completed','Cancelled') DEFAULT 'Pending',
  progress VARCHAR(50) DEFAULT 'Awaiting Approval',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL
);

-- ---------------------------------------------------------
-- FEEDBACK
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS feedback (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  vehicle_id INT,
  appointment_id INT,
  rating TINYINT NOT NULL,
  comment TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL,
  FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE SET NULL
);

-- ---------------------------------------------------------
-- NOTIFICATIONS
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(150) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) DEFAULT 'info', -- info, success, warning, danger
  is_read TINYINT(1) DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- CHAT MESSAGES (customer <-> workshop)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,           -- the customer this conversation belongs to
  sender ENUM('customer','workshop') NOT NULL,
  message TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- INVOICES / BILLING
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS invoices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  appointment_id INT,
  customer_name VARCHAR(120),
  vehicle_no VARCHAR(30),
  items JSON NOT NULL,          -- [{ "description": "Oil Change", "amount": 3500 }, ...]
  total DECIMAL(10,2) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE SET NULL
);

-- ---------------------------------------------------------
-- Seed an admin user (password: admin123 -- change after first login)
-- Hash generated with bcrypt, see routes/auth.js "seed" note.
-- ---------------------------------------------------------
-- INSERT INTO users (name, email, password_hash, role) VALUES
-- ('Workshop Admin', 'admin@autonex.lk', '<bcrypt-hash>', 'admin');
