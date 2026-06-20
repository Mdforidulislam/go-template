-- name: CreateProduct :one
INSERT INTO products (name, description, image_url, slug, price, is_stock, stock_quantity)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: GetProductByID :one
SELECT * FROM products
WHERE id = $1 LIMIT 1;

-- name: GetProductBySlug :one
SELECT * FROM products
WHERE slug = $1 LIMIT 1;

-- name: ListProducts :many
SELECT * FROM products
ORDER BY id DESC
LIMIT $1 OFFSET $2;

-- name: UpdateProductPrice :one
UPDATE products 
SET price = @new_price,
    updated_at = CURRENT_TIMESTAMP
WHERE id = @product_id
RETURNING *;

-- name: UpdateProductStock :one
UPDATE products
SET stock_quantity = @stock,
    is_stock = @is_stock,
    updated_at = CURRENT_TIMESTAMP
WHERE id = @product_id
RETURNING *;

-- name: DeleteProduct :exec
DELETE FROM products
WHERE id = $1;