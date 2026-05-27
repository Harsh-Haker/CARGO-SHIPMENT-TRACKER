-- ============================================================
--  cargo_tracker.sql
--  Database Schema + Sample Data for Cargo Shipment Tracker
--
--  Instructions:
--    1. Open MySQL Workbench or MySQL CLI
--    2. Run: source /path/to/cargo_tracker.sql
--         OR copy-paste the contents into MySQL Workbench query editor
--    3. Verify: USE cargo_tracker; SHOW TABLES; SELECT * FROM shipments;
--
--  MySQL Version: 8.0+
-- ============================================================


-- ============================================================
--  Step 1: Create (or switch to) the database
-- ============================================================
CREATE DATABASE IF NOT EXISTS cargo_tracker
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cargo_tracker;


-- ============================================================
--  Step 2: Drop table if re-running (for clean setup)
-- ============================================================
DROP TABLE IF EXISTS shipments;


-- ============================================================
--  Step 3: Create the shipments table
-- ============================================================
CREATE TABLE shipments (
    id               INT           NOT NULL AUTO_INCREMENT,
    shipment_id      VARCHAR(20)   NOT NULL,
    customer_name    VARCHAR(100)  NOT NULL,
    current_location VARCHAR(150)  NOT NULL,
    shipment_status  VARCHAR(50)   NOT NULL,
    expected_delivery DATE         NULL,
    last_updated     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    origin_city      VARCHAR(100)  NOT NULL DEFAULT '',
    destination_city VARCHAR(100)  NOT NULL DEFAULT '',
    description      VARCHAR(500)  NULL,

    -- Primary key
    PRIMARY KEY (id),

    -- Business key: shipment_id must be unique
    UNIQUE KEY uq_shipment_id (shipment_id),

    -- Index for customer searches
    INDEX idx_customer_name (customer_name),

    -- Index for status filter queries
    INDEX idx_status (shipment_status)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Stores cargo shipment records for tracking';


-- ============================================================
--  Step 4: Insert sample shipment records
--
--  Status values (must match Shipment.getStatusStage() exactly):
--    "Order Placed" | "Packed" | "In Transit" |
--    "Arrived at Hub" | "Out for Delivery" | "Delivered"
-- ============================================================

INSERT INTO shipments
    (shipment_id, customer_name, current_location, shipment_status,
     expected_delivery, last_updated, origin_city, destination_city, description)
VALUES

-- CST001: Delivered
('CST001', 'Rahul Sharma',
 'New Delhi - Customer Address',
 'Delivered',
 '2025-05-20',
 '2025-05-20 14:30:00',
 'Mumbai',
 'New Delhi',
 'Electronics package — 2x Wireless Headphones. Handle with care.'),

-- CST002: Out for Delivery
('CST002', 'Priya Patel',
 'Bengaluru Hub — Zone 3 Courier',
 'Out for Delivery',
 '2025-05-28',
 '2025-05-27 08:45:00',
 'Chennai',
 'Bengaluru',
 'Clothing and accessories — 3 items. Fragile tag applied.'),

-- CST003: In Transit
('CST003', 'Arjun Mehta',
 'Nagpur Transit Warehouse',
 'In Transit',
 '2025-05-30',
 '2025-05-27 10:15:00',
 'Mumbai',
 'Hyderabad',
 'Industrial spare parts — 5 kg. Heavy package.'),

-- CST004: Arrived at Hub
('CST004', 'Sneha Gupta',
 'Pune Regional Distribution Hub',
 'Arrived at Hub',
 '2025-05-29',
 '2025-05-27 11:00:00',
 'Delhi',
 'Pune',
 'Books and stationery — 4 kg.'),

-- CST005: Packed
('CST005', 'Vikram Singh',
 'Kolkata Dispatch Center',
 'Packed',
 '2025-06-02',
 '2025-05-27 09:30:00',
 'Kolkata',
 'Ahmedabad',
 'Handicraft items — Fragile. Special packaging applied.'),

-- CST006: Order Placed
('CST006', 'Ananya Reddy',
 'Hyderabad Warehouse (Order Processing)',
 'Order Placed',
 '2025-06-05',
 '2025-05-27 12:00:00',
 'Hyderabad',
 'Jaipur',
 'Pharmaceutical supplies — Temperature sensitive. Cold chain required.'),

-- CST007: In Transit (International)
('CST007', 'Deepak Kumar',
 'Mumbai International Air Cargo',
 'In Transit',
 '2025-06-01',
 '2025-05-27 06:00:00',
 'Delhi',
 'Mumbai',
 'IT equipment — 3 laptops. High value. Insurance covered.'),

-- CST008: Delivered (Same City)
('CST008', 'Meera Joshi',
 'Jaipur — Delivered to Doorstep',
 'Delivered',
 '2025-05-25',
 '2025-05-25 16:45:00',
 'Jaipur',
 'Jaipur',
 'Local courier — Documents and certificates.'),

-- CST009: Out for Delivery
('CST009', 'Rohan Das',
 'Chandigarh Delivery Zone — Courier Agent #12',
 'Out for Delivery',
 '2025-05-28',
 '2025-05-27 07:30:00',
 'Ludhiana',
 'Chandigarh',
 'Kitchen appliances — 8 kg.'),

-- CST010: Packed
('CST010', 'Pooja Nair',
 'Kochi Packaging Facility',
 'Packed',
 '2025-06-03',
 '2025-05-27 13:20:00',
 'Kochi',
 'Thiruvananthapuram',
 'Organic food products — Perishable. Priority shipping.');


-- ============================================================
--  Step 5: Verify the data
-- ============================================================
SELECT
    shipment_id,
    customer_name,
    shipment_status,
    current_location,
    expected_delivery,
    origin_city,
    destination_city
FROM shipments
ORDER BY id;


-- ============================================================
--  Step 6: Create a read-only application user (RECOMMENDED)
--
--  For production, do NOT connect as root!
--  Run these commands in MySQL as root/admin:
-- ============================================================

-- CREATE USER 'cargo_user'@'localhost' IDENTIFIED BY 'CargoPass@2025';
-- GRANT SELECT, INSERT, UPDATE ON cargo_tracker.* TO 'cargo_user'@'localhost';
-- FLUSH PRIVILEGES;
--
-- Then update DBConnection.java:
--   DB_USER     = "cargo_user"
--   DB_PASSWORD = "CargoPass@2025"
