package repository

import (
	"context"

	db "example.com/m/v2/db/sqlc"
	"github.com/jackc/pgx/v5/pgxpool"
)

// UserRepository interface defines all data layer operations for a User.
type UserRepository interface {
	CreateUser(ctx context.Context, arg db.CreateUserParams) (db.User, error)
	GetUserByID(ctx context.Context, id int64) (db.User, error)
	ListUsers(ctx context.Context, arg db.ListCustomersParams) ([]db.User, error)
	UpdateUser(ctx context.Context, arg db.up) (db.User, error)
	DeleteUser(ctx context.Context, id int64) error
}

// userSQLCRepository struct implements the UserRepository interface.
type userSQLCRepository struct {
	q *db.Queries
}

// NewUserRepository is a constructor that returns the UserRepository interface.
func NewUserRepository(dbPool *pgxpool.Pool) UserRepository {
	return &userSQLCRepository{
		q: db.New(db.DBTX(dbPool))
	}
}

// ---- Implementations ----
func (r *userSQLCRepository) CreateUser(ctx context.Context, arg db.CreateUserParams) (db.User, error) {
	return r.q.CreateUser(ctx, arg)
}

func (r *userSQLCRepository) GetUserByID(ctx context.Context, id int64) (db.User, error) {
	return r.q.GetUserByID(ctx, id)
}

func (r *userSQLCRepository) ListUsers(ctx context.Context, arg db.ListUsersParams) ([]db.User, error) {
	return r.q.ListUsers(ctx, arg)
}

func (r *userSQLCRepository) UpdateUser(ctx context.Context, arg db.UpdateUserParams) (db.User, error) {
	return r.q.UpdateUser(ctx, arg)
}

func (r *userSQLCRepository) DeleteUser(ctx context.Context, id int64) error {
	return r.q.DeleteUser(ctx, id)
}