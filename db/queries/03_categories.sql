-- name: CreateCategory :one
INSERT INTO categories (
    name, slug, description, image_url, is_active
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetCategoryById :one
SELECT * FROM categories WHERE id = $1 AND deleted_at IS NULL LIMIT 1;

-- name: ListCategories :many
SELECT * FROM categories 
WHERE deleted_at IS NULL AND ($1::boolean IS NULL OR is_active = $1)
ORDER BY name ASC
LIMIT $2 OFFSET $3;

-- name: UpdateCategory :one
UPDATE categories
SET name = $2, slug = $3, description = $4, image_url = $5, is_active = $6, updated_at = CURRENT_TIMESTAMP
WHERE id = $1 AND deleted_at IS NULL
RETURNING *;

-- name: SoftDeleteCategory :exec
UPDATE categories 
SET deleted_at = CURRENT_TIMESTAMP, is_active = false 
WHERE id = $1;