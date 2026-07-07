-- name: CreateOrUpdateProfile :one
INSERT INTO user_profiles (
    user_id, date_of_birth, gender, bio, division, district, street_address
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
)
ON CONFLICT (user_id) DO UPDATE SET
    date_of_birth = EXCLUDED.date_of_birth,
    gender = EXCLUDED.gender,
    bio = EXCLUDED.bio,
    division = EXCLUDED.division,
    district = EXCLUDED.district,
    street_address = EXCLUDED.street_address,
    updated_at = CURRENT_TIMESTAMP
RETURNING *;

-- name: GetProfileByUserId :one
SELECT * FROM user_profiles WHERE user_id = $1 LIMIT 1;