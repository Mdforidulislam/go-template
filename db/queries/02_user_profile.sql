-- name: CreateUserProfile :one
INSERT INTO user_profiles (user_id, bio, address)
VALUES ($1, $2, $3)
RETURNING *;

-- name: GetUserProfileByUserID :one
SELECT * FROM user_profiles
WHERE user_id = $1 LIMIT 1;

-- name: UpdateUserProfile :one
UPDATE user_profiles
SET bio = $2,
    address = $3,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = $1
RETURNING *;

-- name: DeleteUserProfile :exec
DELETE FROM user_profiles
WHERE user_id = $1;