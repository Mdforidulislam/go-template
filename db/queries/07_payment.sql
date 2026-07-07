-- name: CreatePayment :one
INSERT INTO payments (
    order_id, transaction_id, amount, payment_method, status, raw_gateway_response
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: UpdatePaymentStatus :one
UPDATE payments
SET status = $2, raw_gateway_response = $3, paid_at = CASE WHEN $2 = 'paid'::payment_status_enum THEN CURRENT_TIMESTAMP ELSE paid_at END, updated_at = CURRENT_TIMESTAMP
WHERE transaction_id = $1
RETURNING *;