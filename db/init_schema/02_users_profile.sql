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