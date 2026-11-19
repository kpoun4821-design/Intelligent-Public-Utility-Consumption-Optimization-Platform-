-- =====================================================================
-- Intelligent Public Utility Consumption Optimization Platform (IPUCOP)
-- MySQL Sample Seed Data Insert Script
-- =====================================================================

USE `ipucop_db`;

-- Roles
INSERT IGNORE INTO `roles` (`id`, `name`) VALUES 
(1, 'ROLE_ADMIN'),
(2, 'ROLE_USER');

-- Buildings
INSERT IGNORE INTO `buildings` (`id`, `name`, `code`, `address`, `total_area_sq_ft`) VALUES 
(1, 'Block A (Main Academic)', 'BLK-A', 'Sector 4, North Campus', 45000.0),
(2, 'Block B (Science & Labs)', 'BLK-B', 'Sector 4, East Campus', 38000.0),
(3, 'Block C (Administrative)', 'BLK-C', 'Sector 4, Central Campus', 25000.0);

-- Departments
INSERT IGNORE INTO `departments` (`id`, `name`, `code`, `building_id`) VALUES 
(1, 'Computer Science & Engineering', 'CSE', 1),
(2, 'Electrical & Electronics', 'EEE', 2),
(3, 'Facility Management & Admin', 'ADM', 3);

-- Default Passwords: Admin@123 and User@123 (BCrypt hash)
INSERT IGNORE INTO `users` (`id`, `name`, `email`, `password`, `phone`, `role_id`, `building_id`, `department_id`, `active`) VALUES 
(1, 'System Administrator', 'admin@ipucop.com', '$2a$10$w09Zz1B89hI3Q5cKqM7pZ.X4uI7e1Z/GjL9T8e/e/O5v.aA8w.B6e', '+1 (555) 019-9283', 1, 1, 3, 1),
(2, 'Prof. Alan Turing', 'user@ipucop.com', '$2a$10$tZ2iHk1VqT2oVpB2lZ5PveXg6F3Ue6F2zX1c0e3L6K8n.mY2z.D4e', '+1 (555) 018-4421', 2, 1, 1, 1);

-- Utilities (Electricity, Water, Gas)
INSERT IGNORE INTO `utilities` (`id`, `name`, `unit`, `unit_rate`, `icon`, `color`, `default_daily_baseline`) VALUES 
(1, 'ELECTRICITY', 'kWh', 0.15, 'bolt', '#f59e0b', 120.0),
(2, 'WATER', 'Liters', 0.005, 'droplet', '#3b82f6', 1800.0),
(3, 'GAS', 'm³', 0.85, 'flame', '#ef4444', 25.0);

-- IoT Sensor Devices
INSERT IGNORE INTO `devices` (`id`, `device_code`, `name`, `utility_id`, `building_id`, `department_id`, `status`) VALUES 
(1, 'ELEC-MTR-BLK-A01', 'Block A Main Power Meter', 1, 1, 1, 'ONLINE'),
(2, 'WTR-MTR-BLK-A01', 'Block A Main Water Inflow Sensor', 2, 1, 1, 'ONLINE'),
(3, 'GAS-MTR-BLK-A01', 'Block A Boiler Gas Flow Meter', 3, 1, 1, 'ONLINE'),
(4, 'ELEC-MTR-BLK-B01', 'Block B Labs Sub-meter', 1, 2, 2, 'ONLINE');

-- Recommendations
INSERT IGNORE INTO `recommendations` (`id`, `utility_id`, `building_id`, `title`, `description`, `category`, `priority`, `potential_savings_percent`, `potential_savings_amount`, `is_applied`) VALUES 
(1, 1, 1, 'Shift Non-Essential Electricity Usage to Off-Peak Hours', 'Electricity consumption spikes heavily during peak window (12:00 PM – 5:00 PM). Schedule heavy pump and lab usage after 7:00 PM to save on tariff surcharges.', 'PEAK_SHIFTING', 'HIGH', 18.5, 240.0, 0),
(2, 2, 1, 'Water Consumption Higher Than Normal: Check for Leakage', 'Recent water flow analysis detected continuous non-zero flow overnight. Please inspect pipelines, restrooms, and storage tank valves.', 'LEAK_PREVENTION', 'HIGH', 25.0, 185.0, 0),
(3, 1, 1, 'Reduce Unnecessary AC Usage During Peak Hours', 'Cooling loads account for ~48% of total building electricity draw. Raising thermostat setpoints by 1.5°C between 1 PM and 4 PM reduces peak energy draw significantly.', 'ENERGY_EFFICIENCY', 'MEDIUM', 12.0, 160.0, 0),
(4, 1, 1, 'Switch Off Unused Electrical Equipment in Unoccupied Zones', 'Standby plug-loads in Block A after 8:00 PM are averaging 8.2 kWh. Implement automated smart power strip cutoffs in labs and offices.', 'ENERGY_EFFICIENCY', 'MEDIUM', 8.0, 95.0, 0),
(5, 1, 1, 'Current Consumption May Exceed Your Monthly Budget', 'Projected monthly consumption is pacing 18% above the configured threshold. Throttle non-critical HVAC and decorative lighting to remain within budget.', 'BUDGET_OPTIMIZATION', 'HIGH', 15.0, 310.0, 0);
