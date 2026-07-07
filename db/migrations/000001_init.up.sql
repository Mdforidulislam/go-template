
-- ======================================================================
-- 📂 FROM FILE: 00_setup.sql
-- ======================================================================

-- ==========================================
-- FILE: db/init_schema/00_setup.sql
-- ==========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Define Custom Enums
CREATE TYPE role_enum AS ENUM ('admin', 'customer');
CREATE TYPE stock_status_enum AS ENUM ('in_stock', 'low_stock', 'out_of_stock');
CREATE TYPE product_label_enum AS ENUM ('none', 'new', 'featured', 'best_seller');
CREATE TYPE discount_type_enum AS ENUM ('percentage', 'fixed');
CREATE TYPE payment_method_enum AS ENUM ('cod', 'bkash', 'nagad', 'card');
CREATE TYPE payment_status_enum AS ENUM ('pending', 'paid', 'failed', 'refunded', 'voided');
CREATE TYPE shipping_status_enum AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'other');
CREATE TYPE review_status_enum AS ENUM ('pending', 'approved', 'rejected');

-- ======================================================================
-- 📂 FROM FILE: 01_users.sql
-- ======================================================================

-- ==========================================
-- FILE: db/init_schema/01_users.sql
-- ==========================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    role role_enum NOT NULL DEFAULT 'customer',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Optimization Index for active users check
CREATE INDEX idx_users_active ON users(id) WHERE deleted_at IS NULL AND is_active = true;




-- ======================================================================
-- 📂 FROM FILE: 02_users_profile.sql
-- ======================================================================

-- ==========================================
-- FILE: db/init_schema/02_user_profiles.sql
-- ==========================================

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth DATE,
    gender gender_enum,
    bio TEXT,
    division VARCHAR(50),
    district VARCHAR(50),
    street_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ======================================================================
-- 📂 FROM FILE: 03_categories.sql
-- ======================================================================

-- ==========================================
-- FILE: db/init_schema/03_categories.sql
-- ==========================================

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(150) NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Optimization Index for lookups
CREATE INDEX idx_categories_active ON categories(id) WHERE deleted_at IS NULL AND is_active = true;

-- ======================================================================
-- 📂 FROM FILE: 04_products.sql
-- ======================================================================

-- ==========================================
-- FILE: db/init_schema/04_products.sql
-- ==========================================

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    sku VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    short_description VARCHAR(255) NOT NULL,
    price DECIMAL(12, 2) NOT NULL CHECK (price > 0),
    discount_price DECIMAL(12, 2) CHECK (discount_price IS NULL OR discount_price < price),
    quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    low_stock_threshold INT NOT NULL DEFAULT 5,
    stock_status stock_status_enum NOT NULL DEFAULT 'out_of_stock',
    label product_label_enum NOT NULL DEFAULT 'none',
    tags TEXT[], 
    images_url TEXT[] NOT NULL, 
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Optimization Indexes for filtering & high performance search
CREATE INDEX idx_products_category ON products(category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_active ON products(id) WHERE deleted_at IS NULL AND is_active = true;
CREATE INDEX idx_products_price_stock ON products(price, stock_status) WHERE deleted_at IS NULL AND is_active = true;
CREATE INDEX idx_products_tags ON products USING gin (tags);
CREATE INDEX idx_products_name_search ON products USING gin (to_tsvector('english', name));

-- ======================================================================
-- 📂 FROM FILE: 05_coupons.sql
-- ======================================================================

-- ==========================================
-- FILE: db/init_schema/05_coupons.sql
-- ==========================================

CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    discount_type discount_type_enum NOT NULL,
    value DECIMAL(12, 2) NOT NULL CHECK (value > 0),
    min_order_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    max_discount_amount DECIMAL(12, 2),
    usage_limit INT,
    usage_limit_per_user INT DEFAULT 1,
    used_count INT NOT NULL DEFAULT 0,
    start_date TIMESTAMP WITH TIME ZONE,
    expiry_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- ======================================================================
-- 📂 FROM FILE: 06_orders.sql
-- ======================================================================

-- ==========================================
-- FILE: db/init_schema/06_orders.sql
-- ==========================================

-- 1. Master Orders Table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_unique_id VARCHAR(50) NOT NULL UNIQUE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, 
    coupon_code VARCHAR(50) REFERENCES coupons(coupon_code) ON DELETE SET NULL,
    
    -- Shipping Address Snapshot
    shipping_name VARCHAR(100) NOT NULL,
    shipping_phone VARCHAR(20) NOT NULL,
    shipping_district VARCHAR(50) NOT NULL,
    shipping_thana VARCHAR(50) NOT NULL,
    shipping_full_address TEXT NOT NULL,
    special_notes TEXT,
    
    -- Financials
    subtotal DECIMAL(12, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    shipping_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL,
    
    -- Status Flags
    payment_method payment_method_enum NOT NULL,
    payment_status payment_status_enum NOT NULL DEFAULT 'pending',
    shipping_status shipping_status_enum NOT NULL DEFAULT 'pending',
    is_payment_verified BOOLEAN NOT NULL DEFAULT false,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Junction Table: Order Items (With snapshot price)
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12, 2) NOT NULL,
    total_price DECIMAL(12, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

-- 3. Audit Log: Order Status History
CREATE TABLE order_status_histories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    changed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    previous_shipping_status shipping_status_enum,
    new_shipping_status shipping_status_enum NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Optimization Indexes
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_orders_status_date ON orders(shipping_status, created_at);

-- ======================================================================
-- 📂 FROM FILE: 07_payments.sql
-- ======================================================================

-- ==========================================
-- FILE: db/init_schema/07_payments.sql
-- ==========================================

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    transaction_id VARCHAR(100) UNIQUE,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method payment_method_enum NOT NULL,
    status payment_status_enum NOT NULL DEFAULT 'pending',
    raw_gateway_response JSONB,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_order ON payments(order_id);

-- ======================================================================
-- 📂 FROM FILE: 08_reviews.sql
-- ======================================================================

-- ==========================================
-- FILE: db/init_schema/08_reviews.sql
-- ==========================================

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    description TEXT NOT NULL,
    status review_status_enum NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for getting approved product reviews fast
CREATE INDEX idx_reviews_product ON reviews(product_id) WHERE status = 'approved';
