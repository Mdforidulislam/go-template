-- name: PlaceOrder :one
INSERT INTO orders (
    order_unique_id, user_id, coupon_code, shipping_name, shipping_phone,
    shipping_district, shipping_thana, shipping_full_address, special_notes,
    subtotal, discount_amount, shipping_amount, total_amount, payment_method
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
) RETURNING *;

-- name: CreateOrderItem :one
INSERT INTO order_items (
    order_id, product_id, quantity, unit_price
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: CreateOrderStatusHistory :exec
INSERT INTO order_status_histories (
    order_id, changed_by, previous_shipping_status, new_shipping_status, remarks
) VALUES (
    $1, $2, $3, $4, $5
);

-- name: UpdateOrderStatus :one
UPDATE orders
SET shipping_status = $2, payment_status = $3, updated_at = CURRENT_TIMESTAMP
WHERE id = $1
RETURNING *;

-- name: GetOrderById :one
SELECT * FROM orders WHERE id = $1 LIMIT 1;

-- name: ListUserOrders :many
SELECT * FROM orders WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3;