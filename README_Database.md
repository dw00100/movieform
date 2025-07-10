# Product and Product Promotion Database Schema

This repository contains SQL DDL statements for creating a product catalog database with promotional capabilities.

## Table Structure

### Product Table
The `product` table stores information about products in your catalog:

| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT (PK) | Auto-incrementing primary key |
| `name` | VARCHAR(255) | Product name (required) |
| `description` | TEXT | Detailed product description |
| `price` | DECIMAL(10,2) | Product price (required) |
| `sku` | VARCHAR(100) | Stock Keeping Unit (unique, required) |
| `category` | VARCHAR(100) | Product category |
| `brand` | VARCHAR(100) | Product brand |
| `stock_quantity` | INT | Available inventory count |
| `weight` | DECIMAL(8,3) | Product weight |
| `dimensions` | VARCHAR(50) | Product dimensions |
| `status` | ENUM | Product status: 'active', 'inactive', 'discontinued' |
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

### Product Promotion Table
The `product_promotion` table manages promotional offers for products:

| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT (PK) | Auto-incrementing primary key |
| `product_id` | BIGINT (FK) | References product.id |
| `promotion_name` | VARCHAR(255) | Name of the promotion (required) |
| `description` | TEXT | Promotion description |
| `discount_type` | ENUM | Type: 'percentage', 'fixed_amount', 'buy_x_get_y' |
| `discount_value` | DECIMAL(10,2) | Discount amount or percentage |
| `minimum_quantity` | INT | Minimum quantity for promotion |
| `maximum_uses` | INT | Maximum number of times promotion can be used |
| `uses_count` | INT | Current usage count |
| `start_date` | DATETIME | Promotion start date |
| `end_date` | DATETIME | Promotion end date |
| `status` | ENUM | Promotion status: 'active', 'inactive', 'expired' |
| `created_at` | TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

## Key Features

### Relationships
- One-to-many relationship between `product` and `product_promotion`
- Foreign key constraint ensures data integrity
- Cascade delete removes promotions when product is deleted

### Constraints
- Unique SKU requirement for products
- Discount value must be non-negative
- End date must be after start date
- Percentage discounts cannot exceed 100%
- Minimum quantity must be positive

### Indexes
- Performance indexes on frequently queried columns
- Composite indexes for date range queries
- Foreign key indexes for join operations

## Usage

### 1. Create the Database Schema
```sql
-- Run the database_schema.sql file
mysql -u username -p database_name < database_schema.sql
```

### 2. Common Queries

#### Get Active Products with Current Promotions
```sql
SELECT 
    p.name,
    p.price,
    pp.promotion_name,
    pp.discount_value,
    CASE 
        WHEN pp.discount_type = 'percentage' THEN p.price * (1 - pp.discount_value/100)
        WHEN pp.discount_type = 'fixed_amount' THEN p.price - pp.discount_value
        ELSE p.price
    END as discounted_price
FROM product p
LEFT JOIN product_promotion pp ON p.id = pp.product_id 
    AND pp.status = 'active' 
    AND NOW() BETWEEN pp.start_date AND pp.end_date
WHERE p.status = 'active';
```

#### Add a New Product
```sql
INSERT INTO product (name, description, price, sku, category, brand, stock_quantity) 
VALUES ('New Product', 'Product description', 29.99, 'NP-001', 'Category', 'Brand', 100);
```

#### Create a Promotion
```sql
INSERT INTO product_promotion (
    product_id, promotion_name, discount_type, discount_value, 
    start_date, end_date
) VALUES (
    1, 'Holiday Sale', 'percentage', 25.00, 
    '2024-12-01 00:00:00', '2024-12-31 23:59:59'
);
```

#### Update Product Stock
```sql
UPDATE product 
SET stock_quantity = stock_quantity - 1 
WHERE id = 1 AND stock_quantity > 0;
```

### 3. Sample Data
The schema includes sample data with:
- 4 sample products across different categories
- 4 sample promotions with different discount types
- Realistic product information and pricing

## Database Compatibility
This schema is designed for MySQL/MariaDB but can be adapted for other databases:
- **PostgreSQL**: Change `AUTO_INCREMENT` to `SERIAL`
- **SQLite**: Remove `AUTO_INCREMENT`, use `INTEGER PRIMARY KEY`
- **SQL Server**: Change data types and AUTO_INCREMENT syntax

## Performance Considerations
- Indexes are optimized for common query patterns
- Consider partitioning for large datasets
- Monitor query performance and adjust indexes as needed
- Use connection pooling for high-traffic applications

## Security Notes
- Implement proper access controls
- Use prepared statements to prevent SQL injection
- Regularly backup the database
- Monitor for unusual activity patterns