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