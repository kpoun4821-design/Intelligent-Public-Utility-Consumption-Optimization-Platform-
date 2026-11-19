-- =====================================================================
-- Intelligent Public Utility Consumption Optimization Platform (IPUCOP)
-- MySQL Schema DDL Script (Compatible with MySQL 8.x and MariaDB 10.x+)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `ipucop_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `ipucop_db`;

-- 1. Roles Table
CREATE TABLE IF NOT EXISTS `roles` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 2. Buildings Table
CREATE TABLE IF NOT EXISTS `buildings` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `code` VARCHAR(50) NOT NULL UNIQUE,
    `address` VARCHAR(255),
    `total_area_sq_ft` DOUBLE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Departments Table
CREATE TABLE IF NOT EXISTS `departments` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `code` VARCHAR(50) NOT NULL,
    `building_id` BIGINT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_dept_building` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 4. Users Table
CREATE TABLE IF NOT EXISTS `users` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(20),
    `role_id` BIGINT NOT NULL,
    `building_id` BIGINT,
    `department_id` BIGINT,
    `active` BOOLEAN NOT NULL DEFAULT TRUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
    CONSTRAINT `fk_user_building` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_user_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 5. Utilities Table
CREATE TABLE IF NOT EXISTS `utilities` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `unit` VARCHAR(20) NOT NULL,
    `unit_rate` DOUBLE NOT NULL,
    `icon` VARCHAR(50),
    `color` VARCHAR(20),
    `default_daily_baseline` DOUBLE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 6. Devices / Sensors Table
CREATE TABLE IF NOT EXISTS `devices` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `device_code` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `utility_id` BIGINT NOT NULL,
    `building_id` BIGINT NOT NULL,
    `department_id` BIGINT,
    `status` VARCHAR(20) DEFAULT 'ONLINE',
    `installed_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_ping_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_device_utility` FOREIGN KEY (`utility_id`) REFERENCES `utilities` (`id`),
    CONSTRAINT `fk_device_building` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`),
    CONSTRAINT `fk_device_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 7. Consumption Records Table
CREATE TABLE IF NOT EXISTS `consumption_records` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `device_id` BIGINT,
    `utility_id` BIGINT NOT NULL,
    `building_id` BIGINT,
    `department_id` BIGINT,
    `units_consumed` DOUBLE NOT NULL,
    `cost` DOUBLE NOT NULL,
    `baseline_expected` DOUBLE,
    `is_anomaly` BOOLEAN DEFAULT FALSE,
    `anomaly_type` VARCHAR(50),
    `recorded_at` DATETIME NOT NULL,
    INDEX `idx_recorded_at` (`recorded_at`),
    INDEX `idx_utility_recorded` (`utility_id`, `recorded_at`),
    INDEX `idx_building_utility` (`building_id`, `utility_id`),
    CONSTRAINT `fk_consumption_device` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_consumption_utility` FOREIGN KEY (`utility_id`) REFERENCES `utilities` (`id`),
    CONSTRAINT `fk_consumption_building` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_consumption_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 8. Alerts Table
CREATE TABLE IF NOT EXISTS `alerts` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(150) NOT NULL,
    `description` VARCHAR(1000) NOT NULL,
    `severity` VARCHAR(20) NOT NULL,
    `alert_type` VARCHAR(50) NOT NULL,
    `utility_id` BIGINT,
    `building_id` BIGINT,
    `department_id` BIGINT,
    `recommended_action` VARCHAR(255),
    `deviation_percentage` DOUBLE,
    `is_read` BOOLEAN DEFAULT FALSE,
    `is_resolved` BOOLEAN DEFAULT FALSE,
    `triggered_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `resolved_at` DATETIME,
    INDEX `idx_alert_severity` (`severity`),
    INDEX `idx_alert_triggered` (`triggered_at`),
    CONSTRAINT `fk_alert_utility` FOREIGN KEY (`utility_id`) REFERENCES `utilities` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_alert_building` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_alert_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 9. Notifications Table
CREATE TABLE IF NOT EXISTS `notifications` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT,
    `alert_id` BIGINT,
    `channel` VARCHAR(20) NOT NULL,
    `recipient` VARCHAR(100),
    `message` VARCHAR(1000) NOT NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'DELIVERED',
    `is_read` BOOLEAN DEFAULT FALSE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_user_notification` (`user_id`, `is_read`),
    CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_notif_alert` FOREIGN KEY (`alert_id`) REFERENCES `alerts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. Budgets Table
CREATE TABLE IF NOT EXISTS `budgets` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `utility_id` BIGINT NOT NULL,
    `building_id` BIGINT,
    `department_id` BIGINT,
    `month_year` VARCHAR(7) NOT NULL,
    `budget_units` DOUBLE NOT NULL,
    `budget_amount` DOUBLE NOT NULL,
    `current_units` DOUBLE DEFAULT 0.0,
    `current_amount` DOUBLE DEFAULT 0.0,
    `alert_threshold_percent` DOUBLE DEFAULT 85.0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_budget_utility` FOREIGN KEY (`utility_id`) REFERENCES `utilities` (`id`),
    CONSTRAINT `fk_budget_building` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_budget_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 11. Recommendations Table
CREATE TABLE IF NOT EXISTS `recommendations` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `utility_id` BIGINT,
    `building_id` BIGINT,
    `title` VARCHAR(150) NOT NULL,
    `description` VARCHAR(1000) NOT NULL,
    `category` VARCHAR(50) NOT NULL,
    `priority` VARCHAR(20) NOT NULL,
    `potential_savings_percent` DOUBLE,
    `potential_savings_amount` DOUBLE,
    `is_applied` BOOLEAN DEFAULT FALSE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_rec_utility` FOREIGN KEY (`utility_id`) REFERENCES `utilities` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_rec_building` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 12. Utility Predictions Table
CREATE TABLE IF NOT EXISTS `utility_predictions` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `utility_id` BIGINT NOT NULL,
    `building_id` BIGINT,
    `period` VARCHAR(30) NOT NULL,
    `predicted_units` DOUBLE NOT NULL,
    `predicted_cost` DOUBLE NOT NULL,
    `confidence_score` DOUBLE DEFAULT 90.0,
    `projected_over_budget_percent` DOUBLE DEFAULT 0.0,
    `assessment_status` VARCHAR(20),
    `root_cause` VARCHAR(500),
    `recommendation` VARCHAR(500),
    `deviation_percent` DOUBLE,
    `generated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_pred_utility` FOREIGN KEY (`utility_id`) REFERENCES `utilities` (`id`),
    CONSTRAINT `fk_pred_building` FOREIGN KEY (`building_id`) REFERENCES `buildings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;
