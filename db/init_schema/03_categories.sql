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