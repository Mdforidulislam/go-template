-- name: CreateProduct :one
INSERT INTO products (
    category_id, name, slug, sku, description, short_description, 
    price, discount_price, quantity, low_stock_threshold, stock_status, 
    label, tags, images_url, is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15
) RETURNING *;

-- name: GetProductById :one
SELECT p.*, c.name as category_name 
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.id = $1 AND p.deleted_at IS NULL LIMIT 1;

-- name: ListProducts :many
SELECT p.*, c.name as category_name
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.deleted_at IS NULL 
  AND ($1::uuid IS NULL OR p.category_id = $1)
  AND ($2::text IS NULL OR p.name ILIKE $2 OR p.tags @> ARRAY[$2::text])
ORDER BY p.created_at DESC
LIMIT $3 OFFSET $4;

-- name: UpdateProductStock :one
UPDATE products
SET quantity = $2, stock_status = $3, updated_at = CURRENT_TIMESTAMP
WHERE id = $1 AND deleted_at IS NULL
RETURNING id, quantity, stock_status;

-- name: SoftDeleteProduct :exec
UPDATE products 
SET deleted_at = CURRENT_TIMESTAMP, is_active = false 
WHERE id = $1;