CREATE DATABASE IF NOT EXISTS college_bus_db;
USE college_bus_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'driver', 'student') NOT NULL,
    full_name VARCHAR(150) NULL,
    roll_number VARCHAR(50) NULL,
    department VARCHAR(120) NULL,
    contact_number VARCHAR(30) NULL,
    student_stop VARCHAR(150) NULL,
    is_blocked TINYINT(1) NOT NULL DEFAULT 0,
    transport_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_users_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS routes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL,
    start_time TIME NULL,
    end_time TIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_routes_route_name (route_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS buses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(50) NOT NULL,
    status ENUM('active', 'inactive', 'maintenance') NOT NULL DEFAULT 'inactive',
    current_lat DECIMAL(10, 8) NULL,
    current_lng DECIMAL(11, 8) NULL,
    speed DECIMAL(6, 2) NULL DEFAULT 0.00,
    route_id INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_buses_bus_number (bus_number),
    KEY idx_buses_status (status),
    KEY idx_buses_route_id (route_id),
    CONSTRAINT fk_buses_route
        FOREIGN KEY (route_id) REFERENCES routes(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS drivers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(30) NULL,
    bus_id INT NULL,
    monthly_salary DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_drivers_name (name),
    UNIQUE KEY uk_drivers_bus_id (bus_id),
    CONSTRAINT fk_drivers_bus
        FOREIGN KEY (bus_id) REFERENCES buses(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS driver_route_assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT NOT NULL,
    route_id INT NOT NULL,
    assignment_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_driver_assignment_day (driver_id, assignment_date),
    KEY idx_assignment_route_date (route_id, assignment_date),
    CONSTRAINT fk_assignment_driver
        FOREIGN KEY (driver_id) REFERENCES drivers(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_assignment_route
        FOREIGN KEY (route_id) REFERENCES routes(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS bus_stops (
    id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT NOT NULL,
    stop_name VARCHAR(150) NOT NULL,
    lat DECIMAL(10, 8) NOT NULL,
    lng DECIMAL(11, 8) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_bus_stops_route_id (route_id),
    CONSTRAINT fk_bus_stops_route
        FOREIGN KEY (route_id) REFERENCES routes(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_alerts_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS smart_stop_alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(100) NOT NULL,
    route_id INT NOT NULL,
    stop_id INT NOT NULL,
    bus_id INT NULL,
    driver_id INT NULL,
    student_lat DECIMAL(10, 8) NOT NULL,
    student_lng DECIMAL(11, 8) NOT NULL,
    distance_m DECIMAL(8, 2) NOT NULL,
    status ENUM('active', 'acknowledged', 'expired') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    acknowledged_at DATETIME NULL,
    KEY idx_smart_stop_alerts_route_status (route_id, status, expires_at),
    KEY idx_smart_stop_alerts_driver_status (driver_id, status, expires_at),
    KEY idx_smart_stop_alerts_bus_status (bus_id, status, expires_at),
    KEY idx_smart_stop_alerts_student_stop (student_id, stop_id, status, expires_at),
    CONSTRAINT fk_smart_stop_alerts_route
        FOREIGN KEY (route_id) REFERENCES routes(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_smart_stop_alerts_stop
        FOREIGN KEY (stop_id) REFERENCES bus_stops(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_smart_stop_alerts_bus
        FOREIGN KEY (bus_id) REFERENCES buses(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_smart_stop_alerts_driver
        FOREIGN KEY (driver_id) REFERENCES drivers(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS usage_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(100) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    lat DECIMAL(10, 8) NULL,
    lng DECIMAL(11, 8) NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_usage_logs_student_time (student_id, timestamp),
    KEY idx_usage_logs_action_time (action_type, timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS student_favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    value VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_student_favorite (student_id, type, value),
    KEY idx_student_favorites_student_type (student_id, type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS student_fee_payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(100) NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    remarks VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_student_fee_payments_student_date (student_id, payment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS staff_salary_payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT NOT NULL,
    salary_month DATE NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL,
    paid_date DATE NOT NULL,
    remarks VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_staff_salary_payments_driver_month (driver_id, salary_month),
    CONSTRAINT fk_staff_salary_payments_driver
        FOREIGN KEY (driver_id) REFERENCES drivers(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO users (username, password, role, full_name, roll_number, department, contact_number, student_stop, is_blocked, transport_fee)
VALUES
    ('admin', 'admin123', 'admin', NULL, NULL, NULL, NULL, NULL, 0, 0.00),
    ('driver1', 'driver123', 'driver', NULL, NULL, NULL, NULL, NULL, 0, 0.00),
    ('student1', 'student123', 'student', 'Student One', 'S1001', 'CSE', '9876500001', 'College Gate', 0, 12000.00)
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    role = VALUES(role),
    full_name = VALUES(full_name),
    roll_number = VALUES(roll_number),
    department = VALUES(department),
    contact_number = VALUES(contact_number),
    student_stop = VALUES(student_stop),
    is_blocked = VALUES(is_blocked),
    transport_fee = VALUES(transport_fee);

INSERT INTO routes (id, route_name, start_time, end_time)
VALUES
    (1, 'Route A', '07:30:00', '09:00:00')
ON DUPLICATE KEY UPDATE
    route_name = VALUES(route_name),
    start_time = VALUES(start_time),
    end_time = VALUES(end_time);

INSERT INTO buses (id, bus_number, status, current_lat, current_lng, speed, route_id)
VALUES
    (1, 'BUS-101', 'active', 11.01680000, 76.95580000, 0.00, 1)
ON DUPLICATE KEY UPDATE
    bus_number = VALUES(bus_number),
    status = VALUES(status),
    current_lat = VALUES(current_lat),
    current_lng = VALUES(current_lng),
    speed = VALUES(speed),
    route_id = VALUES(route_id);

INSERT INTO drivers (id, name, contact, bus_id, monthly_salary)
VALUES
    (1, 'driver1', '9876543210', 1, 18000.00)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    contact = VALUES(contact),
    bus_id = VALUES(bus_id),
    monthly_salary = VALUES(monthly_salary);

INSERT INTO driver_route_assignments (driver_id, route_id, assignment_date)
VALUES
    (1, 1, CURDATE())
ON DUPLICATE KEY UPDATE
    route_id = VALUES(route_id);

INSERT INTO bus_stops (route_id, stop_name, lat, lng)
SELECT 1, 'College Gate', 11.01720000, 76.95610000
WHERE NOT EXISTS (
    SELECT 1
    FROM bus_stops
    WHERE route_id = 1 AND stop_name = 'College Gate'
);

INSERT INTO alerts (message)
SELECT 'System initialized.'
WHERE NOT EXISTS (
    SELECT 1
    FROM alerts
    WHERE message = 'System initialized.'
);
