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