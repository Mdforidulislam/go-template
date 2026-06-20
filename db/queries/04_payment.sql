-- name: CreatePayment :one
INSERT INTO payment (order_id, amount)
VALUES ($1, $2)
RETURNING *;

-- name: GetPaymentByID :one
SELECT * FROM payment
WHERE id = $1 LIMIT 1;

-- name: GetPaymentByOrderID :one
SELECT * FROM payment
WHERE order_id = $1 LIMIT 1;

-- name: ListPayments :many
SELECT * FROM payment
ORDER BY id DESC
LIMIT $1 OFFSET $2;