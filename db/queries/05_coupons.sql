-- name: CreateCoupon :one
INSERT INTO coupons (
    coupon_code, description, discount_type, value, min_order_amount, 
    max_discount_amount, usage_limit, usage_limit_per_user, start_date, expiry_date
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: GetCouponByCode :one
SELECT * FROM coupons 
WHERE coupon_code = $1 AND is_active = true AND deleted_at IS NULL AND expiry_date > CURRENT_TIMESTAMP 
LIMIT 1;

-- name: TrackCouponUsage :exec
UPDATE coupons 
SET used_count = used_count + 1, updated_at = CURRENT_TIMESTAMP 
WHERE id = $1;