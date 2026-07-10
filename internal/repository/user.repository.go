package repository

import (
	"context"

	db "example.com/m/v2/db/sqlc" 

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

// UserRepository interface
type UserRepository interface {
	// --- Users Queries ---
	CreateUser(ctx context.Context, arg db.CreateUserParams) (db.CreateUserRow, error)
	GetUserByEmail(ctx context.Context, email string) (db.GetUserByEmailRow, error)
	ListCustomers(ctx context.Context, arg db.ListCustomersParams) ([]db.ListCustomersRow, error)
	UpdateUserOne(ctx context.Context, id pgtype.UUID) error
	UpdateUserPassword(ctx context.Context, arg db.UpdateUserPasswordParams) error
	UpdateUserStatus(ctx context.Context, arg db.UpdateUserStatusParams) error

	// --- User Profile Queries ---
	CreateOrUpdateProfile(ctx context.Context, arg db.CreateOrUpdateProfileParams) (db.UserProfile, error)
	GetProfileByUserId(ctx context.Context, userID pgtype.UUID) (db.UserProfile, error)
}

// userSQLCRepository
type userSQLCRepository struct {
	q *db.Queries
}

// NewUserRepository 
func NewUserRepository(dbPool *pgxpool.Pool) UserRepository {
	return &userSQLCRepository{
		q: db.New(dbPool), 
	}
}

// ==========================================
// ---- IMPLEMENTATIONS  ----
// ==========================================

func (r *userSQLCRepository) CreateUser(ctx context.Context, arg db.CreateUserParams) (db.CreateUserRow, error) {
	return r.q.CreateUser(ctx, arg)
}

func (r *userSQLCRepository) GetUserByEmail(ctx context.Context, email string) (db.GetUserByEmailRow, error) {
	return r.q.GetUserByEmail(ctx, email)
}

func (r *userSQLCRepository) ListCustomers(ctx context.Context, arg db.ListCustomersParams) ([]db.ListCustomersRow, error) {
	return r.q.ListCustomers(ctx, arg)
}

func (r *userSQLCRepository) UpdateUserOne(ctx context.Context, id pgtype.UUID) error {
	return r.q.UpdateUserOne(ctx, id)
}

func (r *userSQLCRepository) UpdateUserPassword(ctx context.Context, arg db.UpdateUserPasswordParams) error {
	return r.q.UpdateUserPassword(ctx, arg)
}

func (r *userSQLCRepository) UpdateUserStatus(ctx context.Context, arg db.UpdateUserStatusParams) error {
	return r.q.UpdateUserStatus(ctx, arg)
}

func (r *userSQLCRepository) CreateOrUpdateProfile(ctx context.Context, arg db.CreateOrUpdateProfileParams) (db.UserProfile, error) {
	return r.q.CreateOrUpdateProfile(ctx, arg)
}

func (r *userSQLCRepository) GetProfileByUserId(ctx context.Context, userID pgtype.UUID) (db.UserProfile, error) {
	return r.q.GetProfileByUserId(ctx, userID)
}