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