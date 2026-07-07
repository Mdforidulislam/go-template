-- name: CreateUser :one
INSERT INTO users (
    full_name, email, password_hash, phone_number, role
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING id, full_name, email, role, is_active, created_at;

-- name: GetUserByEmail :one
SELECT id, full_name, email, password_hash, role, is_active 
FROM users 
WHERE email = $1 AND deleted_at IS NULL LIMIT 1;

-- name: GetUserForUpdate :one
SELECT id, full_name, email, password_hash, role, is_active 
FROM users 
WHERE id = $1 AND deleted_at IS NULL LIMIT 1;

-- name: ListCustomers :many
SELECT id, full_name, email, phone_number, is_active, created_at 
FROM users 
WHERE role = 'customer' AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: UpdateUserStatus :exec
UPDATE users 
SET is_active = $2, updated_at = CURRENT_TIMESTAMP 
WHERE id = $1;

-- name: UpdateUserPassword :exec
UPDATE users 
SET password_hash = $2, updated_at = CURRENT_TIMESTAMP 
WHERE id = $1;