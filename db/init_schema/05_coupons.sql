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