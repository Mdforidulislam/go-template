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


