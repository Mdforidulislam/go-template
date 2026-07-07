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