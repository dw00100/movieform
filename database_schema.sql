-- Database Schema for Product and Product Promotion Tables
-- Created: $(date)

-- Drop tables if they exist (for clean recreation)
DROP TABLE IF EXISTS product_promotion;
DROP TABLE IF EXISTS product;

-- Create Product table
CREATE TABLE product (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(100),
    brand VARCHAR(100),
    stock_quantity INT DEFAULT 0,
    weight DECIMAL(8, 3),
    dimensions VARCHAR(50),
    status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for better performance
    INDEX idx_product_sku (sku),
    INDEX idx_product_category (category),
    INDEX idx_product_brand (brand),
    INDEX idx_product_status (status),
    INDEX idx_product_created_at (created_at)
);

-- Create Product Promotion table
CREATE TABLE product_promotion (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    promotion_name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_type ENUM('percentage', 'fixed_amount', 'buy_x_get_y') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    minimum_quantity INT DEFAULT 1,
    maximum_uses INT,
    uses_count INT DEFAULT 0,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    status ENUM('active', 'inactive', 'expired') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Indexes for better performance
    INDEX idx_promotion_product_id (product_id),
    INDEX idx_promotion_dates (start_date, end_date),
    INDEX idx_promotion_status (status),
    INDEX idx_promotion_type (discount_type),
    INDEX idx_promotion_created_at (created_at),
    
    -- Constraints
    CONSTRAINT chk_discount_value CHECK (discount_value >= 0),
    CONSTRAINT chk_dates CHECK (end_date > start_date),
    CONSTRAINT chk_minimum_quantity CHECK (minimum_quantity > 0),
    CONSTRAINT chk_percentage_discount CHECK (
        discount_type != 'percentage' OR discount_value <= 100
    )
);

-- Insert sample data for testing
INSERT INTO product (name, description, price, sku, category, brand, stock_quantity) VALUES
('Wireless Bluetooth Headphones', 'High-quality wireless headphones with noise cancellation', 99.99, 'WBH-001', 'Electronics', 'AudioTech', 50),
('Organic Cotton T-Shirt', 'Comfortable organic cotton t-shirt in various colors', 24.99, 'OCT-001', 'Clothing', 'EcoWear', 200),
('Stainless Steel Water Bottle', 'Insulated water bottle keeps drinks cold for 24 hours', 34.99, 'SSB-001', 'Home & Garden', 'HydroLife', 75),
('Smartphone Case', 'Protective case for latest smartphone models', 19.99, 'SPC-001', 'Electronics', 'ProtectPlus', 150);

INSERT INTO product_promotion (product_id, promotion_name, description, discount_type, discount_value, start_date, end_date) VALUES
(1, 'Black Friday Sale', '20% off wireless headphones', 'percentage', 20.00, '2024-11-29 00:00:00', '2024-11-30 23:59:59'),
(2, 'Summer Collection', '$5 off organic t-shirts', 'fixed_amount', 5.00, '2024-06-01 00:00:00', '2024-08-31 23:59:59'),
(3, 'Bundle Deal', '15% off for 2+ water bottles', 'percentage', 15.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59'),
(4, 'New Customer Discount', '10% off first purchase', 'percentage', 10.00, '2024-01-01 00:00:00', '2024-12-31 23:59:59');

-- Useful queries for working with the tables

-- Get all active products with current promotions
SELECT 
    p.id,
    p.name as product_name,
    p.price,
    p.sku,
    pp.promotion_name,
    pp.discount_type,
    pp.discount_value,
    pp.start_date,
    pp.end_date,
    CASE 
        WHEN pp.discount_type = 'percentage' THEN p.price * (1 - pp.discount_value/100)
        WHEN pp.discount_type = 'fixed_amount' THEN p.price - pp.discount_value
        ELSE p.price
    END as discounted_price
FROM product p
LEFT JOIN product_promotion pp ON p.id = pp.product_id 
    AND pp.status = 'active' 
    AND NOW() BETWEEN pp.start_date AND pp.end_date
WHERE p.status = 'active'
ORDER BY p.name;

-- Get promotion statistics
SELECT 
    pp.promotion_name,
    COUNT(p.id) as products_count,
    AVG(p.price) as avg_product_price,
    pp.discount_type,
    pp.discount_value,
    pp.start_date,
    pp.end_date
FROM product_promotion pp
JOIN product p ON pp.product_id = p.id
WHERE pp.status = 'active'
GROUP BY pp.id, pp.promotion_name, pp.discount_type, pp.discount_value, pp.start_date, pp.end_date
ORDER BY pp.start_date DESC;