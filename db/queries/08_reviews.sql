-- name: CreateReview :one
INSERT INTO reviews (
    product_id, user_id, rating, description
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: UpdateReviewStatus :one
UPDATE reviews
SET status = $2, updated_at = CURRENT_TIMESTAMP
WHERE id = $1
RETURNING *;

-- name: ListProductReviews :many
SELECT r.*, u.full_name as user_name 
FROM reviews r
JOIN users u ON r.user_id = u.id
WHERE r.product_id = $1 AND r.status = 'approved'
ORDER BY r.created_at DESC
LIMIT $2 OFFSET $3;